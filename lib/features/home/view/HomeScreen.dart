import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:luckymoon/data/Counsellor.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../chat/view/chat_list_screen.dart';
import '../../list/view/UserListScreen.dart';
import '../../profile/ProfileScreen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _nickname = "";

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_setAppBarTitle);

    _getNickname();
  }

  @override
  void dispose() {
    _tabController.removeListener(_setAppBarTitle);
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _getNickname() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? nickname = prefs.getString('nickname');
    if (nickname != null) {
      setState(() {
        _nickname = nickname;
      });
    }
  }

  void _setAppBarTitle() {
    setState(() {}); // 앱바 타이틀을 업데이트하기 위해 상태를 갱신
  }

  @override
  Widget build(BuildContext context) {
    List<String> titles = ["상담사 리스트", "챗 리스트", "내 프로필"];
    return Scaffold(
      appBar: AppBar(
          title: Text(titles[_tabController.index]),
          actions: <Widget>[
            TextButton.icon(
              icon: const Icon(Icons.account_box_rounded),
              label: Text(_nickname),
              onPressed: () {
                context.push('/profile');
              },
            )
          ],
        ),
      body: TabBarView(
        controller: _tabController,
        physics: NeverScrollableScrollPhysics(), // 스와이프로 탭 변경을 막음
        children: const [
          UserListScreen(),
          ChatListScreen(),
          ProfileScreen(),
        ],
      ),
      bottomNavigationBar: TabBar(
        controller: _tabController,
        tabs: const [
          Tab(icon: Icon(Icons.list), text: 'List'),
          Tab(icon: Icon(Icons.chat), text: 'Chat'),
          Tab(icon: Icon(Icons.person), text: 'Profile'),
        ],
        labelColor: Theme.of(context).primaryColor,
        unselectedLabelColor: Colors.grey,
        indicatorSize: TabBarIndicatorSize.label,
        indicatorPadding: EdgeInsets.all(5.0),
      ),
    );
  }
}