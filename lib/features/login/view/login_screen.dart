import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:luckymoon/config/theme/app_color.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/blank.dart';
import '../../../data/User.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isRememberMeChecked = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() async {
    final String email = _emailController.text.trim();
    final String password = _passwordController.text.trim();

    // Firestore에서 사용자 검색
    final collection = FirebaseFirestore.instance.collection('users');
    final querySnapshot = await collection
        .where('userId', isEqualTo: email)
        .where('password', isEqualTo: password)
        .get();

    // 일치하는 사용자가 있는지 확인
    if (querySnapshot.docs.isEmpty) {
      // 일치하는 사용자가 없을 경우
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('일치하는 회원정보가 없습니다.'))
      );
    } else {
      // Firestore 문서에서 User 객체 생성
      final userData = querySnapshot.docs.first.data();
      final User user = User.fromJson(userData);

      // SharedPreferences에 저장
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('userId', user.userId);
      await prefs.setString('nickname', user.nickname);
      await prefs.setBool('isLoggedIn', true);

      // 일치하는 사용자가 있을 경우 Home 화면으로 이동
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(""),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const FlutterLogo(size: 100),
              const Blank(0, 48),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: '아이디 입력',
                  hintText: '',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const Blank(0, 20),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: '비밀번호 입력',
                  hintText: '',
                  prefixIcon: Icon(Icons.lock),
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              Row(
                children: [
                  Checkbox(
                    value: _isRememberMeChecked,
                    onChanged: (bool? newValue) {
                      setState(() {
                        _isRememberMeChecked = newValue ?? false;
                      });
                    },
                  ),
                  const Text('로그인 상태 유지'),
                ],
              ),
              const Blank(0, 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorStyles.mainColor,
                  foregroundColor: Colors.white,
                  shadowColor: Colors.blueAccent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  minimumSize: const Size(double.infinity, 50),
                ),
                onPressed: _login,
                child: const Text('로그인'),
              ),
              const Blank(0, 20),
              InkWell(
                onTap: () {
                  context.push("/login/signup");
                },
                child: const Text(
                  '회원가입',
                  style: TextStyle(
                    decoration: TextDecoration.underline,
                    color: Colors.blue,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}