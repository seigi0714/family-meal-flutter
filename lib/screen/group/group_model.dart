import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:weight/screen/group/Group.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:weight/services/auth.dart';

class GroupModel extends ChangeNotifier {
  final functions = CloudFunctions.instance;
  final db = Firestore.instance;
  final auth = FirebaseAuth.instance;

  int currentPageIndex = 0;

  String currentGroupName = '';

  var currentGroup;

  String currentGroupInfo = '';

  String profileURL = "https://twitter.com/KboyFlutterUniv/photo";

  File currentImage = null;

  List<Group> groups = [];

  FirebaseStorage storage = FirebaseStorage.instance;


    Future fetchMyGroups() async {
      final user =await auth.currentUser();
      final uid = user.uid;

      final snapshot = await db
          .collection('users')
          .document(uid)
          .collection('belongingGroup')
          .getDocuments();
      final documentIds =
      snapshot.documents.map((doc) => doc.documentID).toList();

      List<Future<Group>> tasks = documentIds.map((id) async {
         return _fetchGroup(id);
      }).toList();

      final groups = await Future.wait(tasks);
      this.groups = groups;
      notifyListeners();
    }

    // groupIdを使ってgroupのオブジェクトを取得するメソッドを用意
    Future<Group> _fetchGroup(String groupId) async {
      final doc = await db.collection('groups').document(groupId).get();
      final group = Group(
          doc['name'], doc['text'], doc['iconImage'], doc['GroupUser'],
          doc['UserCount'], doc['Follower']);
        return group;
    }


Future imageSet(image) {
  currentImage = image;
  notifyListeners();
}

Future uploadImage(image) async {
  FirebaseStorage storage = FirebaseStorage(
      storageBucket: "gs://family-meal-69f4f.appspot.com");
  final StorageReference ref = storage.ref().child("group-icon/${image.toString()}");
  final metaData = StorageMetadata(contentType: "image/png");
  StorageUploadTask task = ref.putFile(image, metaData);
  profileURL = await (await task.onComplete).ref.getDownloadURL();
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
void linkAddDetail() {
      currentPageIndex = 2;
      notifyListeners();
}
 void goHome() {
  currentPageIndex = 0;
  fetchMyGroups();
  notifyListeners();
}}
