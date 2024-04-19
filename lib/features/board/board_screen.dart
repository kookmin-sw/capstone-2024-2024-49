import 'package:luckymoon/data/Counsellor.dart';
import 'package:luckymoon/features/board/cubit/board_cubit.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/blank.dart';
import '../../data/Review.dart';


class BoardScreen extends StatefulWidget {
  const BoardScreen({Key? key}) : super(key: key);

  @override
  _BoardScreenState createState() => _BoardScreenState();
}

class _BoardScreenState extends State<BoardScreen> {
  late Counsellor counsellor;
  List<Review> reviews = [];

  @override
  void initState() {
    super.initState();
    fetchReviews();
  }



  // Firestore에서 리뷰 데이터를 가져오는 로직 (예시로 직접 데이터를 할당)
  Future<void> fetchReviews() async {
    var fetchedReviews = [
      {"nickname": "룰룰", "comment": "상담 좋습니다~!"},
      {"nickname": "김사주", "comment": "감사합니다!!"},
    ];

    setState(() {
      reviews = fetchedReviews.map((data) => Review.fromJson(data)).toList();
    });
  }

  @override
  Widget build(BuildContext context) {

    counsellor = context.read<BoardCubit>().getCounsellor();

    return Scaffold(
      appBar: AppBar(
        title: Text('상담자 게시판'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundImage: counsellor.profileUrl != null && counsellor.profileUrl!.isNotEmpty ? NetworkImage(counsellor.profileUrl!) : null,
              child: counsellor.profileUrl == null || counsellor.profileUrl!.isEmpty ? const Icon(Icons.person, size: 40) : null,
            ),
            const Blank(0, 8),
            Center(child: Text(counsellor.nickname)),
            const Blank(0, 16),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: reviews.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(reviews[index].nickname),
                  subtitle: Text(reviews[index].comment),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}