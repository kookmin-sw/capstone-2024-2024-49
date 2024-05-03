import 'package:luckymoon/config/theme/app_color.dart';
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
  final String userId;

  const UserListItem({
    Key? key,
    required this.counsellor,
    required this.userId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Card(
          color: ColorStyles.backgroundColor,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(0),
          ),
          elevation: 0,
          child: Padding(
            padding: const EdgeInsets.only(top: 16.0, left: 16.0, right: 16.0),
            child: InkWell(
              onTap: () {
                // context.read<ChatCubit>().setCounsellor(counsellor);
                // context.push('/chat');
              },
              child: Row(
                children: [
                  // 프로필 이미지
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      image: counsellor.profileUrl != null && counsellor.profileUrl!.isNotEmpty
                          ? DecorationImage(
                        image: NetworkImage(counsellor.profileUrl!),
                        fit: BoxFit.cover,
                      )
                          : null,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: counsellor.profileUrl == null || counsellor.profileUrl!.isEmpty
                        ? const Icon(Icons.person, size: 80, color: Colors.white)
                        : null,
                  ),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            counsellor.nickname,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const Blank(0, 10),
                          Text(
                            counsellor.comment,
                            style: const TextStyle(fontSize: 13),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (counsellor.userId != userId)
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.chat_bubble_outline),
                        label: const Text('상담'),
                        onPressed: () {
                          context.read<ChatCubit>().setCounsellor(counsellor);
                          context.push('/chat');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ColorStyles.mainColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          )
        ),
        const Divider(
          indent: 150,
          endIndent: 16,
          color: Color(0xFFFFFFFF),
          height: 1,
          thickness: 1,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: InkWell(
            onTap: () {
              context.read<BoardCubit>().setCounsellor(counsellor);
              context.push('/board');
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Text('누적후기 '),
                const Icon(Icons.chat_outlined, color: ColorStyles.mainColor),
                Text(' (${counsellor.reviewCount})'),
              ],
            ),
          ),
        ),
        const Divider(
          color: Color(0xFFFFFFFF),
          height: 10,
          thickness: 10,
        ),
      ],
    );
  }


}