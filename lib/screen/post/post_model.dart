import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:weight/models/Group.dart';
import 'package:weight/models/Post.dart';

class PostModel extends ChangeNotifier{
  final db = Firestore.instance;
  final auth = FirebaseAuth.instance;

  String currentPostName = "";
  String currentPostInfo = "";
  String profileURL = "";

  File currentImage;

  List<Post> posts = [];

  Future fetchPost(Group group)async {
    final FirebaseUser user = await auth.currentUser();
    final uid = user.uid;
    final snapshots =await db.collection('groups').document(group.groupID).collection('posts').getDocuments();
    final docIds = snapshots.documents.map((doc) => doc.documentID).toList();
    List<Future<Post>> tasks = docIds.map((id) async {
      return _fetchMyPost(id);
    }).toList();

    final posts = await Future.wait(tasks);
    this.posts = posts;

    notifyListeners();
  }

  Future _fetchMyPost(String id) async {
    final doc = await db.collection('posts').document(id).get();
    final posts = Post(id, doc['groupID'], doc['created'],doc['imageURL'], doc['like']);
    return posts;
  }

  void imageSet(image){
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
}