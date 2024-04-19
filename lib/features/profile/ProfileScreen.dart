import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:luckymoon/data/Counsellor.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/blank.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String userId = "";
  String nickname = "";
  String? profileUrl = "";

  // 사용자 정보를 가져오는 함수
  Future<void> _getUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      userId = prefs.getString('userId')!;
      nickname = prefs.getString('nickname')!;
      profileUrl = prefs.getString('profileUrl');
    });
  }

  void becomeCounsellor(BuildContext context, String currentUserId) async {
    // 인증번호 입력을 위한 다이얼로그
    String? certificationCode = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        String inputCode = '';
        return AlertDialog(
          title: const Text('인증번호 입력'),
          content: TextField(
            onChanged: (value) => inputCode = value,
            decoration: const InputDecoration(hintText: "인증번호를 입력하세요"),
            keyboardType: TextInputType.number, // 숫자만 입력
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly
            ], // 숫자만 입력되도록 필터
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context, inputCode),
              child: const Text('확인'),
            ),
          ],
        );
      },
    );

    // 인증번호 검증
    if (certificationCode != null && certificationCode == '0000') {
      // 상담자 코멘트 입력을 위한 다이얼로그
      String? comment = await showDialog<String>(
        context: context,
        builder: (BuildContext context) {
          TextEditingController commentController = TextEditingController();
          return AlertDialog(
            title: const Text('상담자 코멘트 입력'),
            content: TextField(
              controller: commentController,
              decoration: const InputDecoration(hintText: "코멘트를 입력하세요"),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.pop(context, commentController.text),
                child: const Text('확인'),
              ),
            ],
          );
        },
      );

      if (comment != null && comment.isNotEmpty) {
        // User 객체 생성
        final counsellor = Counsellor(
          userId: userId,
          nickname: nickname,
          comment: comment,
          chatCount: 0,
          reviewCount: 0,
        );

        final counsellorJson = counsellor.toJson();

        FirebaseFirestore.instance
            .collection('counsellors')
            .doc(userId)
            .set(counsellorJson)
            .then((value) {
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text('상담자로 등록됐습니다.')));
        }).catchError((error) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('상담자 등록에 실패했습니다: $error')));
        });
      }
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('잘못된 인증번호입니다.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    _getUserInfo();

    return Scaffold(
      appBar: AppBar(
        title: Text('내정보'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          // 프로필 이미지, 아이디, 닉네임 표시
          CircleAvatar(
            radius: 50,
            backgroundImage: profileUrl != null && profileUrl!.isNotEmpty
                ? NetworkImage(profileUrl!)
                : null,
            child: profileUrl == null || profileUrl!.isEmpty
                ? const Icon(Icons.person, size: 40)
                : null,
          ),
          const Blank(0, 8),
          Center(child: Text(userId)),
          Center(child: Text(nickname)),
          const Blank(0, 16),
          ElevatedButton(
            child: const Text('상담자 인증'),
            onPressed: () {
              becomeCounsellor(context, userId);
            },
          ),
          ElevatedButton(
            child: const Text('로그아웃'),
            onPressed: () async {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              await prefs.setBool('isLoggedIn', false);
              context.go('/login');
            },
          ),
        ],
      ),
    );
  }
}
