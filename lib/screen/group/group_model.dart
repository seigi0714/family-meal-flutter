import 'dart:io';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';

class Group extends ChangeNotifier {
  final functions = CloudFunctions.instance;

  int currentPageIndex = 0;

  String currentGroupName = '';

  String currentGroupInfo = '';

  File currentImage = null;

  void ImageSet(image) {
    currentImage = image;
    notifyListeners();
  }

  void addGroup(name, text, image) {
    functions
        .getHttpsCallable(functionName: 'addGroup')
        .call({name: name, text: text, image: image});
  }

  void linkAddPage() {
    currentPageIndex = 1;
    notifyListeners();
  }

  void GoHome() {
    currentPageIndex = 0;
    notifyListeners();
  }
}
