import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:luckymoon/data/Counsellor.dart';
import 'package:luckymoon/data/Message.dart';

import '../cubit/chat_cubit.dart';

class ChatListItem extends StatelessWidget {
  final Counsellor counsellor;
  final String chatId;
  final DateTime createdAt;
  final String messageText;
  final DateTime messageTime;

  const ChatListItem({
    Key? key,
    required this.counsellor,
    required this.chatId,
    required this.createdAt,
    required this.messageText,
    required this.messageTime,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 현재 날짜 가져오기
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateOfMessage = DateTime(messageTime.year, messageTime.month, messageTime.day);

    // 날짜 포맷 결정
    String formattedDate;
    if (dateOfMessage == today) {
      // 오늘 날짜인 경우 시간만 표시
      String hourMinute = DateFormat('hh:mm').format(messageTime);
      String amPm = messageTime.hour >= 12 ? '오후' : '오전';
      formattedDate = '$amPm $hourMinute';
    } else {
      // 다른 날짜인 경우 월, 일 표시
      formattedDate = DateFormat('M월 d일').format(messageTime);
    }

    // 시간 차이 계산 (20분 체크)
    bool isClosed = now.difference(createdAt).inMinutes > 20;

    return InkWell(
      onTap: () {
        context.read<ChatCubit>().setCounsellor(counsellor);
        context.read<ChatCubit>().setChatId(chatId);
        context.push('/chat');
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 1.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(0.0),
        ),
        elevation: 0.0,
        color: isClosed ? Colors.grey[300] : Colors.yellow[600],
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60, 
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  image: counsellor.profileUrl != null && counsellor.profileUrl!.isNotEmpty
                      ? DecorationImage(
                    image: NetworkImage(counsellor.profileUrl!),
                    fit: BoxFit.cover,
                  )
                      : null,
                  color: Colors.grey[300],
                ),
                child: counsellor.profileUrl == null || counsellor.profileUrl!.isEmpty
                    ? const Icon(Icons.person, size: 30, color: Colors.white)
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(counsellor.nickname,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.black87,
                        )),
                    const SizedBox(height: 4),
                    Text(
                      messageText,
                      style: TextStyle(color: Colors.grey[600]),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Text(
                formattedDate,
                style: TextStyle(color: Colors.grey[500], fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}