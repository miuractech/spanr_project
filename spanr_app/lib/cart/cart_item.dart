import '../mechanics/models/plan_model.dart';

class CartItem {
  final String id;
  final PlanModel plan;
  final String serviceName;

  CartItem({
    required this.id,
    required this.plan,
    required this.serviceName,
  });

  double get subtotal => plan.basePrice;
  double get taxAmount => subtotal * plan.tax / 100;
  double get total => subtotal * (1 + plan.tax / 100);
}

