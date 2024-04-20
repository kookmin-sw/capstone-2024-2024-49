import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/board/board_screen.dart';
import '../../features/chat/view/chat_screen.dart';
import '../../features/home/view/home_screen.dart';
import '../../features/login/view/signup_screen.dart';
import '../../features/login/view/login_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../../main.dart';


final GlobalKey<NavigatorState> rootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'root');


GoRouter appRouter = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) {
        // 로그인 상태에 따라 HomeScreen 또는 LoginScreen 반환
        print(isLoggedIn);
        return isLoggedIn ? const HomeScreen() : const LoginScreen();
      },
    ),

    GoRoute(
        path: '/login',
        builder: (context, state) {
          return const LoginScreen();
        },
        routes: [
          GoRoute(
              path: 'signup',
              builder: (context, state) {
                return const SignUpScreen();
              }
          )
        ]
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) {
        // 로그인 상태에 따라 HomeScreen 또는 LoginScreen 반환
        return const HomeScreen();
      },
    ),
    GoRoute(
        path: '/board',
        builder: (context, state) {
          return const BoardScreen();
        }
    ),
    GoRoute(
        path: '/chat',
        builder: (context, state) {
          return const ChatScreen();
        }
    ),

    GoRoute(
        path: '/profile',
        builder: (context, state) {
          return const ProfileScreen();
        }
    ),
  ],
);