import 'dart:io';
import 'package:algolia/algolia.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
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
  bool isFollow = false;
  bool isBelonging = false;
  bool searching = false;
  bool loading = false;
  String currentGroupName = '';
  Group group;
  String currentGroupInfo = '';
  String profileURL = "https://twitter.com/KboyFlutterUniv/photo";
  File currentImage = null;
  List<Group> groups = [];
  List<Post> posts = [];
  FirebaseStorage storage = FirebaseStorage.instance;

  Future fetchMyGroups() async {
    final user = await auth.currentUser();
    final uid = user.uid;

    final snapshot = await db
        .collection('users')
        .document(uid)
        .collection('belongingGroup')
        .getDocuments();
    final documentIds =
        snapshot.documents.map((doc) => doc.documentID).toList();

    List<Future<Group>> tasks = documentIds.map((id) async {
      return _fetchGroup(id, uid);
    }).toList();

    final groups = await Future.wait(tasks);
    this.groups = groups;
    this.loading = true;
    notifyListeners();
  }

  // groupIdを使ってgroupのオブジェクトを取得するメソッドを用意
  Future<Group> _fetchGroup(String groupId, String uid) async {
    final doc = await db.collection('groups').document(groupId).get();
    final followDoc = await db
        .collection('users')
        .document(uid)
        .collection('followGroup')
        .getDocuments();
    final followIds = followDoc.documents.map((doc) => doc.documentID).toList();
    final bool isFollow = followIds.contains(groupId);
    final postdoc = await db
        .collection('groups')
        .document(groupId)
        .collection('posts')
        .getDocuments();
    final postIDs = postdoc.documents.map((doc) => doc.documentID).toList();
    final group = Group(
        groupID: doc.documentID,
        name: doc['name'],
        text: doc['text'],
        iconURL: doc['iconImage'],
        userID: doc['GroupUser'],
        userCount: doc['UserCount'],
        follower: doc['Follower'],
        postIds: postIDs,
        isBelong: true,
        isFollow: isFollow);
    return group;
  }
  Future<Group> getGroups(String id) async {
    final user =await auth.currentUser();
    final doc = await db.collection('groups').document(id).get();
    final followDoc = await db.collection('users').document(user.uid).collection('following').document(id).get();
    final isFollow = followDoc.exists;
    final belongDoc = await db.collection('users').document(user.uid).collection('belongingGroup').document(id).get();
    final isBelong = belongDoc.exists;
    final group = Group(groupID: doc.documentID,
      name: doc['name'],
      text: doc['text'],
      iconURL: doc['iconImage'],
      userID: doc['GroupUser'],
      userCount: doc['UserCount'],
      follower: doc['Follower'],
      isBelong: isBelong,
      isFollow: isFollow);
    print(group.isFollow);
    this.loading = true;
    this.group = group;
    notifyListeners();
    return group;
  }

  Future fetchPost(Group group) async {
    final FirebaseUser user = await auth.currentUser();
    final uid = user.uid;
    final snapshots = await db
        .collection('groups')
        .document(group.groupID)
        .collection('posts')
        .getDocuments();
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
    final posts = Post(
        name: doc['title'],
        text: doc['text'],
        postID: id,
        groupID: doc['groupID'],
        imageURL: doc['imageURL'],
        created: doc['created'],
        likes: doc['like']);
    return posts;
  }

  // idの配列から投稿を取得する
  Future getPosts(List<String> ids) async {
    List<Future<Post>> tasks = ids.map((id) async {
      return _fetchMyPost(id);
    }).toList();
    final posts = await Future.wait(tasks);
    print(posts.toString());
    this.posts = posts;
    notifyListeners();
  }

  Future searchGroup(text) async {
    Algolia algolia = Algolia.init(
      applicationId: DotEnv().env["ALGOLIA_APP_KEY"],
      apiKey: DotEnv().env["SEARCH_API_KEY"],
    );
    AlgoliaQuery query = algolia.instance.index('groups');
    query = query.search(text);
    query = query.setHitsPerPage(30);

    final results = (await query.getObjects()).hits;
    print(results.toString());
    final groupIds = results.map((result) => result.objectID);
    List<Future<Group>> tasks = groupIds.map((id) async {
      return getGroups(id);
    }).toList();
    final groups = await Future.wait(tasks);
    this.groups = groups;
    print(groups.toString());
    this.searching = true;
    notifyListeners();
  }

  Future imageSet(image) {
    currentImage = image;
    notifyListeners();
  }

  Future followGroup(String id) async {
    final user = await auth.currentUser();
    await db.collection('users').document(user.uid).collection('following').document(id).setData({
      'groupID': id,
    });
    await db.collection('groups').document(id).updateData({
      'Follower': FieldValue.increment(1),
    });
    this.isFollow = true;
  }
  Future unFollowGroup(String id) async {
    final user = await auth.currentUser();
    await db.collection('users').document(user.uid).collection('following').document(id).delete();
    await db.collection('groups').document(id).updateData({
      'Follower': FieldValue.increment(-1),
    });
    this.isFollow = false;
    notifyListeners();
  }


  Future uploadImage(image) async {
    FirebaseStorage storage =
        FirebaseStorage(storageBucket: "gs://family-meal-69f4f.appspot.com");
    final StorageReference ref =
        storage.ref().child("group-icon/${image.toString()}");
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
  }
}
