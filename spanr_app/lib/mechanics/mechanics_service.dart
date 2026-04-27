import 'dart:math' as math;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'models/mechanic_company.dart';

class MechanicsService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<MechanicCompany>> getNearbyMechanics({
    required double latitude,
    required double longitude,
    double radiusKm = 7.0,
    int limit = 10,
    int offset = 0,
    String? searchQuery,
  }) async {
    var query = _supabase
        .from('mechanic_companies')
        .select('''
          *,
          company_ratings(
            count,
            professionalism,
            timeliness,
            quality,
            rating
          )
        ''')
        .not('latitude', 'is', null)
        .not('longitude', 'is', null);
    
    // Add search filter if query is provided
    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      query = query.ilike('company_name', '%${searchQuery.trim()}%');
    }

    final response = await query;

    final companies = (response as List)
        .map((json) {
          // Flatten ratings data
          final jsonMap = json as Map<String, dynamic>;
          final ratings = jsonMap['company_ratings'] != null 
              ? (jsonMap['company_ratings'] is List 
                  ? (jsonMap['company_ratings'] as List).firstOrNull 
                  : jsonMap['company_ratings'])
              : null;
          
          return {
            ...jsonMap,
            'ratings_count': ratings?['count'],
            'professionalism': ratings?['professionalism'],
            'timeliness': ratings?['timeliness'],
            'quality': ratings?['quality'],
            'rating': ratings?['rating'],
          };
        })
        .map((json) => MechanicCompany.fromJson(json))
        .toList();

    // Calculate distance and filter by radius
    final nearbyWithDistance = <MechanicCompany>[];
    for (final company in companies) {
      if (company.latitude == null || company.longitude == null) continue;
      
      final distance = _calculateDistance(
        latitude,
        longitude,
        company.latitude!,
        company.longitude!,
      );
      
      if (distance <= radiusKm) {
        nearbyWithDistance.add(company.copyWith(distanceKm: distance));
      }
    }

    // Sort by distance
    nearbyWithDistance.sort((a, b) => a.distanceKm!.compareTo(b.distanceKm!));
    
    // Apply pagination
    final start = offset;
    final end = offset + limit;
    if (start >= nearbyWithDistance.length) {
      return [];
    }
    
    return nearbyWithDistance.sublist(
      start, 
      end > nearbyWithDistance.length ? nearbyWithDistance.length : end
    );
  }

  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    // Using Haversine formula
    const double earthRadius = 6371.0; // km
    
    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);
    final lat1Rad = _toRadians(lat1);
    final lat2Rad = _toRadians(lat2);

    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1Rad) * math.cos(lat2Rad) * 
        math.sin(dLon / 2) * math.sin(dLon / 2);

    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadius * c;
  }

  double _toRadians(double degrees) => degrees * math.pi / 180.0;
}

