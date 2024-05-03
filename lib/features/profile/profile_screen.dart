import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:luckymoon/config/theme/app_color.dart';
import 'package:luckymoon/core/logger.dart';
import 'package:luckymoon/data/Counsellor.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/blank.dart';
import '../../data/User.dart';
import '../board/cubit/board_cubit.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String userId = "";
  String nickname = "";
  String? profileUrl = "";
  late Counsellor counsellor;
  bool isCounsellor = false;
  bool isLoading = false;
  late final TextEditingController _commentController = TextEditingController();

  // 사용자 정보를 가져오는 함수
  Future<void> _getUserInfo() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      String? id = prefs.getString('userId');
      if (id == null) {
        throw Exception('User ID not found in SharedPreferences');
      }

      var doc = await FirebaseFirestore.instance.collection('users').doc(id).get();
      var userData = doc.data();
      if (userData == null) {
        throw Exception('User data not found in Firestore');
      }

      // User 객체를 생성합니다.
      User user = User.fromJson(userData);

      // 상태를 업데이트합니다.
      setState(() {
        userId = user.userId;
        nickname = user.nickname;
        profileUrl = user.profileUrl;
        isCounsellor = user.isCounsellor;
      });

      if (isCounsellor) {
        _getCounsellor();
      }

    } catch (e) {
      print('Failed to fetch user info: $e');
    }
  }

  Future<void> _getCounsellor() async {

    FirebaseFirestore.instance.collection('counsellors')
        .where('userId', isEqualTo: userId)
        .get()
        .then((QuerySnapshot snapshot) {
      if (snapshot.docs.isNotEmpty) {
        setState(() {
          counsellor = Counsellor.fromJson(snapshot.docs.first.data() as Map<String, dynamic>);
        });
      } else {
        print('No counsellors found for the given userId.');
      }
    }).catchError((error) {
      print('Error fetching counsellors: $error');
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
      XFile? imageFile;
      final ImagePicker _picker = ImagePicker();

      // 상담자 코멘트 입력을 위한 다이얼로그
      // ignore: use_build_context_synchronously
      String? comment = await showDialog<String>(
        context: context,
        builder: (BuildContext context) {
          TextEditingController commentController = TextEditingController();
          return StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                title: const Text('상담사 정보 입력'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    IconButton(
                      icon: imageFile != null ? Image.file(File(imageFile!.path), height: 100) : const Icon(Icons.add_photo_alternate, size: 40),
                      onPressed: () async {
                        imageFile = await _picker.pickImage(source: ImageSource.gallery);
                        setState(() {});
                      },
                    ),
                    TextField(
                      controller: commentController,
                      decoration: const InputDecoration(hintText: "코멘트를 입력하세요"),
                    ),
                  ],
                ),
                actions: <Widget>[
                  TextButton(
                    onPressed: () => {
                      isLoading = true,
                      Navigator.pop(context, commentController.text)
                    },
                    child: const Text('확인'),
                  ),
                ],
              );
            },
          );
        },
      );

      if (comment != null && comment.isNotEmpty) {
        String imageUrl = '';
        if (imageFile != null) {
          // firebase storage 에 이미지 업로드 후 url 생성
          File file = File(imageFile!.path);
          try {
            final ref = FirebaseStorage.instance.ref().child('profileImages').child(userId);
            await ref.putFile(file);
            imageUrl = await ref.getDownloadURL();

            setState(() {
              profileUrl = imageUrl;
            });
          } catch (e) {
            isLoading = false;
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('이미지 업로드 실패: $e')));
          }
        }

        counsellor = Counsellor(
          userId: userId,
          nickname: nickname,
          comment: comment,
          chatCount: 0,
          notice: '$nickname님의 후기 게시판 입니다.',
          reviewCount: 0,
          profileUrl: imageUrl,
        );

        FirebaseFirestore.instance
            .collection('counsellors')
            .doc(userId)
            .set(counsellor.toJson())
            .then((value) {
          isLoading = false;
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('상담자로 등록됐습니다.')));
        }).catchError((error) {
          isLoading = false;
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('상담자 등록에 실패했습니다: $error')));
        });

        FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .update({'isCounsellor': true, 'profileUrl': imageUrl});


      }
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('잘못된 인증번호입니다.')));
    }
  }

  Future<void> _pickImage() async {

    final ImagePicker _picker = ImagePicker();

    final XFile? imageFile = await _picker.pickImage(source: ImageSource.gallery);

    setState(() {
      isLoading = true;
    });

    // 선택된 이미지를 Firestore에 업로드
    String imageUrl = '';
    if (imageFile != null) {
      // firebase storage 에 이미지 업로드 후 url 생성
      File file = File(imageFile!.path);
      try {
        final ref = FirebaseStorage.instance.ref().child('profileImages').child(userId);
        await ref.putFile(file);
        imageUrl = await ref.getDownloadURL();

        await FirebaseFirestore.instance
            .collection('counsellors')
            .doc(userId)
            .update({'profileUrl': imageUrl});

        setState(() {
          profileUrl = imageUrl;
          isLoading = false;
        });

      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('이미지 업로드 실패: $e')));
        setState(() {
          isLoading = false;
        });

      }
    }
  }

  void _showUpdateComment() {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (BuildContext context) {
        return SingleChildScrollView(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            padding: const EdgeInsets.only(top: 50, left: 16, right: 16, bottom: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: _commentController,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    labelText: counsellor.notice,
                  ),
                ),
                const Blank(0, 16),
                ElevatedButton(
                  onPressed: () {
                    _updateComment(_commentController.text);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    backgroundColor: Colors.pink,
                    foregroundColor: Colors.white,
                    fixedSize: const Size(100, 50),
                  ),
                  child: const Text('작성'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _updateComment(String comment) {

    // Firestore에 counsellor 컬렉션에 notice 업데이트
    FirebaseFirestore.instance.collection('counsellors').doc(userId).update({'comment': comment}).then((value) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('코멘트 수정 완료.')));

    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('코멘트 수정 실패.')));
    });


  }

  Widget _buildAccountSection() {
    return Row(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            image: profileUrl != null && profileUrl!.isNotEmpty
                ? DecorationImage(
              image: NetworkImage(profileUrl!),
              fit: BoxFit.cover,
            )
                : null,
            color: Colors.grey[300],
          ),
          child: profileUrl == null || profileUrl!.isEmpty
              ? const Icon(Icons.person, size: 30, color: Colors.white)
              : null,
        ),
        const Blank(20, 0),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(nickname ?? "", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text(userId ?? "", style: const TextStyle(fontSize: 14)),
            ],
          ),
        ),
        TextButton(
          onPressed: () async {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            await prefs.setBool('isLoggedIn', false);
            context.go('/login');
          },
          child: const Text(
            '로그아웃',
            style: TextStyle(
              decoration: TextDecoration.underline,
              color: Colors.blueAccent,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCounsellorSection() {
    if (isCounsellor == true) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
            child: Text('상담자 메뉴', style: TextStyle(fontSize: 16, color: Colors.white)),
          ),
          InkWell(
            onTap: () {
              _showUpdateComment();
            },
            child: const Padding(
              padding: EdgeInsets.only(left: 20.0, right: 20.0, top: 10, bottom: 10),
              child: Text('코멘트 변경', style: TextStyle(fontSize: 16, color: Colors.black)),
            ),
          ),
          InkWell(
            onTap: () {
              _pickImage();
            },
            child: const Padding(
              padding: EdgeInsets.only(left: 20.0, right: 20.0, top: 10, bottom: 10),
              child: Text('프로필 이미지 변경', style: TextStyle(fontSize: 16, color: Colors.black)),
            ),
          ),
          InkWell(
            onTap: () {
              context.read<BoardCubit>().setCounsellor(counsellor);
              context.push('/board');
            },
            child: const Padding(
              padding: EdgeInsets.only(left: 20.0, right: 20.0, top: 10, bottom: 10),
              child: Text('내 후기 게시판 관리', style: TextStyle(fontSize: 16, color: Colors.black)),
            ),
          ),
        ],
      );
    } else {
      return Padding(
        padding: const EdgeInsets.all(20.0),
        child: ElevatedButton.icon(
          icon: const Icon(Icons.verified_user, size: 24),
          label: const Text('상담자 인증', style: TextStyle(fontSize: 16)),
          onPressed: () => becomeCounsellor(context, userId!),
          style: ElevatedButton.styleFrom(
            backgroundColor: ColorStyles.mainColor,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 50),
          ),
        ),
      );
    }
  }



  @override
  Widget build(BuildContext context) {
    _getUserInfo();

    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        color: ColorStyles.backgroundColor,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: _buildAccountSection(),
              ),
              const Divider(color: Color(0xFFFFFFFF), thickness: 10),
              Padding(
                padding: const EdgeInsets.all(0.0),
                child: _buildCounsellorSection(),
              ),
              const Divider(color: Color(0xFFFFFFFF), thickness: 10),
              if (isLoading) // 로딩 인디케이터 표시
                const Center(child: CircularProgressIndicator())
            ],
          ),
        ),
      )
    );
  }
}