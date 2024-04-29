import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:luckymoon/data/Counsellor.dart';
import 'package:luckymoon/features/board/cubit/board_cubit.dart';
import '../../config/theme/app_color.dart';
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

  Future<void> fetchReviews() async {
    var fetchedReviews = List.generate(20, (index) => {
      "counsellorId": "counsellor${index + 1}",
      "userId": "user${index + 1}",
      "nickname": "사용자${index + 1}",
      "comment": "정말 도움이 많이 되었습니다. 감사합니다. ${index + 1}",
      "reply": "소중한 후기 감사드립니다! ${index + 1}",
      "profileUrl": index % 2 == 0 ? "http://example.com/profile${index + 1}.jpg" : null,
    });

    setState(() {
      reviews = fetchedReviews.map((data) => Review.fromJson(data)).toList();
    });
  }


  @override
  Widget build(BuildContext context) {
    counsellor = context.read<BoardCubit>().getCounsellor();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: ColorStyles.secondMainColor,
            expandedHeight: 350.0,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Image.network(
                counsellor.profileUrl ?? '',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const Icon(Icons.person, size: 80),
              ),
              title: Text(counsellor.nickname),
              titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
            ),
          ),
          SliverPersistentHeader(
            delegate: _SliverAppBarDelegate(
              minHeight: 50,
              maxHeight: 50,
              child: Container(
                color: Colors.white,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const Text('누적후기 '),
                        const Icon(Icons.chat_outlined, color: Colors.blue),
                        Text(' (${counsellor.reviewCount})'),

                        const Blank(20, 0),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.add),
                          label: const Text('후기작성'),
                          onPressed: () {

                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ColorStyles.mainColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(0),
                            ),
                            elevation: 0,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 1, color: Color(0xFFEAEAEA)),
                  ],
                )
              ),
            ),
            pinned: true,
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 50, bottom: 50, left: 16, right: 16),
                  child: Text("${counsellor.nickname} 님의 게시판 입니다."),
                ),
                const Divider(height: 1, color: Color(0xFFEAEAEA)),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: reviews.length * 2 - 1,
                  itemBuilder: (context, index) {
                    if (index.isOdd) {
                      return const Divider(height: 1, color: Color(0xFFEAEAEA));
                    } else {
                      final reviewIndex = index ~/ 2;
                      return ListTile(
                        title: Text(reviews[reviewIndex].nickname),
                        subtitle: Text(reviews[reviewIndex].comment),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final double minHeight;
  final double maxHeight;
  final Widget child;

  _SliverAppBarDelegate({
    required this.minHeight,
    required this.maxHeight,
    required this.child,
  });

  @override
  double get minExtent => minHeight;
  @override
  double get maxExtent => max(maxHeight, minHeight);

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
  }
}