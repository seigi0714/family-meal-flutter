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
import 'package:weight/models/PopUpMenu.dart';
import 'package:weight/models/Post.dart';
import 'package:weight/models/user.dart';
import 'package:weight/services/auth.dart';

class GroupModel extends ChangeNotifier {
  final functions = CloudFunctions.instance;
  final db = Firestore.instance;
  final auth = FirebaseAuth.instance;
  QuerySnapshot postdoc;
  int currentPageIndex = 0;
  bool isFollow = false;
  bool isBelonging = false;
  bool searching = false;
  bool loading = false;
  String currentGroupName = '';
  Group group;
  List<User> users;
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
    print(documentIds.toString());
    final groups = await Future.wait(tasks);
    print(groups.toString());
    this.groups = groups.where((group) => group.isHidden != true).toList();
    this.loading = true;
    notifyListeners();
  }
  Future updateGroup(Group group) async {
    this.loading = true;
    notifyListeners();
    if(currentImage != null){
    await uploadImage(currentImage);
    }else{
      profileURL = group.iconURL;
    }
    final document =
    Firestore.instance.collection('groups').document(group.groupID);
    await document.updateData(
      {
        'iconImage': profileURL,
        'name': currentGroupName,
        'text': currentGroupInfo,
        'updateAt': Timestamp.now(),
      },
    );

    this.loading = false;
    notifyListeners();
  }

  // groupIdを使ってgroupのオブジェクトを取得するメソッドを用意
  Future<Group> _fetchGroup(String groupId, String uid) async {
    final doc = await db.collection('groups').document(groupId).get();
    print(doc.toString());
    final followDoc = await db
        .collection('users')
        .document(uid)
        .collection('followGroup')
        .getDocuments();
    final hiddenDoc = await db.collection('users').document(uid).collection('hiddenGroups').document(groupId).get();
    final isHidden = hiddenDoc.exists;
    final followIds = followDoc.documents.map((doc) => doc.documentID).toList();
    final bool isFollow = followIds.contains(groupId);
    try {
      this.postdoc = await db
        .collection('groups')
        .document(groupId)
        .collection('posts')
        .getDocuments();
    } catch (e) {
      this.postdoc = null;
    }
    print(postdoc);
    final postIDs = postdoc.documents.map((doc) => doc.documentID).toList();
    print(postIDs);
    final group = Group(
        groupID: doc.documentID,
        name: doc['name'],
        text: doc['text'],
        iconURL: doc['iconImage'],
        userID: doc['Founder'],
        userCount: doc['UserCount'],
        follower: doc['Follower'],
        isBelong: true,
        isFollow: isFollow,
        isHidden: isHidden
    );
    print(group.name);
    notifyListeners();
    return group;
  }
  Future<Group> getGroups(String id) async {
    final user =await auth.currentUser();
    final doc = await db.collection('groups').document(id).get();
    final followDoc = await db.collection('users').document(user.uid).collection('following').document(id).get();
    final isFollow = followDoc.exists;
    this.isFollow = isFollow;
    final belongDoc = await db.collection('users').document(user.uid).collection('belongingGroup').document(id).get();
    final isBelong = belongDoc.exists;
    final hiddenGroup = await db.collection('users').document(user.uid).collection('hiddenGroups').document(id).get();
    final isHidden = hiddenGroup.exists;
    final group = Group(groupID: doc.documentID,
      name: doc['name'],
      text: doc['text'],
      iconURL: doc['iconImage'],
      userID: doc['Founder'],
      userCount: doc['UserCount'],
      follower: doc['Follower'],
      isBelong: isBelong,
      isFollow: isFollow,
      isHidden: isHidden
    );
    this.loading = true;
    print(group.isHidden);
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
  Future getFollower(Group group) async {
    final doc = await db.collection('groups').document(group.groupID).collection('Follower').getDocuments();
    final documentIDs = doc.documents.map((doc) => doc.documentID);
    List<Future<User>> tasks = documentIDs.map((id) async {
      return _fetchFollower(id,group.groupID);
    }).toList();
    final users = await Future.wait(tasks);
    this.users = users;
    notifyListeners();
  }
  Future getMember(Group group) async {
    final doc = await db.collection('groups').document(group.groupID).collection('groupUsers').getDocuments();
    final documentIDs = doc.documents.map((doc) => doc.documentID);
    List<Future<User>> tasks = documentIDs.map((id) async {
      return _fetchFollower(id,group.groupID);
    }).toList();
    final users = await Future.wait(tasks);
    this.users = users;
    notifyListeners();
  }
  Future<User> _fetchFollower(String uid,String groupID) async {
    final doc = await db.collection('users').document(uid).get();
    final invDoc = await db.collection('users').document(uid).collection('invitation').document(groupID).get();
    final bool isInv = invDoc.exists;
    final belongDoc = await db.collection('users').document(uid).collection('belongingGroup').document(groupID).get();
    final isBelong = belongDoc.exists;
    final currentUser = User(userID: doc.documentID,name: doc['name'],iconURL: doc['iconURL'],isBelong: isBelong,isInv: isInv);
    final user = User(userID: uid,name: doc['name'],iconURL: doc['iconURL'],isBelong: isBelong,isInv: isInv);
    return user;
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
    this.groups = groups.where((group) => group.isHidden != true).toList();
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
    notifyListeners();
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
  Future invUser(String userID, String groupID) async {
    db.collection('users').document(userID).collection('invitation').document(groupID).setData({
      'isJoin': false,
      'invitationAt': FieldValue.serverTimestamp(),
    });
  }
  startLoading() {
    loading = true;
    notifyListeners();
  }

  endLoading() {
    loading = false;
    notifyListeners();
  }

  Future addGroup() async {
    if (currentGroupName.isEmpty){
      throw('グループ名を入力してください');
    }
    final user = await auth.currentUser();
    await uploadImage(currentImage);
    await db.collection('groups').add({
     'name': currentGroupName,
     'text': currentGroupInfo,
     'iconImage': profileURL,
      'UserCount': 1,
      'Follower': 0,
      'Founder': user.uid,
      'created': FieldValue.serverTimestamp()
   });
    notifyListeners();
  }
  Future competition(Group group) async {
    final user = await auth.currentUser();
    await db.collection('users').document(user.uid).collection('belongingGroup').document(group.groupID).delete();
  }
  Future reportGroup(Group group) async {
    final user = await auth.currentUser();
    await db.collection('users').document(user.uid).collection('reports').add({
      'reporter': user.uid,
      'target': group.groupID
    });
  }
  Future hiddenGroup(Group group) async {
    final user = await auth.currentUser();
    await db.collection('users').document(user.uid).collection('hiddenGroups').document(group.groupID).setData({
      'groupID': group.groupID
    });
  }
  Future unHidden(String id) async {
    final user = await auth.currentUser();
    await db.collection('users').document(user.uid).collection('hiddenGroups').document(id).delete();
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
