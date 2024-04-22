import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:luckymoon/data/Counsellor.dart';
import 'package:luckymoon/data/Message.dart';

import '../../../data/User.dart';

class ConsultListItem extends StatelessWidget {
  final User user;
  final String messageText;
  final DateTime messageTime;

  const ConsultListItem({
    Key? key,
    required this.user,
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
      String amPm = dateOfMessage.hour >= 12 ? '오후' : '오전';
      formattedDate = '$amPm $hourMinute';
    } else {
      // 다른 날짜인 경우 월, 일 표시
      formattedDate = DateFormat('M월 d일').format(messageTime);
    }

    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            const CircleAvatar(
              radius: 40,
              backgroundImage: null,
              child: Icon(Icons.person, size: 40)
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(user.nickname,
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
    );
  }
}