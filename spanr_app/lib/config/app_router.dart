import 'dart:io';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../auth/auth_provider.dart';
import '../auth/screens/login_screen.dart';
import '../auth/screens/signup_screen.dart';
import '../screens/home_screen.dart';
import '../screens/splash_screen.dart';
import '../addresses/screens/addresses_list_screen.dart';
import '../addresses/screens/address_form_screen.dart';
import '../addresses/models/address.dart';
import '../mechanics/models/mechanic_company.dart';
import '../mechanics/screens/mechanic_detail_screen.dart';
import '../vehicles/models/vehicle_model.dart';
import '../vehicles/screens/add_vehicle_screen.dart';
import '../booking/select_vehicle_screen.dart';
import '../booking/checkout_screen.dart';
import '../booking/orders_screen.dart';
import '../booking/order_details_screen.dart';
import '../booking/order_confirmation_screen.dart';
import '../booking/payment_processing_screen.dart';
import '../booking/order_model.dart';

class AppRouter {
  static GoRouter createRouter() {
    return GoRouter(
      initialLocation: '/splash',
      redirect: (context, state) {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final isAuthenticated = authProvider.isAuthenticated;
        final isLoading = authProvider.isLoading;

        // Don't redirect while loading
        if (isLoading) {
          return null;
        }

        final isAuthRoute = state.matchedLocation == '/login' ||
            state.matchedLocation == '/signup';

        // Redirect to login if not authenticated and not on auth page
        if (!isAuthenticated && !isAuthRoute && state.matchedLocation != '/splash') {
          return '/login';
        }

        // Redirect to home if authenticated and on auth page
        if (isAuthenticated && isAuthRoute) {
          return '/home';
        }

        return null;
      },
      routes: [
        GoRoute(
          path: '/splash',
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/signup',
          builder: (context, state) => const SignupScreen(),
        ),
        GoRoute(
          path: '/home',
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: '/vehicles/add',
          builder: (context, state) => const AddVehicleScreen(),
        ),
        GoRoute(
          path: '/addresses',
          builder: (context, state) => const AddressesListScreen(),
        ),
        GoRoute(
          path: '/addresses/add',
          builder: (context, state) {
            final prefill = state.extra as Address?;
            return AddressFormScreen(address: prefill);
          },
        ),
        GoRoute(
          path: '/addresses/edit',
          builder: (context, state) {
            final address = state.extra as Address?;
            return AddressFormScreen(address: address);
          },
        ),
        GoRoute(
          path: '/mechanic/:id',
          builder: (context, state) {
            final company = state.extra as MechanicCompany;
            return MechanicDetailScreen(company: company);
          },
        ),
        GoRoute(
          path: '/select-vehicle',
          builder: (context, state) {
            final company = state.extra as MechanicCompany;
            return SelectVehicleScreen(company: company);
          },
        ),
        GoRoute(
          path: '/checkout',
          builder: (context, state) {
            final data = state.extra as Map<String, dynamic>;
            return CheckoutScreen(
              company: data['company'] as MechanicCompany,
              vehicle: data['vehicle'] as VehicleModel,
              beforeImages: data['beforeImages'] as List<File>,
            );
          },
        ),
        GoRoute(
          path: '/orders',
          builder: (context, state) => const OrdersScreen(),
        ),
        GoRoute(
          path: '/orders/:id',
          builder: (context, state) {
            final orderId = state.pathParameters['id']!;
            return OrderDetailsScreen(orderId: orderId);
          },
        ),
        GoRoute(
          path: '/order-confirmation',
          builder: (context, state) {
            final data = state.extra as Map<String, dynamic>;
            return OrderConfirmationScreen(
              order: data['order'] as OrderModel,
              payment: data['payment'] as PaymentModel,
            );
          },
        ),
        GoRoute(
          path: '/payment-processing',
          builder: (context, state) {
            final data = state.extra as Map<String, dynamic>;
            return PaymentProcessingScreen(
              order: data['order'] as OrderModel,
              payment: data['payment'] as PaymentModel,
              status: data['status'] as String,
            );
          },
        ),
      ],
    );
  }
}
