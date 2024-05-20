import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:luckymoon/config/theme/app_color.dart';
import 'package:luckymoon/core/logger.dart';
import 'package:luckymoon/data/Message.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/blank.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image/image.dart' as Img;
import 'package:klc/klc.dart';

import '../../../data/User.dart';
import '../../chat/chat_service.dart';
import '../cubit/consult_cubit.dart';

final List<String> zodiac = ['쥐', '소', '호랑이', '토끼', '용', '뱀', '말', '양', '원숭이', '닭', '개', '돼지'];
final List<String> destiny = ['천귀', '천액', '천권', '천파', '천간', '천문', '천복', '천역', '천고', '천인', '천예', '천수'];
final List<String> days = ['수', '토', '목', '목', '토', '화', '화', '토', '금', '금', '토', '수'];

class ConsultScreen extends StatefulWidget {
  const ConsultScreen({Key? key}) : super(key: key);

  @override
  _ConsultScreenState createState() => _ConsultScreenState();
}

class _ConsultScreenState extends State<ConsultScreen> {
  late User user;
  late String counsellorId;
  late String chatId;
  final TextEditingController _messageController = TextEditingController();
  late ScrollController _scrollController;
  late List<Message> _messages = [];
  late ChatService chatService;
  late String chatRoomId;
  bool isClosed = false;
  bool isLoading = false;
  bool isShowConsultForm = false;
  bool isShowConsultDetail = false;

  // 상담폼 value
  var name = "";
  var gender = "";
  var age = "";
  var ddi = "";
  var lunarYear = 0;
  var lunarMonth = 0;
  var lunarDay = 0;
  var destiny1 = "";
  var day1 = "";
  var destiny2 = "";
  var day2 = "";
  var destiny3 = "";
  var day3 = "";

  @override
  void initState() {
    super.initState();
    chatId = context.read<ConsultCubit>().getChatId();
    user = context.read<ConsultCubit>().getUser();
    _scrollController = ScrollController();
    initializeChat();
  }

  Future<void> initializeChat() async {
    await _getUser();
    await _initChat();
    _getConsultForm();
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

    var chatQuery = await FirebaseFirestore.instance.collection('chats')
        .doc(chatId)
        .get();

    chatService = ChatService(chatId);

    Timestamp createdAt = chatQuery['createdAt'] as Timestamp;

    final duration = DateTime.now().difference(createdAt.toDate());


    // 20분 넘었으면 대화창 입력 불가
    if (duration.inMinutes >= 20) {
      setState(() {
        isClosed = true;
      });
    }

    var messageStream = chatService.getMessages();
    messageStream.listen((messageData) {
      setState(() {
        _messages = messageData;

        if (_messages.last.text.contains("내담자") && _messages.last.sender == "system") {
          _getConsultForm();
        } else if (_messages.last.text.contains("종료되었습니다") && _messages.last.sender == "system") {
          setState(() {
            isClosed = true;
          });
        }

        Future.delayed(const Duration(milliseconds: 10), () {
          _scrollToBottom();
        });
      });
    });


  }

  // 내담자의 입력폼 완료 메시지가 뜨면 consultForm 로딩 후 변환
  void _getConsultForm() {

   FirebaseFirestore.instance.collection('chats')
        .doc(chatId)
        .get().then((doc) {

      var data = doc.data();
      String? consultForm = data!['consultForm'] as String?;

      if (consultForm != null) {
        // consultForm 필드가 존재하면 생성
        setState(() {
          isShowConsultForm = true;
        });
        _generateConsultForm(consultForm);
      } else {
        logger.e("내담자 입력 폼이 없음");
      }
        });

  }

  void _generateConsultForm(String consultForm) {
    var inputs = consultForm.split(",");
    name = inputs[0];
    gender = inputs[1];
    age = inputs[2];
    var year = inputs[3];
    var month = inputs[4];
    var day = inputs[5];

    // 음력 계산
    setSolarDate(int.parse(year), int.parse(month), int.parse(day));
    final lunar = getLunarIsoFormat();

    lunarYear = int.parse(lunar.split("-")[0]);
    lunarMonth = int.parse(lunar.split("-")[1]);
    lunarDay = int.parse(lunar.split("-")[2]);

    var index1 = (lunarYear - 1900) % 12;
    ddi = "${zodiac[index1]}띠";
    destiny1 = destiny[index1];
    day1 = days[index1];

    var index2 = (index1 + lunarMonth - 1) % 12;
    destiny2 = destiny[index2];
    day2 = days[index2];

    var index3 = (index2 + lunarDay) % 12;
    destiny3 = destiny[index3];
    day3 = days[index3];

    logger.d("성별 : $gender, 나이 : $age");
    logger.d("음력 생년월일 : $lunar");
    logger.d("destiny : $destiny1, $destiny2, $destiny3");
    logger.d("day : $day1, $day2, $day3");
  }

  void _sendMessage() {
    if (_messageController.text.isNotEmpty) {

      chatService.sendMessage("counsellor", _messageController.text);

      setState(() {
        _messages.add(Message(sender: "counsellor", text: _messageController.text, timestamp: DateTime.now()));
        _messageController.clear();
      });
      _scrollToBottom();
    }
  }

  Future<void> _pickImage() async {

    final ImagePicker picker = ImagePicker();

    final XFile? imageFile = await picker.pickImage(source: ImageSource.gallery);

    if (imageFile == null) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    // 선택된 이미지를 Firestore에 업로드
    String imageUrl = '';
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
    File file = File(resizedFile.path);
    try {
      final ref = FirebaseStorage.instance.ref().child('chatImages').child(imageFile.path);
      await ref.putFile(file);
      imageUrl = await ref.getDownloadURL();


    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('이미지 업로드 실패: $e')));
    }
  
    setState(() {
      chatService.sendImage("counsellor", imageUrl);
      _messages.add(
          Message(sender: "counsellor", text: "", image: imageUrl, timestamp: DateTime.now())
      );
      isLoading = false;
    });
      _scrollToBottom();
  }

  Future<void> _pickImageWeb() async {
    setState(() {
      isLoading = true;
    });

    // 파일 선택
    FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false
    );

    if (result != null) {
      PlatformFile file = result.files.first;

      // 파일에서 이미지 데이터 읽기
      Uint8List imageData = file.bytes!;
      Img.Image? originalImage = Img.decodeImage(imageData);

      // 이미지 크기 조정
      int width = 300;
      double aspectRatio = originalImage!.width / originalImage.height;
      int height = (width / aspectRatio).round();
      Img.Image resizedImage = Img.copyResize(originalImage, width: width, height: height);

      // 조정된 이미지를 새 파일로 저장
      List<int> resizedImageData = Img.encodeJpg(resizedImage);
      Uint8List resizedImageDataBytes = Uint8List.fromList(resizedImageData);

      // Firebase Storage에 이미지 업로드
      String filePath = 'chatImages/${DateTime.now().millisecondsSinceEpoch}';
      try {
        final ref = FirebaseStorage.instance.ref().child(filePath);
        await ref.putData(resizedImageDataBytes);
        String imageUrl = await ref.getDownloadURL();

        // 이미지 메시지 전송
        chatService.sendImage("counsellor", imageUrl);
        _messages.add(Message(sender: "counsellor", text: "", image: imageUrl, timestamp: DateTime.now()));

      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('이미지 업로드 실패: $e')));
      }

      setState(() {
        isLoading = false;
      });

      _scrollToBottom();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('이미지 선택이 취소되었습니다.')));
      setState(() {
        isLoading = false;
      });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('상담사 채팅방'),
        backgroundColor: Colors.green[200],
        actions: <Widget>[
          if (isShowConsultForm)
            ElevatedButton.icon(
              label: const Text("내담자 입력폼", style: TextStyle(color: Colors.black),),
              icon: Icon(isShowConsultDetail ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                color: Colors.black,),
              onPressed: () {
                setState(() {
                  isShowConsultDetail = !isShowConsultDetail;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                disabledBackgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                enableFeedback: false,
                surfaceTintColor: Colors.transparent,
                elevation: 0,
              ),
            ),
        ],
      ),
      body: Stack(
        children: [
          Container(
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
                            child: Text(message.text, style: const TextStyle(fontSize: 14, color: Colors.white)),
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
                                      constraints: const BoxConstraints(
                                      maxWidth: 300,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[300],
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        message.text,
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
                            if(!isUser)
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
                          if (kIsWeb) {
                            _pickImageWeb();
                          } else {
                            _pickImage();
                          }
                        },
                        icon: const Icon(Icons.attach_file),
                        color: Colors.black,
                      ),
                      Expanded(
                        child: TextField(
                          controller: _messageController,
                          enabled: !isClosed,
                          decoration: InputDecoration(
                            hintText: isClosed ? '상담시간이 종료되었습니다.' : '메시지 입력',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            filled: true,
                            fillColor: isClosed ? Colors.grey[300] : Colors.white,
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
          ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            top: isShowConsultDetail ? 0 : -300,
            right: 0,
            left: 0,
            child: Container(
              color: ColorStyles.secondMainColor,
              padding: const EdgeInsets.all(10),
              child: Column(
                children: [
                  const Text("[인적사항]"),
                  const Blank(0, 10),
                  Text("이름 : $name,  성별 : $gender,  나이 : $age"),
                  const Blank(0, 10),
                  Text("생년월일 (음력) : $lunarYear년 $lunarMonth월 $lunarDay일 ($ddi)"),
                  const Blank(0, 20),
                  const Text("[사주정보]"),
                  const Blank(0, 10),
                  Text("$destiny1  $destiny2  $destiny3"),
                  Text("$day1  $day2  $day3"),
                ],
              ),
            ),
          ),
        ],
      )
    );
  }
}