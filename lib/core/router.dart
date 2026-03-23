import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/auth_screen.dart';
import '../features/home/main_screen.dart';
import '../features/home/home_screen.dart';
import '../features/jobs/jobs_screen.dart';
import '../features/ai/ai_chat_screen.dart'; // 👈 1. 퀴즈 대신 방금 만든 AI 챗 화면 import!
import '../features/community/community_screen.dart';
import '../features/profile/profile_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

final router = GoRouter(
  initialLocation: '/auth',
  navigatorKey: _rootNavigatorKey,
  routes: [
    GoRoute(
      path: '/auth',
      builder: (context, state) => const AuthScreen(),
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return MainScreen(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          routes: [GoRoute(path: '/home', builder: (context, state) => const HomeScreen())],
        ),
        StatefulShellBranch(
          routes: [GoRoute(path: '/jobs', builder: (context, state) => const JobsScreen())],
        ),
        // 🚀 2. 3번째 탭 길 안내를 퀴즈에서 AI 챗봇으로 변경!
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/ai', // 경로 이름도 깔끔하게 /ai로 변경
              builder: (context, state) => const AiChatScreen(), // AiChatScreen 연결!
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [GoRoute(path: '/community', builder: (context, state) => const CommunityScreen())],
        ),
        StatefulShellBranch(
          routes: [GoRoute(path: '/profile', builder: (context, state) => const ProfileScreen())],
        ),
      ],
    ),
  ],
);