import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:weight/models/Group.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:weight/models/Post.dart';
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

  List<Post> posts = [];
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
          doc.documentID,doc['name'], doc['text'], doc['iconImage'], doc['GroupUser'],
          doc['UserCount'], doc['Follower']);
        return group;
    }

    Future fetchPost(Group group)async {
      final FirebaseUser user = await auth.currentUser();
      final uid = user.uid;
      final snapshots =await db.collection('groups').document(group.groupID).collection('posts').getDocuments();
      final docIds = snapshots.documents.map((doc) => doc.documentID).toList();
      List<Future<Post>> tasks = docIds.map((id) async {
        return _fetchMyPost(id);
      }).toList();

      final List<Post> posts = await Future.wait(tasks);
      this.posts = posts;

      notifyListeners();
    }

    Future<Post> _fetchMyPost(String id) async {
      final doc = await db.collection('posts').document(id).get();
      final posts = Post(id, doc['groupID'],doc['imageURL'],doc['created'],doc['like']);
      return posts;
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
