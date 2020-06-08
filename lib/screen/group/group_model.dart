import 'package:flutter/material.dart';
import 'package:weight/screen/group/home.dart';

class Group extends ChangeNotifier{
  int currentPageIndex = 0;
  void linkAddPage () {
    currentPageIndex = 1;
    notifyListeners();
  }
  void GoHome () {
    currentPageIndex = 0;
    notifyListeners();
  }
}