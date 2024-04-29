import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:luckymoon/data/Counsellor.dart';
import 'package:luckymoon/features/board/cubit/board_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../config/theme/app_color.dart';
import '../../core/blank.dart';
import '../../data/Review.dart';
import '../../data/User.dart';

class BoardScreen extends StatefulWidget {
  const BoardScreen({Key? key}) : super(key: key);

  @override
  _BoardScreenState createState() => _BoardScreenState();
}

class _BoardScreenState extends State<BoardScreen> {
  String userId = "";
  String nickname = "";

  late Counsellor counsellor;
  List<Review> reviews = [];
  late TextEditingController _commentController;

  @override
  void initState() {
    super.initState();
    _getUserInfo();
    _fetchReviews();
    _commentController = TextEditingController();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _getUserInfo() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      String? id = prefs.getString('userId');
      if (id == null) {
        throw Exception('User ID not found in SharedPreferences');
      }

      var doc = await FirebaseFirestore.instance.collection('users').doc(id).get();
      var userData = doc.data();
      if (userData == null) {
        throw Exception('User data not found in Firestore');
      }

      User user = User.fromJson(userData);

      setState(() {
        userId = user.userId;
        nickname = user.nickname;
      });
    } catch (e) {
      print('Failed to fetch user info: $e');
    }
  }

  Future<void> _fetchReviews() async {
    var fetchedReviews = List.generate(20, (index) => {
      "counsellorId": "counsellor${index + 1}",
      "userId": "user${index + 1}",
      "nickname": "사용자${index + 1}",
      "comment": "정말 도움이 많이 되었습니다. 감사합니다. ${index + 1}",
      "timestamp": Timestamp.fromDate(DateTime.now())
    });

    setState(() {
      reviews = fetchedReviews.map((data) => Review.fromJson(data)).toList();
    });
  }

  void _writeReview() {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (BuildContext context) {
        return SingleChildScrollView(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            padding: const EdgeInsets.only(top: 50, left: 16, right: 16, bottom: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: _commentController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: '후기 작성',
                  ),
                ),
                const Blank(0, 16),
                ElevatedButton(
                  onPressed: () {
                    _addReview(_commentController.text);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    backgroundColor: Colors.pink,
                    foregroundColor: Colors.white,
                    fixedSize: const Size(100, 50),
                  ),
                  child: const Text('작성'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _addReview(String comment) {
    final review = Review(
      counsellorId: counsellor.userId,
      userId: userId,
      nickname: nickname,
      comment: comment,
      timestamp: DateTime.now(),
    );

    // Firestore에 reviews 컬렉션에 review 추가
    FirebaseFirestore.instance.collection('reviews').add(review.toJson()).then((value) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('리뷰작성 완료.')));

      // counsellors 컬렉션에서 userId가 counsellor.userId와 동일한 문서 찾기
      FirebaseFirestore.instance.collection('counsellors').where('userId', isEqualTo: counsellor.userId).get().then((querySnapshot) {
        if (querySnapshot.size == 1) {
          // 문서가 존재하면 해당 문서의 reviewCount 값을 1 증가시킨 후 업데이트
          final docId = querySnapshot.docs.first.id;
          final currentReviewCount = querySnapshot.docs.first.get('reviewCount') as int;
          FirebaseFirestore.instance.collection('counsellors').doc(docId).update({'reviewCount': currentReviewCount + 1});
        }
      });
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('리뷰작성 실패.')));
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
              title: Text("       ${counsellor.nickname}"),
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
                            _writeReview();
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