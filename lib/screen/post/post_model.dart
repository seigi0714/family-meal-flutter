import 'dart:io';

import 'package:algolia/algolia.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:weight/models/Group.dart';
import 'package:weight/models/Post.dart';

class PostModel extends ChangeNotifier{
  final db = Firestore.instance;
  final auth = FirebaseAuth.instance;

  String currentPostName = "";
  String currentPostInfo = "";
  String profileURL = "";

  File currentImage;
  bool searching = false;
  bool isLike = false;
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

  Future<Post> _fetchMyPost(String id) async {
    final user = await auth.currentUser();
    final doc = await db.collection('posts').document(id).get();
    final likePost = await db.collection('users').document(user.uid).collection('likePost').getDocuments();
    final ids = likePost.documents.map((doc) => doc.documentID);
    final bool isLike = ids.contains(id);
    final posts = Post(name:doc['title'],text:doc['text'],postID:id, groupID:doc['groupID'], created:doc['created'],imageURL:doc['imageURL'],likes:doc['like'],isLike:isLike);
    this.isLike = isLike;
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
  // algoliaに検索をかける
  Future searchPost(text) async {
    Algolia algolia = Algolia.init(
      applicationId: DotEnv().env["ALGOLIA_APP_KEY"],
      apiKey: DotEnv().env["SEARCH_API_KEY"],
    );
    AlgoliaQuery query = algolia.instance.index('posts');
    query = query.search(text);

    final results = (await query.getObjects()).hits;
    final postIds = results.map((result) => result.objectID);
    List<Future<Post>> tasks = postIds.map((id) async {
      return _fetchMyPost(id);
    }).toList();
    final posts = await Future.wait(tasks);
    this.posts = posts;
    print(posts.toString());
    this.searching = false;
    notifyListeners();
  }

  // いいねの処理
  Future likePost(Post post) async {
    final user = await auth.currentUser();
    db.collection('posts').document(post.postID).collection('likeUsers').document(user.uid).setData({
      'user': user.uid,
    });
    db.collection('posts').document(post.postID).updateData({
      'like': FieldValue.increment(1),
    });
    db.collection('users').document(user.uid).collection('likePost').document(post.postID).setData({
      'postID': post.postID,
      'group' : post.groupID,
    });
    this.isLike = true;
    notifyListeners();
  }
  // いいね解除したときの処理
  Future unLikePost(Post post) async {
    final user =await auth.currentUser();
    db.collection('posts').document(post.postID).collection('likeUsers').document(user.uid).delete();
    db.collection('users').document(user.uid).collection('likePost').document(post.postID).delete();
    this.isLike = false;
    notifyListeners();
  }
}