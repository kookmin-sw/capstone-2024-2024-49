import 'package:cloud_firestore/cloud_firestore.dart';

import '../../data/Message.dart';

class ChatService {
  late final String chatRoomId;

  ChatService(this.chatRoomId);

  Stream<List<Message>> getMessages() {
    return FirebaseFirestore.instance.collection('chats')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => Message.fromJson(doc.data())).toList());
  }

  Future<void> sendMessage(String sender, String message) async {
    await FirebaseFirestore.instance.collection('chats')
        .doc(chatRoomId)
        .collection('messages')
        .add({
      'sender': sender,
      'text': message,
      'image': "",
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Future<void> sendImage(String sender, String imageUrl) async {
    await FirebaseFirestore.instance.collection('chats')
        .doc(chatRoomId)
        .collection('messages')
        .add({
      'sender': sender,
      'text': "",
      'image': imageUrl,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}