import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:luckymoon/data/Counsellor.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'UserListItem.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Counsellor> _counsellors = [];
  String _nickname = "";

  @override
  void initState() {
    super.initState();
    _fetchCounsellors();
  }

  void _fetchCounsellors() {
    FirebaseFirestore.instance.collection('counsellors').get().then((snapshot) {
      setState(() {
        _counsellors = snapshot.docs
            .map((doc) => Counsellor.fromJson(doc.data()))
            .toList();

        print("counsellors size : ${_counsellors.length}");
      });
    }).catchError((error) {
      print('상담자 정보를 가져오는 중 오류 발생: $error');
    });
  }

  Future<void> _getNickname() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? nickname = prefs.getString('nickname');
    if (nickname != null) {
      setState(() {
        _nickname = nickname;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    _getNickname();

    return Scaffold(
      appBar: AppBar(
        title: const Text('상담자 리스트'),
        actions: <Widget>[
          TextButton.icon(
            icon: const Icon(Icons.account_box_rounded),
            label: Text(_nickname), // 텍스트 설정
            onPressed: () {
              context.push('/profile'); // 버튼 클릭 시 수행할 동작
            },
          )
        ],
      ),
      body: ListView.builder(
        itemCount: _counsellors.length,
        itemBuilder: (BuildContext context, int index) {
          var counsellor = _counsellors[index];
          return UserListItem(
            counsellor: counsellor,
          );
        },
      ),
    );
  }
}
