import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:luckymoon/config/theme/app_color.dart';
import 'package:luckymoon/core/logger.dart';
import 'package:luckymoon/data/Counsellor.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../chat/view/chat_list_screen.dart';
import '../../consult/view/consult_list_screen.dart';
import '../../list/view/user_list_screen.dart';
import '../../profile/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _nickname = "";
  bool _isCounsellor = false;

  @override
  void initState() {
    super.initState();
    //_tabController = TabController(length: _isCounsellor ? 4 : 3, vsync: this);

    _checkCounsellorStatus();
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

  Future<void> _checkCounsellorStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userId');
    logger.e("isCounsellor ??? $_isCounsellor");
    if (userId != null) {
      var doc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      bool? isCounsellor = doc.data()?['isCounsellor'];
      setState(() {
        _isCounsellor = isCounsellor!;
        _tabController = TabController(length: _isCounsellor ? 4 : 3, vsync: this);
        _tabController.addListener(_setAppBarTitle);
      });
    }

    logger.e("isCounsellor ??? $_isCounsellor");

  }

  void _setAppBarTitle() {
    setState(() {}); // 앱바 타이틀을 업데이트하기 위해 상태를 갱신
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> tabs = [
      const Tab(icon: Icon(Icons.list), text: '상담사'),
      if (_isCounsellor) const Tab(icon: Icon(Icons.health_and_safety), text: '내 상담'),
      const Tab(icon: Icon(Icons.chat), text: '채팅목록'),
      const Tab(icon: Icon(Icons.person), text: '프로필'),
    ];

    List<Widget> tabViews = [
      const UserListScreen(),
      if (_isCounsellor) const ConsultListScreen(),
      const ChatListScreen(),
      const ProfileScreen(),
    ];

    List<String> titles = ["상담사 리스트", if (_isCounsellor) "상담 리스트", "챗 리스트", "내 프로필"];
    
    return Scaffold(
      appBar: AppBar(
        backgroundColor: ColorStyles.backgroundColor,
        title: Text(_tabController == null ? "" : titles[_tabController.index]),
          actions: <Widget>[
            TextButton.icon(
              icon: const Icon(Icons.account_box_rounded),
              label: Text(_nickname),
              onPressed: () {},
            )
          ],
        elevation: 0,
        ),
      body: TabBarView(
        controller: _tabController,
        physics: const NeverScrollableScrollPhysics(), // 스와이프로 탭 변경을 막음
        children: tabViews,
      ),
      bottomNavigationBar: TabBar(
        controller: _tabController,
        tabs: tabs,
        labelColor: Theme.of(context).primaryColor,
        unselectedLabelColor: Colors.grey,
        indicatorSize: TabBarIndicatorSize.label,
        indicatorPadding: const EdgeInsets.all(5.0),
      ),
    );
  }
}