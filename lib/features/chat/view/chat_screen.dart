import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:luckymoon/config/theme/app_color.dart';
import 'package:luckymoon/core/logger.dart';
import 'package:luckymoon/data/Message.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:luckymoon/features/chat/cubit/chat_cubit.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image/image.dart' as Img;


import '../../../core/blank.dart';
import '../../../data/Counsellor.dart';
import '../chat_service.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late Counsellor counsellor;
  late String userId;
  final TextEditingController _messageController = TextEditingController();
  late ScrollController _scrollController;
  late List<Message> _messages = [];
  late ChatService chatService;
  late String chatRoomId;
  bool isLoading = false;

  String name = "";
  String gender = "남";
  int age = 0;
  int year = 0;
  int month = 0;
  int day = 0;

  @override
  void initState() {
    super.initState();
    counsellor = context.read<ChatCubit>().getCounsellor();
    _scrollController = ScrollController();
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
        .where('isClosed', isEqualTo: false)
        .limit(1)
        .get();

    if (chatQuery.docs.isEmpty) {
      // 채팅방이 존재하지 않으면 새로운 채팅방 문서를 생성
      DocumentReference chatRoomRef = await firestore.collection('chats').add({
        'counsellorId': counsellor.userId,
        'userId': userId,
        'isClosed': false,
      });

      // 새로 생성된 채팅방 ID로 chatId 필드 업데이트
      chatRoomId = chatRoomRef.id;
      await chatRoomRef.update({'chatId': chatRoomId});

      chatService = ChatService(chatRoomId);
      logger.d("=======> chatRoomId : $chatRoomId");

      // 채팅방에 추가할 초기 메시지 생성 및 보내기
      _initializeChatMessages(counsellor, chatService);
    } else {
      // 채팅방이 존재하는 경우 해당 채팅방의 메시지를 로드
      chatRoomId = chatQuery.docs.first.id;
      chatService = ChatService(chatRoomId);
    }

    var messageStream = chatService.getMessages();
    messageStream.listen((messageData) {
      setState(() {
        _messages = messageData;
        //_scrollToBottom();

        Future.delayed(const Duration(milliseconds: 10), () {
          _scrollToBottom();
        });
      });
    });
  }

  void _initializeChatMessages(Counsellor counsellor, ChatService chatService) {
    String currentDate = DateFormat('yyyy년 M월 d일 EEEE').format(DateTime.now());
    List<Message> initialMessages = [
      Message(sender: "system", text: currentDate, timestamp: DateTime.now()),
      Message(sender: "system", text: '${counsellor.nickname} 님의 상담소에 입장하셨습니다', timestamp: DateTime.now()),
    ];

    // Firestore에 초기 메시지들을 저장
    for (var message in initialMessages) {
      chatService.sendMessage("system", message.text!);
    }

    setState(() {
      _messages.addAll(initialMessages);
    });
  }

  void _sendFormMessage() {

    var message = Message(sender: "system", text: "내담자가 입력폼 작성을 완료했습니다.", timestamp: DateTime.now());
    chatService.sendMessage("system", message.text!);

    setState(() {
      _messages.add(message);
    });
  }

  void _sendMessage() {
    if (_messageController.text.isNotEmpty) {

      chatService.sendMessage("user", _messageController.text);

      setState(() {
        _messages.add(Message(sender: "user", text: _messageController.text, timestamp: DateTime.now()));
        _messageController.clear();
      });

      _scrollToBottom();
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
      File resizedFile = await File("${imageFile.path}_resized").writeAsBytes(resizedImageData);



      // firebase storage 에 이미지 업로드 후 url 생성
      File file = File(resizedFile!.path);
      try {
        final ref = FirebaseStorage.instance.ref().child('chatImages').child(imageFile!.path);
        await ref.putFile(file);
        imageUrl = await ref.getDownloadURL();

        chatService.sendImage("user", imageUrl);

      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('이미지 업로드 실패: $e')));
      }
    }

    if (imageUrl != null) {
      setState(() {
        _messages.add(
            Message(sender: "user", text: "", image: imageUrl, timestamp: DateTime.now())
        );
        isLoading = false;
      });

      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  void _showBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {

        return StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
          return Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const Blank(0, 20),
                const Text("상담 폼 입력", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const Blank(0, 50),
                Row(
                  children: [
                    const Text("이름 : ", style: TextStyle(fontSize: 18)),
                    const Blank(55, 0),
                    Expanded(
                      flex: 1,
                      child: TextField(
                        keyboardType: TextInputType.text,
                        decoration: const InputDecoration(
                            labelText: '',
                            border: OutlineInputBorder()
                        ),
                        onChanged: (value) {
                          if (value.isNotEmpty) {
                            try {
                              setState(() => name = value);
                            } catch (e) {
                              print("숫자만 입력해주세요.");
                            }
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const Blank(0, 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const Text("성별 : ", style: TextStyle(fontSize: 18)),
                    const Blank(55, 0),
                    Row(
                      children: [
                        Radio<String>(
                          value: "남",
                          groupValue: gender,
                          onChanged: (String? value) {
                            setState(() => gender = value!);
                          },
                        ),
                        const Text('남'),
                      ],
                    ),
                    const Blank(20, 0),
                    Row(
                      children: [
                        Radio<String>(
                          value: "여",
                          groupValue: gender,
                          onChanged: (String? value) {
                            setState(() => gender = value!);
                          },
                        ),
                        const Text('여'),
                      ],
                    ),
                  ],
                ),
                const Blank(0, 15),
                Row(
                  children: [
                    const Text("나이 : ", style: TextStyle(fontSize: 18)),
                    const Blank(55, 0),
                    Expanded(
                      flex: 1,
                      child: TextField(
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: '',
                          border: OutlineInputBorder()
                        ),
                        onChanged: (value) {
                          if (value.isNotEmpty) {
                            try {
                              setState(() => age = int.parse(value));
                            } catch (e) {
                              print("숫자만 입력해주세요.");
                            }
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const Blank(0, 15),
                Row(
                  children: [
                    const Text("생년월일 : ", style: TextStyle(fontSize: 18)),
                    const Blank(20, 0),
                    Expanded(
                      flex: 1,
                      child: TextField(
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: '년도',
                          border: OutlineInputBorder()
                        ),
                        onChanged: (value) {
                          if (value.isNotEmpty) {
                            try {
                              setState(() => year = int.parse(value));
                            } catch (e) {
                              print("숫자만 입력해주세요.");
                            }
                          }
                        },
                      ),
                    ),
                    const Blank(10, 0),
                    Expanded(
                      flex: 1,
                      child: TextField(
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: '월',
                          border: OutlineInputBorder()
                        ),
                        onChanged: (value) {
                          if (value.isNotEmpty) {
                            try {
                              setState(() => month = int.parse(value));
                            } catch (e) {
                              print("숫자만 입력해주세요.");
                            }
                          }
                        },
                      ),
                    ),
                    const Blank(10, 0),
                    Expanded(
                      flex: 1,
                      child: TextField(
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: '일',
                          border: OutlineInputBorder()
                        ),
                        onChanged: (value) {
                          if (value.isNotEmpty) {
                            try {
                              setState(() => day = int.parse(value));
                            } catch (e) {
                              print("숫자만 입력해주세요.");
                            }
                          }
                        },
                      ),
                    ),
                  ],
                ),

                const Blank(0, 40),
                Align(
                  alignment: Alignment.bottomRight,
                  child: ElevatedButton(
                    onPressed: () {
                      logger.e("date time : $year.$month.$day");
                      DateTime date = DateTime(year, month, day);
                      if (date.year == year && date.month == month && date.day == day) {

                        String consultForm = "$name,$gender,$age,$year,$month,$day";
                        _saveConsultForm(consultForm);
                        _sendFormMessage();

                        Navigator.pop(context);
                        _sendMessage();
                      } else {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('유효한 값을 입력해주세요.')));
                      }
                    },
                    style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(ColorStyles.mainColor),
                        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                            const RoundedRectangleBorder(
                              borderRadius: BorderRadius.zero,
                            )
                        )
                    ),
                    child: const Text('확인', style: TextStyle(fontSize: 15, color: Colors.white)),
                  ),
                ),
              ],
            ),
          );
        });
      },
    );
  }

  void _saveConsultForm(String consultForm) async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    DocumentReference chatRoomRef = firestore.collection('chats').doc(chatRoomId);
    await chatRoomRef.update({
      'consultForm': consultForm, 
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('내담자 채팅방'),
        backgroundColor: Colors.yellow[600],
        actions: <Widget>[
          Container(
            margin: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.description, color: Colors.black),
              onPressed: () {
                _showBottomSheet(context);
              },
            ),
          ),
        ],
      ),
      body: Container(
        color: ColorStyles.messageColor,
        child: Column(
          children: <Widget>[
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[index];
                  bool isUser = message.sender == 'user';

                  if (message.sender == 'system') {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Text(message.text!, style: const TextStyle(fontSize: 14, color: Colors.white)),
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
                              if (message.text != null)
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
                              if (message.text.isEmpty && message.image != null)
                                Container(
                                  margin: const EdgeInsets.only(top: 5, bottom: 5, left: 5, right: 10),
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: ConstrainedBox(
                                    constraints: const BoxConstraints(
                                      maxWidth: 300,
                                    ),
                                    child: Image.network(
                                      message.image!,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        if(isUser)
                          Container(
                            margin: const EdgeInsets.only(top: 5, bottom: 5, left: 10, right: 5),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.yellow[600],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(
                                maxWidth: 300,
                              ),
                              child: message.text.isNotEmpty ?
                              Text(
                                message.text,
                                style: const TextStyle(color: Colors.black),
                              ) :
                              (message.image != null ?
                              Image.network(
                                message.image!,
                                fit: BoxFit.cover,
                              ) :
                              const Text("No content")
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
            if (isLoading)
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
      )
    );
  }
}