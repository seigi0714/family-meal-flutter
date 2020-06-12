import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';

class Group extends ChangeNotifier {
  final functions = CloudFunctions.instance;

  int currentPageIndex = 0;

  String currentGroupName = '';

  String currentGroupInfo = '';

  String profileURL = "";

  File currentImage = null;

  FirebaseStorage storage = FirebaseStorage.instance;


  void ImageSet(image) {
    currentImage = image;
    notifyListeners();
  }
  Future UploadImage(image) async {

    FirebaseStorage storage = FirebaseStorage(storageBucket: "gs://family-meal-69f4f.appspot.com");
    final StorageReference ref =storage.ref().child("group-icon");
    final metaData = StorageMetadata(contentType: "image/png");
    StorageUploadTask task = ref.putFile(image, metaData);
    profileURL= await (await task.onComplete).ref.getDownloadURL();
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
