import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:luckymoon/shared/blocs.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'config/routes/app_routes.dart';
import 'config/theme/app_theme.dart';
import 'firebase_options.dart';

bool isLoggedIn = false;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 로그인 상태 확인
  isLoggedIn = await checkLoginStatus();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocWidget(
      child: MaterialApp.router(
        title: '무꾸리',
        theme: theme(),
        debugShowCheckedModeBanner: false,
        routerConfig: appRouter,
      ),
    );
  }
}

Future<bool> checkLoginStatus() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  // 'isLoggedIn' 키로 저장된 로그인 상태 확인
  bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
  return isLoggedIn;
}