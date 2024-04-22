import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:luckymoon/data/Counsellor.dart';
import 'package:luckymoon/data/Message.dart';

import '../cubit/chat_cubit.dart';

class ChatListItem extends StatelessWidget {
  final Counsellor counsellor;
  final String messageText;
  final DateTime messageTime;

  const ChatListItem({
    Key? key,
    required this.counsellor,
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

    return InkWell(
      onTap: () {
        context.read<ChatCubit>().setCounsellor(counsellor);
        context.push('/chat');
      },
      child: Card(
        margin: const EdgeInsets.all(8.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundImage: counsellor.profileUrl != null &&
                    counsellor.profileUrl!.isNotEmpty
                    ? NetworkImage(counsellor.profileUrl!)
                    : null,
                child: counsellor.profileUrl == null ||
                    counsellor.profileUrl!.isEmpty
                    ? const Icon(Icons.person, size: 40)
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
                          fontSize: 20,
                        )),
                    const SizedBox(height: 8),
                    Text(
                      messageText,
                      style: TextStyle(color: Colors.grey[600]),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    formattedDate,
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}