import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:luckymoon/core/logger.dart';
import 'package:luckymoon/data/Message.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:luckymoon/features/chat/cubit/chat_cubit.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../data/Counsellor.dart';
import '../../../data/User.dart';
import '../chat_service.dart';
import '../cubit/consult_cubit.dart';

class ConsultScreen extends StatefulWidget {
  const ConsultScreen({Key? key}) : super(key: key);

  @override
  _ConsultScreenState createState() => _ConsultScreenState();
}

class _ConsultScreenState extends State<ConsultScreen> {
  late User user;
  late String counsellorId;
  final TextEditingController _messageController = TextEditingController();
  late List<Message> _messages = [];
  late ChatService chatService;
  late String chatRoomId;

  @override
  void initState() {
    super.initState();
    user = context.read<ConsultCubit>().getUser();
    initializeChat();
  }

  Future<void> initializeChat() async {
    await _getUser();
    await _initChat();
  }

  Future<void> _getUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userIdPref = prefs.getString('userId');
    if (userIdPref != null) {
      setState(() {
        counsellorId = userIdPref;
      });
    }
  }

  Future<void> _initChat() async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    // 채팅방 조회
    var chatQuery = await firestore.collection('chats')
        .where('userId', isEqualTo: user.userId)
        .where('counsellorId', isEqualTo: counsellorId)
        .where('isClosed', isEqualTo: false)
        .limit(1)
        .get();

    chatRoomId = chatQuery.docs.first.id;
    chatService = ChatService(chatRoomId);

    var messageStream = chatService.getMessages();
    messageStream.listen((messageData) {
      setState(() {
        _messages = messageData;
      });
    });
  }

  void _sendMessage() {
    if (_messageController.text.isNotEmpty) {

      chatService.sendMessage("counsellor", _messageController.text);

      setState(() {
        _messages.add(Message(sender: "counsellor", text: _messageController.text, timestamp: DateTime.now()));
        _messageController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('채팅'),
        backgroundColor: Colors.yellow[600],
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                bool isUser = message.sender == 'user';

                if (message.sender == 'system') {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Text(message.text, style: const TextStyle(fontSize: 14, color: Colors.grey)),
                    ),
                  );
                }

                return Align(
                  alignment: isUser ? Alignment.centerLeft : Alignment.centerRight,
                  child: Row(
                    mainAxisAlignment: isUser ? MainAxisAlignment.start : MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (isUser)
                        const CircleAvatar(
                          radius: 24,
                          backgroundImage: null,
                          child: Icon(Icons.person, size: 24),
                        ),
                      if (isUser)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 10),
                              child: Text(
                                user.nickname,
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.only(top: 5, bottom: 5, left:  5, right: 10),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                message.text,
                                style: const TextStyle(color: Colors.black),
                              ),
                            ),
                          ],
                        ),
                      if(!isUser)
                        Container(
                          margin: const EdgeInsets.only(top: 5, bottom: 5, left: 10, right: 5),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.yellow[600],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            message.text,
                            style: const TextStyle(color: Colors.black),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: '메시지 입력',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _sendMessage,
                  icon: const Icon(Icons.send),
                  color: Colors.yellow[600],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}