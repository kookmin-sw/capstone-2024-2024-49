import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:luckymoon/data/Counsellor.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'user_list_item.dart';

class UserListScreen extends StatefulWidget {
  const UserListScreen({super.key});

  @override
  _UserListScreenState createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  List<Counsellor> _counsellors = [];

  @override
  void initState() {
    super.initState();
    _fetchCounsellors();
  }

  Future<void> _fetchCounsellors() async {

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userId');

    FirebaseFirestore.instance.collection('counsellors')
        .where('userId', isNotEqualTo: userId)
        .get()
        .then((snapshot) {
      setState(() {
        _counsellors = snapshot.docs
            .map((doc) => Counsellor.fromJson(doc.data()))
            .toList();
      });
    }).catchError((error) {
      print('Error fetching counsellors: $error');
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: _counsellors.length,
      itemBuilder: (context, index) {
        return UserListItem(counsellor: _counsellors[index]);
      },
    );
  }

}