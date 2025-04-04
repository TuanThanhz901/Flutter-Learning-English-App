import 'package:final_project/pages/home.dart';
import 'package:final_project/pages/library.dart';
import 'package:final_project/pages/profile.dart';
import 'package:final_project/pages/ranking.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  final int selectedIndex;

  const HomePage({Key? key, this.selectedIndex = 0}) : super(key: key);

  @override
  State<HomePage> createState() => MyHomePage();
}

class MyHomePage extends State<HomePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedIndex = 0;
  static List<Widget> _widgetOptions = <Widget>[
    Home(),
    Library(),
    Ranking(),
    Profile(),
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.selectedIndex;
    _tabController = TabController(
        length: _widgetOptions.length,
        vsync: this,
        initialIndex: _selectedIndex);
    _tabController.addListener(_onTabChanged);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    setState(() {
      _selectedIndex = _tabController.index;
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _tabController.index = index;
    });
  }

  void setSelectedIndex(int index) {
    setState(() {
      _selectedIndex = index;
      _tabController.animateTo(index); // Chuyển đến tab tương ứng
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: SafeArea(
          child: Scaffold(
            body: TabBarView(
              controller: _tabController,
              children: _widgetOptions,
            ),
            bottomNavigationBar: BottomNavigationBar(
              iconSize: 28,
              items: <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: Image.asset('assets/images/home.png',
                      width: 28, height: 28),
                  activeIcon: Image.asset(
                    'assets/images/home.png',
                    width: 28,
                    height: 28,
                    color: Colors.blue,
                  ),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Image.asset('assets/images/library3.png',
                      width: 26, height: 26),
                  activeIcon: Image.asset(
                    'assets/images/library3.png',
                    width: 26,
                    height: 26,
                    color: Colors.blue,
                  ),
                  label: 'Library',
                ),
                // BottomNavigationBarItem(
                //   icon: Icon(Icons.headset_mic),
                //   activeIcon: Icon(Icons.headset_mic, color: Colors.blue),
                //   label: 'Rank',
                // ),
                BottomNavigationBarItem(
                  icon: Image.asset('assets/images/ranking.png',
                      width: 28, height: 28),
                  activeIcon: Image.asset(
                    'assets/images/ranking.png',
                    width: 28,
                    height: 28,
                    color: Colors.blue,
                  ),
                  label: 'Ranking',
                ),
                BottomNavigationBarItem(
                  icon: Image.asset('assets/images/profile.png',
                      width: 28, height: 28),
                  activeIcon: Image.asset(
                    'assets/images/profile.png',
                    width: 28,
                    height: 28,
                    color: Colors.blue,
                  ),
                  label: 'Profile',
                ),
              ],
              currentIndex: _selectedIndex,
              selectedItemColor: Colors.blue,
              unselectedItemColor: Colors.black,
              showUnselectedLabels: true,
              onTap: _onItemTapped,
            ),
          ),
        ));
  }
}
