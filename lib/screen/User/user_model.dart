import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:weight/models/user.dart';

class UserModel extends ChangeNotifier {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final db = Firestore.instance;
  int currentPageIndex = 0;
  String currentImageURL =
      'https://lh3.googleusercontent.com/ogw/ADGmqu-lCe3avbX9Wvvi6fuveBxkGxZ7NfPReFDdtTYy=s64-c-mo';

  User currentUser;

  setCurrentUser() async {
    final user = await auth.currentUser();
    final String uid = user.uid;
    final currentUser = await setUser(uid);
    this.currentUser = currentUser;
    notifyListeners();
  }

  Future setUser(uid) async {
    final String name = await db
        .collection('users')
        .document(uid)
        .get()
        .then((doc) => doc.data['name']);
    final String docID = await db
        .collection('users')
        .document(uid)
        .get()
        .then((snapshot) => snapshot.documentID);
    var currentUser = User(userID: docID, name: name, iconURL: currentImageURL);
    return currentUser;
  }
}
