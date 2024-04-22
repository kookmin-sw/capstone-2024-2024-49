import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/blank.dart';
import '../../../data/User.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _userIdController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  bool _agreementChecked = false;

  @override
  void dispose() {
    _userIdController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _signUp() async {
    final String userId = _userIdController.text.trim();
    final String password = _passwordController.text.trim();
    final String confirmPassword = _confirmPasswordController.text.trim();
    final String nickname = _nameController.text.trim();

    if (userId.isEmpty || password.isEmpty || nickname.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('모두 입력해주세요.')));
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('비밀번호가 일치하지 않습니다. 다시 입력하세요.')));
      return;
    }

    // User 객체 생성
    final user = User(
      userId: userId,
      password: password,
      nickname: nickname,
      isCounsellor: false
    );

    final userJson = user.toJson();

    FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .set(userJson)
        .then((value) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('회원가입에 성공 했습니다.')));
      context.go('/login');
    }).catchError((error) {
      print('Failed to add user: $error');
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('회원가입에 실패했습니다: $error')));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('회원가입'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            TextField(
              controller: _userIdController,
              decoration: const InputDecoration(
                labelText: '아이디 *',
                hintText: '영문, 숫자, _ 만 입력가능. 최소 3자 이상',
              ),
            ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: '비밀번호 *',
                hintText: '비밀번호를 입력하세요.',
              ),
              obscureText: true,
            ),
            TextField(
              controller: _confirmPasswordController,
              decoration: const InputDecoration(
                labelText: '비밀번호 확인 *',
                hintText: '비밀번호를 한 번 더 입력하세요.',
              ),
              obscureText: true,
            ),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: '닉네임 *',
                hintText: '닉네임을 입력하세요',
              ),
            ),
            Row(
              children: [
                Checkbox(
                  value: _agreementChecked,
                  onChanged: (bool? value) {
                    setState(() {
                      _agreementChecked = value ?? false;
                    });
                  },
                ),
                Expanded(
                  child: Text(
                    '사용자약관 및 개인정보처리방침에 동의합니다.',
                    style: Theme.of(context).textTheme.subtitle1,
                  ),
                ),
              ],
            ),
            const Blank(0, 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: _agreementChecked ? _signUp : null,
              child: const Text('동의하고 회원가입', style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}