import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../views/splash_view.dart';
import '../views/auth_shell.dart';
import '../views/main_shell.dart';
import '../views/home_view.dart';
import '../views/avatar_view.dart';
import '../views/interactive_quran_view.dart';
import '../views/compass_view.dart';
import '../views/community_feed_view.dart';
import '../views/profile_view.dart';
import '../services/auth_service.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authService = ref.watch(authServiceProvider);
  
  return GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashView(),
      ),
      GoRoute(
        path: '/auth',
        builder: (context, state) => const AuthShell(),
        routes: [
          GoRoute(
            path: '/login',
            builder: (context, state) => const AuthShell(),
          ),
          GoRoute(
            path: '/signup',
            builder: (context, state) => const AuthShell(),
          ),
        ],
      ),
      GoRoute(
        path: '/main',
        builder: (context, state) => const MainShell(),
        routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) => const HomeView(),
          ),
          GoRoute(
            path: '/quran',
            builder: (context, state) => const InteractiveQuranView(),
          ),
          GoRoute(
            path: '/compass',
            builder: (context, state) => const CompassView(),
          ),
          GoRoute(
            path: '/siraj',
            builder: (context, state) => const AskSirajView(),
          ),
          GoRoute(
            path: '/community',
            builder: (context, state) => const CommunityFeedView(),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfileView(),
          ),
        ],
      ),
    ],
    redirect: (context, state) {
      final user = authService.currentUser;
      final isLoggedIn = user != null;
      final isOnAuthPage = state.fullPath?.startsWith('/auth') ?? false;
      final isOnSplash = state.fullPath == '/';

      if (isOnSplash) {
        return null; // Allow splash screen
      }

      if (!isLoggedIn && !isOnAuthPage) {
        return '/auth';
      }

      if (isLoggedIn && isOnAuthPage) {
        return '/main/home';
      }

      return null;
    },
  );
});

