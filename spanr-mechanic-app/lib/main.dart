import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'config/app_router.dart';
import 'config/supabase_config.dart';
import 'core/offline/connectivity_service.dart';
import 'core/offline/hive_boxes.dart';
import 'core/providers/app_providers.dart';
import 'core/theme/app_theme.dart';
import 'auth/auth_provider.dart';
import 'auth/auth_service.dart';
import 'auth/attendance_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  await SupabaseConfig.initialize();
  await HiveBoxes.init();

  runApp(const SpanrMechanicApp());
}

class SpanrMechanicApp extends StatefulWidget {
  const SpanrMechanicApp({super.key});

  @override
  State<SpanrMechanicApp> createState() => _SpanrMechanicAppState();
}

class _SpanrMechanicAppState extends State<SpanrMechanicApp> {
  late final AuthProvider _authProvider;
  late final ConnectivityService _connectivity;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _authProvider = AuthProvider(AuthService(), AttendanceService());
    _connectivity = ConnectivityService();
    _router = AppRouter.create(_authProvider);
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    await _connectivity.init();
    await _authProvider.init();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ...buildProviders(),
        ChangeNotifierProvider<AuthProvider>.value(value: _authProvider),
        Provider<ConnectivityService>.value(value: _connectivity),
      ],
      child: MaterialApp.router(
        title: 'SPANR Mechanic',
        theme: AppTheme.lightTheme,
        routerConfig: _router,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
