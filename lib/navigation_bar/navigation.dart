import 'package:flutter/material.dart';
import 'package:sports_c/Alertbox/alertdialogBottomNav.dart';
import 'package:sports_c/Reusable/color.dart';
import 'package:sports_c/user/Home/home.dart';
import 'package:sports_c/user/profile/profile_page.dart';
import 'package:sports_c/user/search/search_screen.dart';
import 'package:sports_c/user/chat/chat_list_screen.dart';

class DashBoardScreen extends StatefulWidget {
  final int? selectTab;
  const DashBoardScreen({Key? key, this.selectTab}) : super(key: key);

  @override
  State<DashBoardScreen> createState() => _DashBoardScreenState();
}

class _DashBoardScreenState extends State<DashBoardScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    // const HomePage(),
    Placeholder(),
    const SearchPage(),
    const ChatListScreen(),
    const ProfilePage(),
  ];

  final List<IconData> _icons = [
    Icons.home,
    Icons.search,
    Icons.chat_bubble_outline,
    Icons.person_outline,
  ];

  void _initSelectedTab() {
    if (widget.selectTab != null &&
        widget.selectTab! >= 0 &&
        widget.selectTab! < _pages.length) {
      _selectedIndex = widget.selectTab!;
    }
  }

  @override
  void initState() {
    super.initState();
    _initSelectedTab();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: whiteColor,
        body: _pages[_selectedIndex],
        bottomNavigationBar: _buildFullWidthBottomNav(),
      ),
    );
  }

  Future<bool> _onWillPop() async {
    if (_selectedIndex != 0) {
      setState(() {
        _selectedIndex = 0; // Go to home tab instead of reloading screen
      });
      return false;
    } else {
      final shouldExit = await showExitConfirmationDialog(
        context,
        MediaQuery.of(context).size,
      );
      return shouldExit;
    }
  }

  Widget _buildFullWidthBottomNav() {
    return Container(
      height: 70,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade400, Colors.green.shade400],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 6,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(_icons.length, (index) {
          final isSelected = index == _selectedIndex;
          return GestureDetector(
            onTap: () {
              setState(() => _selectedIndex = index);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white.withOpacity(0.25) : Colors.transparent,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Icon(
                _icons[index],
                color: isSelected ? Colors.white : Colors.white70,
                size: isSelected ? 28 : 24,
              ),
            ),
          );
        }),
      ),
    );
  }
}
