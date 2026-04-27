import 'package:flutter/foundation.dart';
import 'cart_item.dart';
import '../mechanics/models/plan_model.dart';

class CartProvider with ChangeNotifier {
  final List<CartItem> _items = [];
  String? _companyId;
  String? _companyName;

  List<CartItem> get items => _items;
  String? get companyId => _companyId;
  String? get companyName => _companyName;
  bool get isEmpty => _items.isEmpty;
  int get itemCount => _items.length;

  double get subtotal => _items.fold(0.0, (sum, item) => sum + item.subtotal);
  double get taxAmount => _items.fold(0.0, (sum, item) => sum + item.taxAmount);
  double get total => _items.fold(0.0, (sum, item) => sum + item.total);

  void addPlan(PlanModel plan, String serviceName, String companyId, String companyName) {
    // If cart has items from different company, clear it
    if (_companyId != null && _companyId != companyId) {
      _items.clear();
    }

    _companyId = companyId;
    _companyName = companyName;

    // Check if plan already exists - don't add duplicates
    final existingIndex = _items.indexWhere((item) => item.plan.id == plan.id);
    
    if (existingIndex < 0) {
      // Add new plan to cart (multiple different plans allowed)
      _items.add(CartItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        plan: plan,
        serviceName: serviceName,
      ));
      notifyListeners();
    }
  }

  void removePlan(String planId) {
    _items.removeWhere((item) => item.plan.id == planId);
    
    if (_items.isEmpty) {
      _companyId = null;
      _companyName = null;
    }
    
    notifyListeners();
  }

  void clear() {
    _items.clear();
    _companyId = null;
    _companyName = null;
    notifyListeners();
  }

  bool isPlanInCart(String planId) {
    return _items.any((item) => item.plan.id == planId);
  }
}

