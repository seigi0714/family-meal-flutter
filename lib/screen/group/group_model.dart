import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:weight/screen/group/home.dart';

class Group extends ChangeNotifier{
  int currentPageIndex = 0;

  String currentGroupName = '';

  String currentGroupInfo = '';

 File currentImage = null;

  void ImageSet (image) {
    currentImage = image;
    notifyListeners();
  }

  void addGroup (name, introduction,image) {
    // cloud functrion

  }

  void linkAddPage () {
    currentPageIndex = 1;
    notifyListeners();
  }
  void GoHome () {
    currentPageIndex = 0;
    notifyListeners();
  }

}