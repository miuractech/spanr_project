import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import '../../auth/auth_provider.dart';
import '../../vehicles/vehicles_provider.dart';
import '../../addresses/addresses_provider.dart';
import '../../mechanics/mechanics_provider.dart';
import '../../cart/cart_provider.dart';
import '../../booking/order_provider.dart';

class AppProviders {
  static List<SingleChildWidget> get providers => [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => VehiclesProvider()),
        ChangeNotifierProvider(create: (_) => AddressesProvider()),
        ChangeNotifierProvider(create: (_) => MechanicsProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
      ];
}

