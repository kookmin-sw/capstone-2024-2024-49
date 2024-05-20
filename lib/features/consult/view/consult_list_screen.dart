import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:luckymoon/data/Chat.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../data/User.dart';
import 'consult_list_item.dart';


class ConsultListScreen extends StatefulWidget {
  const ConsultListScreen({Key? key}) : super(key: key);

  @override
  _ConsultListScreenState createState() => _ConsultListScreenState();
}

class _ConsultListScreenState extends State<ConsultListScreen> {
  String _userId = "";
  List<Chat> _chats = [];

  @override
  void initState() {
    super.initState();
    _getUserId();
  }

  Future<void> _getUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userId');

    if (userId != null) {
      _userId = userId;
    }
    _fetchChats();
  }

  void _fetchChats() {
    FirebaseFirestore.instance.collection('chats')
        .where('counsellorId', isEqualTo: _userId)
        .orderBy('createdAt', descending: true)
        .get()
        .then((snapshot) {
      setState(() {
        _chats = snapshot.docs
            .map((doc) => Chat.fromJson(doc.data()))
            .toList();
      });
    }).catchError((error) {
      print('Error fetching chats: $error');
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: _chats.length,
      itemBuilder: (BuildContext context, int index) {
        Chat chat = _chats[index];
        Future<User> userFuture = FirebaseFirestore.instance
            .collection('users')
            .doc(chat.userId)
            .get()
            .then((doc) => User.fromJson(doc.data()!));

        Future<DocumentSnapshot> messageFuture = FirebaseFirestore.instance
            .collection('chats')
            .doc(chat.chatId)
            .collection('messages')
            .orderBy('timestamp', descending: true)
            .limit(1)
            .get()
            .then((snapshot) => snapshot.docs.first);

        return FutureBuilder(
            future: Future.wait([userFuture, messageFuture]),
            builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              }

              User user = snapshot.data![0];
              DocumentSnapshot messageDoc = snapshot.data![1];
              String lastMessage = messageDoc['text'];
              DateTime lastTimestamp = messageDoc['timestamp'].toDate();

              return ConsultListItem(
                user: user,
                chatId: chat.chatId!,
                createdAt: chat.createdAt,
                messageText: lastMessage,
                messageTime: lastTimestamp,
              );
            });
      },
    );
  }
}