import 'package:supabase_flutter/supabase_flutter.dart';
import 'models/service_model.dart';
import 'models/plan_model.dart';

class ServicesPlanService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<ServiceModel>> getServicesByCompany(String companyId) async {
    final response = await _supabase
        .from('services')
        .select('*')
        .eq('company_id', companyId)
        .order('name', ascending: true);

    return (response as List)
        .map((json) => ServiceModel.fromJson(json))
        .toList();
  }

  Future<List<PlanModel>> getPlansByService(String serviceId) async {
    final response = await _supabase
        .from('plans')
        .select('''
          *,
          plan_fuel_types(fuel_type),
          plan_features(feature)
        ''')
        .eq('service_id', serviceId)
        .order('base_price', ascending: true);

    return (response as List).map((json) {
      // Extract fuel types
      final fuelTypes = json['plan_fuel_types'] != null
          ? (json['plan_fuel_types'] as List)
              .map((ft) => ft['fuel_type'] as String)
              .toList()
          : <String>[];

      // Extract features
      final features = json['plan_features'] != null
          ? (json['plan_features'] as List)
              .map((f) => f['feature'] as String)
              .toList()
          : <String>[];

      return PlanModel.fromJson({
        ...json,
        'fuel_types': fuelTypes,
        'features': features,
      });
    }).toList();
  }

  Future<Map<String, List<PlanModel>>> getServicesPlansByCompany(
      String companyId) async {
    final services = await getServicesByCompany(companyId);
    final Map<String, List<PlanModel>> result = {};

    for (final service in services) {
      final plans = await getPlansByService(service.id);
      if (plans.isNotEmpty) {
        result[service.id] = plans;
      }
    }

    return result;
  }
}

