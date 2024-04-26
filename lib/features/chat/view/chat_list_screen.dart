import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:luckymoon/core/logger.dart';
import 'package:luckymoon/data/Chat.dart';
import 'package:luckymoon/data/Counsellor.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../cubit/chat_cubit.dart';
import 'chat_list_item.dart';


class ChatListScreen extends StatefulWidget {
  const ChatListScreen({Key? key}) : super(key: key);

  @override
  _ChatListScreenState createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
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
        .where('userId', isEqualTo: _userId)
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
        Future<Counsellor> counsellorFuture = FirebaseFirestore.instance
            .collection('counsellors')
            .doc(chat.counsellorId)
            .get()
            .then((doc) => Counsellor.fromJson(doc.data()!));

        Future<DocumentSnapshot> messageFuture = FirebaseFirestore.instance
            .collection('chats')
            .doc(chat.chatId)
            .collection('messages')
            .orderBy('timestamp', descending: true)
            .limit(1)
            .get()
            .then((snapshot) => snapshot.docs.first);

        return FutureBuilder(
            future: Future.wait([counsellorFuture, messageFuture]),
            builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              }

              Counsellor counsellor = snapshot.data![0];
              DocumentSnapshot messageDoc = snapshot.data![1];
              String lastMessage = messageDoc['text'];
              DateTime lastTimestamp = messageDoc['timestamp'].toDate();

              if (lastMessage.isEmpty) {
                lastMessage = messageDoc['image'];
              }

              return ChatListItem(
                counsellor: counsellor,
                messageText: lastMessage,
                messageTime: lastTimestamp,
              );
            });
      },
    );
  }
}