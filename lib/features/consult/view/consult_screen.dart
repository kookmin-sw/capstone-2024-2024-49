import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:luckymoon/core/logger.dart';
import 'package:luckymoon/data/Message.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:luckymoon/features/chat/cubit/chat_cubit.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image/image.dart' as Img;

import '../../../data/Counsellor.dart';
import '../../../data/User.dart';
import '../../chat/chat_service.dart';
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
  bool isLoading = false;

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

  Future<void> _pickImage() async {

    final ImagePicker _picker = ImagePicker();

    final XFile? imageFile = await _picker.pickImage(source: ImageSource.gallery);

    setState(() {
      isLoading = true;
    });

    logger.e("============> imageFile $imageFile");
    // 선택된 이미지를 Firestore에 업로드
    String imageUrl = '';
    if (imageFile != null) {
      // 파일에서 이미지 데이터 읽기
      Uint8List imageData = await imageFile.readAsBytes();
      Img.Image? originalImage = Img.decodeImage(imageData);

      // 이미지 너비를 300px로 고정하고 높이를 자동 조정
      int width = 300;
      double aspectRatio = originalImage!.width / originalImage.height;
      int height = (width / aspectRatio).round();

      Img.Image resizedImage = Img.copyResize(originalImage, width: width, height: height);

      // 조정된 이미지를 새 파일로 저장
      List<int> resizedImageData = Img.encodeJpg(resizedImage);
      File resizedFile = await File(imageFile.path).writeAsBytes(resizedImageData);



      // firebase storage 에 이미지 업로드 후 url 생성
      File file = File(resizedFile!.path);
      try {
        final ref = FirebaseStorage.instance.ref().child('chatImages').child(imageFile!.path);
        await ref.putFile(file);
        imageUrl = await ref.getDownloadURL();

        chatService.sendImage("counsellor", imageUrl);

      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('이미지 업로드 실패: $e')));
      }
    }

    if (imageUrl != null) {
      setState(() {
        _messages.add(
            Message(sender: "counsellor", text: "", image: imageUrl, timestamp: DateTime.now())
        );
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('상담사 채팅방'),
        backgroundColor: const Color(0xFF228B22),
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
                      child: Text(message.text!, style: const TextStyle(fontSize: 14, color: Colors.grey)),
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
                            if (message.text.isNotEmpty) // 메시지의 텍스트가 있는 경우 텍스트를 보여줌
                              Container(
                                margin: const EdgeInsets.only(top: 5, bottom: 5, left: 5, right: 10),
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  message.text!,
                                  style: const TextStyle(color: Colors.black),
                                ),
                              ),
                            if (message.text.isEmpty && message.image != null) // 이미지 URL이 있는 경우 이미지를 보여줌
                              Container(
                                margin: const EdgeInsets.only(top: 5, bottom: 5, left: 5, right: 10),
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: ConstrainedBox(
                                  constraints: BoxConstraints(
                                    maxWidth: 300, // 최대 너비 300px
                                  ),
                                  child: Image.network(
                                    message.image!,
                                    fit: BoxFit.cover, // 이미지를 컨테이너에 맞게 조정
                                  ),
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
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: 300, // 최대 너비 300px
                            ),
                            child: message.text.isNotEmpty ?
                            Text(
                              message.text,
                              style: const TextStyle(color: Colors.black),
                            ) :
                            (message.image != null ?
                            Image.network(
                              message.image!,
                              fit: BoxFit.cover, // 이미지를 컨테이너에 맞게 조정
                            ) :
                            const Text("No content") // 텍스트와 이미지 모두 없는 경우 대체 텍스트 표시
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
          if (isLoading) // 로딩 인디케이터 표시
            const Center(child: CircularProgressIndicator()),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: <Widget>[
                IconButton(
                  onPressed: () {
                    _pickImage();
                  },
                  icon: const Icon(Icons.attach_file),
                  color: Colors.black,
                ),
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
                  color: Colors.black,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}