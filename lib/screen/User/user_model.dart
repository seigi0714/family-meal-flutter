import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:weight/models/user.dart';

class UserModel extends ChangeNotifier {
  final FirebaseAuth auth = FirebaseAuth.instance;

  final db = Firestore.instance;

  int currentPageIndex = 0;

  String currentImageURL =
      'https://lh3.googleusercontent.com/ogw/ADGmqu-lCe3avbX9Wvvi6fuveBxkGxZ7NfPReFDdtTYy=s64-c-mo';

  User currentUser;

  String currentUserName;

  File currentImage;

  setCurrentUser() async {
    final user = await auth.currentUser();
    final String uid = user.uid;
    final currentUser = await setUser(uid);
    this.currentUser = currentUser;
    this.currentUserName = currentUser.name;
    notifyListeners();
  }

  Future setUser(uid) async {
    final doc = await db.collection('users').document(uid).get();
    final String name = await db
        .collection('users')
        .document(uid)
        .get()
        .then((doc) => doc.data['name']);
    final String iconURL = await db
        .collection('users')
        .document(uid)
        .get()
        .then((doc) => doc.data['iconURL']);
    final String docID = await db
        .collection('users')
        .document(uid)
        .get()
        .then((snapshot) => snapshot.documentID);
    var currentUser = User(userID: docID, name:name, iconURL: iconURL);
    return currentUser;
  }
  void imageSet(image) {
    currentImage = image;
    notifyListeners();
  }

  Future uploadImage(image) async {
    FirebaseStorage storage = FirebaseStorage(
        storageBucket: "gs://family-meal-69f4f.appspot.com");
    final StorageReference ref = storage.ref().child("group-icon/${image.toString()}");
    final metaData = StorageMetadata(contentType: "image/png");
    StorageUploadTask task = ref.putFile(image, metaData);
    currentImageURL = await (await task.onComplete).ref.getDownloadURL();
    notifyListeners();
    return currentImageURL;
  }

  Future nameEdit(name) async {
     this.currentUserName = name;
  }
  Future updateUser(String imageURL,String name) async {
    final user = await auth.currentUser();
    final String uid = user.uid;
    await db.collection('users').document(uid).updateData({
        "iconURL": imageURL,
         "name": name,
      },
    );
  }
}


