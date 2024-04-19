import 'package:luckymoon/data/Counsellor.dart';
import 'package:luckymoon/features/board/cubit/board_cubit.dart';
import 'package:luckymoon/features/chat/cubit/chat_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/blank.dart';

class UserListItem extends StatelessWidget {
  final Counsellor counsellor;

  const UserListItem({
    Key? key,
    required this.counsellor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
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
            const Blank(16, 0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(counsellor.nickname,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      )),
                  const Blank(0, 8),
                  Text(counsellor.comment), // 상태 메시지 추가
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        context.read<ChatCubit>().setCounsellor(counsellor);
                        context.push('/chat');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        foregroundColor: Colors.pink,
                        shadowColor: Colors.transparent,
                        elevation: 0,
                        side: const BorderSide(color: Colors.pink, width: 2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        '상담하기',
                        style: TextStyle(color: Colors.pink),
                      ),
                    ),
                  ],
                ),
                const Blank(0, 8),
                InkWell(
                  onTap: () {
                    context.read<BoardCubit>().setCounsellor(counsellor);
                    context.push('/board');
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('누적 후기 ${counsellor.reviewCount}개'),
                      const Text(' | '), // 구분자
                      Text('대화 ${counsellor.chatCount}회'),
                    ],
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
