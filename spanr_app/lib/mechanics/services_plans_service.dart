import 'package:supabase_flutter/supabase_flutter.dart';
import 'models/service_model.dart';
import 'models/plan_model.dart';

class ServicesPlanService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Service categories for a company — sourced from `job_sections`, the
  /// table the mechanic dashboard's live Services page actually writes to
  /// (the legacy standalone `services` table is no longer populated).
  Future<List<ServiceModel>> getServicesByCompany(String companyId) async {
    final response = await _supabase
        .from('job_sections')
        .select('*')
        .eq('company_id', companyId)
        .order('display_order', ascending: true);

    return (response as List)
        .map((json) => ServiceModel.fromJobSection(json))
        .toList();
  }

  /// All package/custom plans for a company. Plans are no longer linked to
  /// an individual service/job (`plans.service_id` is nullable and left
  /// unset by the dashboard); they're scoped to the company + vehicle type.
  Future<List<PlanModel>> getPlansByCompany(String companyId) async {
    final response = await _supabase
        .from('plans')
        .select('''
          *,
          plan_fuel_types(fuel_type),
          plan_features(feature)
        ''')
        .eq('company_id', companyId)
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

  /// Groups the company's plans under each service category by matching
  /// vehicle type (car/bike) — the only relationship the current data model
  /// still preserves between a service section and a plan.
  Future<Map<String, List<PlanModel>>> getServicesPlansByCompany(
      String companyId) async {
    final services = await getServicesByCompany(companyId);
    final allPlans = await getPlansByCompany(companyId);
    final Map<String, List<PlanModel>> result = {};

    for (final service in services) {
      final plans =
          allPlans.where((p) => p.vehicleType == service.category).toList();
      if (plans.isNotEmpty) {
        result[service.id] = plans;
      }
    }

    return result;
  }
}

