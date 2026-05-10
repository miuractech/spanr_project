import 'dart:io';
import 'package:postgrest/postgrest.dart';
import 'package:uuid/uuid.dart';
import '../config/supabase_config.dart';
import 'models/vehicle_model.dart';

class VehiclesService {
  final _client = SupabaseConfig.client;
  final _uuid = const Uuid();

  bool _isMissingColumnError(Object error, String columnName) {
    if (error is! PostgrestException) return false;
    final message = error.message.toString();
    final details = error.details?.toString() ?? '';
    final hint = error.hint?.toString() ?? '';
    return error.code == '42703' &&
        (message.contains(columnName) ||
            details.contains(columnName) ||
            hint.contains(columnName));
  }

  Map<String, dynamic> _withoutUnsupportedVehicleColumns(
    Map<String, dynamic> data,
  ) {
    final cleaned = Map<String, dynamic>.from(data);
    cleaned.remove('is_primary');
    return cleaned;
  }

  Future<List<VehicleModel>> getVehiclesByUser(String authUserId) async {
    try {
      // authUserId is the user's id directly (no lookup needed)
      // Order by primary first, then by created_at
      List<dynamic> vehicles;
      try {
        vehicles = await _client
            .from('vehicles')
            .select('*')
            .eq('user_id', authUserId)
            .order('is_primary', ascending: false)
            .order('created_at', ascending: false);
      } catch (e) {
        if (!_isMissingColumnError(e, 'is_primary')) rethrow;
        vehicles = await _client
            .from('vehicles')
            .select('*')
            .eq('user_id', authUserId)
            .order('created_at', ascending: false);
      }

      final vehicleList = <VehicleModel>[];
      
      for (final vehicleData in vehicles) {
        // Fetch images for this vehicle
        final images = await _client
            .from('images')
            .select('url')
            .eq('entity_type', 'vehicle')
            .eq('entity_id', vehicleData['id']);
        
        // Add images to vehicle data
        vehicleData['images'] = images;
        vehicleList.add(VehicleModel.fromJson(vehicleData));
      }

      return vehicleList;
    } catch (e) {
      rethrow;
    }
  }

  Future<VehicleModel> createVehicle(VehicleModel vehicle) async {
    try {
      // userId is the auth user id directly
      final vehicleData = vehicle.toJson();

      Map<String, dynamic> response;
      try {
        response = await _client
            .from('vehicles')
            .insert(vehicleData)
            .select()
            .single();
      } catch (e) {
        if (!_isMissingColumnError(e, 'is_primary')) rethrow;
        response = await _client
            .from('vehicles')
            .insert(_withoutUnsupportedVehicleColumns(vehicleData))
            .select()
            .single();
      }

      return VehicleModel.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  Future<VehicleModel> updateVehicle(
      String vehicleId, Map<String, dynamic> updates) async {
    try {
      Map<String, dynamic> response;
      try {
        response = await _client
            .from('vehicles')
            .update(updates)
            .eq('id', vehicleId)
            .select()
            .single();
      } catch (e) {
        if (!_isMissingColumnError(e, 'is_primary')) rethrow;
        response = await _client
            .from('vehicles')
            .update(_withoutUnsupportedVehicleColumns(updates))
            .eq('id', vehicleId)
            .select()
            .single();
      }

      // Fetch images for this vehicle
      final images = await _client
          .from('images')
          .select('url')
          .eq('entity_type', 'vehicle')
          .eq('entity_id', vehicleId);
      
      response['images'] = images;

      return VehicleModel.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteVehicle(String vehicleId) async {
    try {
      // Delete images from storage
      final images = await _client
          .from('images')
          .select('file_name')
          .eq('entity_type', 'vehicle')
          .eq('entity_id', vehicleId);

      for (final image in images) {
        await _client.storage
            .from('vehicle-images')
            .remove([image['file_name']]);
      }

      // Delete vehicle (will cascade delete images records)
      await _client.from('vehicles').delete().eq('id', vehicleId);
    } catch (e) {
      rethrow;
    }
  }

  Future<String> uploadImage(String vehicleId, File imageFile) async {
    try {
      final fileName = '${vehicleId}_${_uuid.v4()}.jpg';
      
      // Upload to storage
      await _client.storage
          .from('vehicle-images')
          .upload(fileName, imageFile);

      // Get public URL
      final url = _client.storage
          .from('vehicle-images')
          .getPublicUrl(fileName);

      // Save to images table
      await _client.from('images').insert({
        'entity_type': 'vehicle',
        'entity_id': vehicleId,
        'url': url,
        'file_name': fileName,
      });

      return url;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteImage(String vehicleId, String imageUrl) async {
    try {
      // Get file name from images table
      final imageRecord = await _client
          .from('images')
          .select('file_name')
          .eq('entity_type', 'vehicle')
          .eq('entity_id', vehicleId)
          .eq('url', imageUrl)
          .single();

      // Delete from storage
      await _client.storage
          .from('vehicle-images')
          .remove([imageRecord['file_name']]);

      // Delete from images table
      await _client
          .from('images')
          .delete()
          .eq('entity_type', 'vehicle')
          .eq('entity_id', vehicleId)
          .eq('url', imageUrl);
    } catch (e) {
      rethrow;
    }
  }
}

