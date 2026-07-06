import 'package:go_router/go_router.dart';
import '../auth/auth_provider.dart';
import '../auth/screens/login_screen.dart';
import '../auth/screens/splash_screen.dart';
import '../auth/screens/change_password_screen.dart';
import '../jobs/screens/jobs_list_screen.dart';
import '../jobs/screens/job_detail_screen.dart';
import '../jobs/screens/before_inspection_screen.dart';
import '../jobs/screens/after_inspection_screen.dart';
import '../jobs/screens/parts_replacement_screen.dart';
import '../jobs/screens/part_replacement_detail_screen.dart';
import '../jobs/screens/service_notes_screen.dart';
import '../jobs/screens/complete_job_screen.dart';
import '../jobs/screens/extra_work_request_screen.dart';

class AppRouter {
  static GoRouter create(AuthProvider authProvider) {
    return GoRouter(
      initialLocation: '/splash',
      refreshListenable: authProvider,
      redirect: (context, state) {
        if (authProvider.isLoading) {
          return state.matchedLocation == '/splash' ? null : '/splash';
        }
        if (state.matchedLocation == '/splash') {
          return authProvider.isAuthenticated
              ? (authProvider.mustChangePassword ? '/change-password' : '/jobs')
              : '/login';
        }
        final isAuth = authProvider.isAuthenticated;
        final isLogin = state.matchedLocation == '/login';
        final isChangePassword = state.matchedLocation == '/change-password';

        if (!isAuth && !isLogin) return '/login';
        if (isAuth && isLogin) {
          return authProvider.mustChangePassword ? '/change-password' : '/jobs';
        }
        if (isAuth && authProvider.mustChangePassword && !isChangePassword) {
          return '/change-password';
        }
        if (isAuth && !authProvider.mustChangePassword && isChangePassword) {
          return '/jobs';
        }
        return null;
      },
      routes: [
        GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),
        GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
        GoRoute(path: '/change-password', builder: (_, __) => const ChangePasswordScreen()),
        GoRoute(path: '/jobs', builder: (_, __) => const JobsListScreen()),
        GoRoute(
          path: '/jobs/:orderId',
          builder: (_, state) => JobDetailScreen(orderId: state.pathParameters['orderId']!),
          routes: [
            GoRoute(
              path: 'before',
              builder: (_, state) => BeforeInspectionScreen(orderId: state.pathParameters['orderId']!),
            ),
            GoRoute(
              path: 'after',
              builder: (_, state) => AfterInspectionScreen(orderId: state.pathParameters['orderId']!),
            ),
            GoRoute(
              path: 'parts',
              builder: (_, state) => PartsReplacementScreen(orderId: state.pathParameters['orderId']!),
              routes: [
                GoRoute(
                  path: ':partId',
                  builder: (_, state) => PartReplacementDetailScreen(
                    partId: state.pathParameters['partId']!,
                  ),
                ),
              ],
            ),
            GoRoute(
              path: 'notes',
              builder: (_, state) => ServiceNotesScreen(orderId: state.pathParameters['orderId']!),
            ),
            GoRoute(
              path: 'complete',
              builder: (_, state) => CompleteJobScreen(orderId: state.pathParameters['orderId']!),
            ),
            GoRoute(
              path: 'extra-work',
              builder: (_, state) => ExtraWorkRequestScreen(
                orderId: state.pathParameters['orderId']!,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
