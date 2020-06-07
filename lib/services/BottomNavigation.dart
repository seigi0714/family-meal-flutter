import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weight/screen/home/HomePage.dart';
import 'package:weight/screen/home/UserPage.dart';
import 'package:weight/screen/home/GroupPage.dart';

class BottomNavigationBarExample extends StatefulWidget {
  @override
  _BottomNavigationBarExampleState createState() => _BottomNavigationBarExampleState();
}

class _BottomNavigationBarExampleState extends State<BottomNavigationBarExample> {
  var currentTab = [
    HomePage(),
    UserPage(),
    GroupPage(),
  ];

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<BottomNavigationBarProvider>(context);
    return Scaffold(
      body: currentTab[provider.currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: provider.currentIndex,
        onTap: (index) {
          provider.currentIndex =index;
        },
        items: [
          BottomNavigationBarItem(
            icon: new Icon(Icons.home),
            title: new Text('home'),
          ),
          BottomNavigationBarItem(
            icon: new Icon(Icons.person),
            title: new Text('user')
          ),
          BottomNavigationBarItem(
            icon: new Icon(Icons.group),
            title: new Text('group')
          )
        ]
      )
    );
  }
}


class BottomNavigationBarProvider with ChangeNotifier{
  int _currentIndex = 0;

  get currentIndex => _currentIndex;

  set currentIndex(int index) {
    _currentIndex = index;
    notifyListeners();
  }
}