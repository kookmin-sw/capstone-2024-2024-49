import 'package:luckymoon/core/logger.dart';
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

    logger.e("profileUrl : ${counsellor.profileUrl}");
    return Card(
      margin: EdgeInsets.all(8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      elevation: 8.0,
      child: InkWell(
        onTap: () {
          // context.read<ChatCubit>().setCounsellor(counsellor);
          // context.push('/chat');
        },
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Colors.blue, Colors.lightBlueAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16.0),
          ),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 130,
                height: 130,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  image: counsellor.profileUrl != null && counsellor.profileUrl!.isNotEmpty
                      ? DecorationImage(
                    image: NetworkImage(counsellor.profileUrl!),
                    fit: BoxFit.cover,
                  )
                      : null,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: counsellor.profileUrl == null || counsellor.profileUrl!.isEmpty
                    ? Icon(Icons.person, size: 80)
                    : null,
              ),
              const Blank(0, 10),
              Text(counsellor.nickname, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white)),
              Text(counsellor.comment, style: const TextStyle(fontSize: 16, color: Colors.white70)),
              const Blank(0, 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    icon: const Icon(Icons.chat_bubble_outline, color: Colors.white),
                    label: const Text('상담'),
                    onPressed: () {
                      context.read<ChatCubit>().setCounsellor(counsellor);
                      context.push('/chat');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 4,
                    ),
                  ),
                  const Blank(8, 0),
                  InkWell(
                    onTap: () {
                      context.read<BoardCubit>().setCounsellor(counsellor);
                      context.push('/board');
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.rate_review, color: Colors.yellow),
                        const Blank(4, 0),
                        Text('(${counsellor.reviewCount})', style: const TextStyle(fontSize: 15, color: Colors.white)),
                      ],
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}