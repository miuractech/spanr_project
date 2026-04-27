import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class PlacePrediction {
  final String placeId;
  final String description;
  final String mainText;
  final String secondaryText;

  const PlacePrediction({
    required this.placeId,
    required this.description,
    required this.mainText,
    required this.secondaryText,
  });
}

class PlaceDetails {
  final double latitude;
  final double longitude;
  final String formattedAddress;
  final String street;
  final String city;
  final String state;
  final String postalCode;
  final String country;

  const PlaceDetails({
    required this.latitude,
    required this.longitude,
    required this.formattedAddress,
    required this.street,
    required this.city,
    required this.state,
    required this.postalCode,
    required this.country,
  });
}

class PlacesService {
  static String get _apiKey => dotenv.env['GOOGLE_MAPS_API_KEY'] ?? '';

  Future<List<PlacePrediction>> autocomplete(String input) async {
    if (input.length < 2) return [];
    try {
      final uri = Uri.https(
        'maps.googleapis.com',
        '/maps/api/place/autocomplete/json',
        {'input': input, 'key': _apiKey},
      );
      final response = await http.get(uri);
      if (response.statusCode != 200) return [];
      final data = json.decode(response.body) as Map<String, dynamic>;
      if (data['status'] != 'OK') return [];
      return (data['predictions'] as List)
          .map((p) => PlacePrediction(
                placeId: p['place_id'] as String,
                description: p['description'] as String,
                mainText:
                    (p['structured_formatting'] as Map)['main_text'] as String,
                secondaryText:
                    (p['structured_formatting'] as Map)['secondary_text']
                        as String? ??
                        '',
              ))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<PlaceDetails?> getPlaceDetails(String placeId) async {
    try {
      final uri = Uri.https(
        'maps.googleapis.com',
        '/maps/api/place/details/json',
        {
          'place_id': placeId,
          'fields': 'geometry,address_components,formatted_address',
          'key': _apiKey,
        },
      );
      final response = await http.get(uri);
      if (response.statusCode != 200) return null;
      final data = json.decode(response.body) as Map<String, dynamic>;
      if (data['status'] != 'OK') return null;

      final result = data['result'] as Map<String, dynamic>;
      final loc = (result['geometry'] as Map)['location'] as Map;
      final components = result['address_components'] as List;

      String getComponent(String type) {
        final c = components
            .where((c) => (c['types'] as List).contains(type))
            .firstOrNull;
        return c?['long_name'] as String? ?? '';
      }

      final streetNumber = getComponent('street_number');
      final route = getComponent('route');
      final street =
          [streetNumber, route].where((s) => s.isNotEmpty).join(' ');

      return PlaceDetails(
        latitude: (loc['lat'] as num).toDouble(),
        longitude: (loc['lng'] as num).toDouble(),
        formattedAddress: result['formatted_address'] as String? ?? '',
        street: street,
        city: getComponent('locality'),
        state: getComponent('administrative_area_level_1'),
        postalCode: getComponent('postal_code'),
        country: getComponent('country'),
      );
    } catch (_) {
      return null;
    }
  }
}
