import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weight/screen/group/home.dart';
import 'package:weight/screen/home/home_feed.dart';
import 'package:weight/screen/User//UserPage.dart';
import 'package:weight/screen/group/GroupPage.dart';

class BottomNavigationBarExample extends StatelessWidget {
  @override
  var currentTab = [
    HomePage(),
    UserPage(),
    GroupHome(),
  ];

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<BottomNavigationBarProvider>(context);
    return Scaffold(
      body: currentTab[provider.currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        unselectedItemColor: Colors.grey,
        currentIndex: provider.currentIndex,
        onTap: (index) {
          provider.currentIndex =index;
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            title:  Text('home'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            title:  Text('user')
          ),
          BottomNavigationBarItem(
            icon:  Icon(Icons.group),
            title: Text('group')
          )
        ]
      )
    );
  }
}

// ここが所謂 viewModel
class BottomNavigationBarProvider with ChangeNotifier{

  int _currentIndex = 0;

  get currentIndex => _currentIndex;

  set currentIndex(int index) {
    _currentIndex = index;
    notifyListeners();
  }
}