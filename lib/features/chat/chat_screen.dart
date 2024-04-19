import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:luckymoon/core/logger.dart';
import 'package:luckymoon/data/Message.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:luckymoon/features/chat/cubit/chat_cubit.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/Counsellor.dart';
import 'chat_service.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late Counsellor counsellor;
  late String userId;
  final TextEditingController _messageController = TextEditingController();
  late List<Message> _messages = [];
  late ChatService chatService;
  late String chatRoomId;

  @override
  void initState() {
    super.initState();
    counsellor = context.read<ChatCubit>().getCounsellor();
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
        userId = userIdPref;
      });
    }
  }

  Future<void> _initChat() async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    // 채팅방 조회
    var chatQuery = await firestore.collection('chats')
        .where('counsellorId', isEqualTo: counsellor.userId)
        .where('userId', isEqualTo: userId)
        .limit(1)
        .get();

    if (chatQuery.docs.isEmpty) {
      // 채팅방이 존재하지 않으면 새로운 채팅방 문서를 생성
      DocumentReference chatRoomRef = await firestore.collection('chats').add({
        'counsellorId': counsellor.userId,
        'userId': userId,
      });

      // 새로 생성된 채팅방 ID
      chatRoomId = chatRoomRef.id;
      chatService = ChatService(chatRoomId);
      logger.d("=======> chatRoomId : $chatRoomId");

      // 채팅방에 추가할 초기 메시지 생성
      String currentDate = DateFormat('yyyy년 M월 d일 EEEE').format(DateTime.now());
      List<Message> initialMessages = [
        Message(sender: "system", text: currentDate, timestamp: DateTime.now()),
        Message(sender: "system", text: '${counsellor.nickname} 님의 상담소에 입장하셨습니다', timestamp: DateTime.now()),
      ];

      // Firestore에 초기 메시지들을 저장
      for (var message in initialMessages) {
        chatService.sendMessage("system", message.text);
      }

      setState(() {
        _messages.addAll(initialMessages);
      });
    } else {
      // 채팅방이 존재하는 경우 해당 채팅방의 메시지를 로드
      chatRoomId = chatQuery.docs.first.id;
      chatService = ChatService(chatRoomId);

      var messageStream = chatService.getMessages();
      messageStream.listen((messageData) {
        setState(() {
          _messages = messageData;
        });
      });
    }


  }

  void _sendMessage() {
    if (_messageController.text.isNotEmpty) {

      chatService.sendMessage("user", _messageController.text);

      setState(() {
        _messages.add(Message(sender: "user", text: _messageController.text, timestamp: DateTime.now()));
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
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Row(
                    mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (!isUser)
                        CircleAvatar(
                          radius: 24,
                          backgroundImage: counsellor.profileUrl != null && counsellor.profileUrl!.isNotEmpty ? NetworkImage(counsellor.profileUrl!) : null,
                          child: counsellor.profileUrl == null || counsellor.profileUrl!.isEmpty ? const Icon(Icons.person, size: 24) : null,
                        ),
                      if (!isUser)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 10),
                              child: Text(
                                counsellor.nickname,
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(top: 5, bottom: 5, left: isUser ? 10 : 5, right: isUser ? 5 : 10),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: isUser ? Colors.yellow[600] : Colors.grey[300],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                message.text,
                                style: const TextStyle(color: Colors.black),
                              ),
                            ),
                          ],
                        ),
                      if(isUser)
                        Container(
                          margin: EdgeInsets.only(top: isUser ? 5 : 20, bottom: 5, left: isUser ? 10 : 5, right: isUser ? 5 : 10),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: isUser ? Colors.yellow[600] : Colors.grey[300],
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