import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'config/supabase_config.dart';
import 'config/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/providers/app_providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await SupabaseConfig.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: AppProviders.providers,
      child: Builder(
        builder: (context) {
          return MaterialApp.router(
            title: 'SPANR',
            theme: AppTheme.lightTheme,
            routerConfig: AppRouter.createRouter(),
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}
