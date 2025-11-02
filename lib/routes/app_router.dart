import 'package:aplikasi_dua/screen/auth/login_screen.dart';
import 'package:aplikasi_dua/screen/auth/registrasi_screen.dart';
import 'package:aplikasi_dua/screen/landing/obrolan/detail.dart';
import 'package:aplikasi_dua/screen/landing/obrolan/search_user.dart';
import 'package:aplikasi_dua/screen/landing/pengaturan/profile.dart';
import 'package:aplikasi_dua/screen/splash/index.dart';
import 'package:aplikasi_dua/screen/widget/app_layout.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

final GoRouter router = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(path: '/splash', builder: (context, state) => const SplashScreen()),
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegistrasiScreen(),
    ),
    GoRoute(path: '/home', builder: (context, state) => const AppLayout()),
    GoRoute(
      path: '/chat-detail/:chatId',
      builder: (context, state) {
        final chatId = state.pathParameters['chatId']!;
        final chatData = state.extra as Map<String, dynamic>?;
        return DetailScreen(chatId: chatId, chatData: chatData);
      },
    ),
    GoRoute(
      path: '/search-user',
      builder: (context, state) => const SearchUserScreen(),
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state) => const ProfileScreen(),
    ),
  ],
);
