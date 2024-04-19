import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:luckymoon/features/chat/cubit/chat_cubit.dart';

import '../../data/Counsellor.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late Counsellor counsellor;
  final TextEditingController _messageController = TextEditingController();
  List<Map<String, dynamic>> _messages = [];

  @override
  void initState() {
    super.initState();
    counsellor = context.read<ChatCubit>().getCounsellor();
    _initChat();
  }

  void _initChat() {
    // 초기 메시지와 상담자 인사 추가
    String currentDate = DateFormat('yyyy년 M월 d일 EEEE').format(DateTime.now());
    _messages.add({
      'type': 'date',
      'text': currentDate,
    });
    _messages.add({
      'type': 'system',
      'text': '${counsellor.nickname} 님의 상담소에 입장하셨습니다',
    });
    _messages.add({
      'type': 'message',
      'sender': 'counsellor',
      'text': '안녕하세요',
    });
  }

  void _sendMessage() {
    if (_messageController.text.isNotEmpty) {
      setState(() {
        _messages.add({
          'type': 'message',
          'sender': 'user',
          'text': _messageController.text,
        });
        _messageController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('채팅'),
        backgroundColor: Colors.yellow[600],
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                bool isUser = message['sender'] == 'user';

                if (message['type'] == 'date' || message['type'] == 'system') {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.all(8),
                      child: Text(message['text'],
                          style: TextStyle(fontSize: 14, color: Colors.grey)),
                    ),
                  );
                }

                return Align(
                  alignment:
                      isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Row(
                    mainAxisAlignment: isUser
                        ? MainAxisAlignment.end
                        : MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (!isUser)
                        CircleAvatar(
                          radius: 24,
                          backgroundImage: counsellor.profileUrl != null &&
                                  counsellor.profileUrl!.isNotEmpty
                              ? NetworkImage(counsellor.profileUrl!)
                              : null,
                          child: counsellor.profileUrl == null ||
                                  counsellor.profileUrl!.isEmpty
                              ? const Icon(Icons.person, size: 24)
                              : null,
                        ),
                      if (!isUser)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(left: 10),
                              child: Text(
                                counsellor.nickname,
                                style: TextStyle(
                                    fontSize: 13, fontWeight: FontWeight.bold),
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(
                                  top: 5,
                                  bottom: 5,
                                  left: isUser ? 10 : 5,
                                  right: isUser ? 5 : 10),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: isUser
                                    ? Colors.yellow[600]
                                    : Colors.grey[300],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                message['text'],
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                          ],
                        ),
                      if (isUser)
                        Container(
                          margin: EdgeInsets.only(
                              top: isUser ? 5 : 20,
                              bottom: 5,
                              left: isUser ? 10 : 5,
                              right: isUser ? 5 : 10),
                          padding:
                              EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color:
                                isUser ? Colors.yellow[600] : Colors.grey[300],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            message['text'],
                            style: TextStyle(color: Colors.black),
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
                  icon: Icon(Icons.send),
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
