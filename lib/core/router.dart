import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/auth_screen.dart';
import '../features/home/main_screen.dart';
import '../features/home/home_screen.dart';
import '../features/jobs/jobs_screen.dart';
import '../features/quiz/quiz_screen.dart';
import '../features/community/community_screen.dart';
import '../features/profile/profile_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

final router = GoRouter(
  initialLocation: '/auth', // 초기 화면을 로그인 화면으로 설정
  navigatorKey: _rootNavigatorKey,
  routes: [
    // 🔐 로그인 화면 라우트 추가
    GoRoute(
      path: '/auth',
      builder: (context, state) => const AuthScreen(),
    ),
    
    // 메인 탭 구조 (로그인 성공 후 진입)
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return MainScreen(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/home',
              builder: (context, state) => const HomeScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/jobs',
              builder: (context, state) => const JobsScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/quiz',
              builder: (context, state) => const QuizScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/community',
              builder: (context, state) => const CommunityScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/profile',
              builder: (context, state) => const ProfileScreen(),
            ),
          ],
        ),
      ],
    ),
  ],
);
