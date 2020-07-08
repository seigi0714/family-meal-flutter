import 'dart:async';
import 'dart:io';

import 'package:algolia/algolia.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:weight/models/Group.dart';
import 'package:weight/models/Invitation.dart';
import 'package:weight/models/user.dart';

class UserModel extends ChangeNotifier {
  final FirebaseAuth auth = FirebaseAuth.instance;

  final db = Firestore.instance;

  int currentPageIndex = 0;

  String currentImageURL =
      'https://lh3.googleusercontent.com/ogw/ADGmqu-lCe3avbX9Wvvi6fuveBxkGxZ7NfPReFDdtTYy=s64-c-mo';
  User currentUser;
  bool searching = false;
  bool loading = false;
  bool isImage = false;
  bool isSelect = false;
  int invCount = 0;
  String currentUserName;
  List<Invitation> invs;
  Group group;
  List<User> users;
  List<Group> followList;
  File currentImage;

  setCurrentUser() async {
    final user = await auth.currentUser();
    final String uid = user.uid;
    final currentUser = await setUser(uid);
    this.currentUser = currentUser;
    this.currentUserName = currentUser.name;
    this.loading = true;
    notifyListeners();
  }
  Future setUser(uid) async {
    final doc = await db.collection('users').document(uid).get();
    final invDoc = await db.collection('users').document(uid).collection('invitation').getDocuments();
    final invCount = invDoc.documents.length;
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
    this.invCount = invCount;
    notifyListeners();
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
    this.currentImageURL = await (await task.onComplete).ref.getDownloadURL();
    notifyListeners();
    return currentImageURL;
  }
  Future nameEdit(name) async {
     this.currentUserName = name;
  }
  Future updateUser() async {
    final user = await auth.currentUser();
    final String uid = user.uid;
    await db.collection('users').document(uid).updateData({
        "iconURL": currentImageURL,
         "name": currentUserName,
      },
    );
  }
  Future searchUser(String text,String groupID) async {
    Algolia algolia = Algolia.init(
      applicationId: DotEnv().env["ALGOLIA_APP_KEY"],
      apiKey: DotEnv().env["SEARCH_API_KEY"],
    );
    AlgoliaQuery query = algolia.instance.index('user');
    query = query.search(text);
    query = query.setHitsPerPage(30);

    final results = (await query.getObjects()).hits;
    print(results.toString());
    final userIds = results.map((result) => result.objectID);
    List<Future<User>> tasks = userIds.map((id) async {
      return getUser(id,groupID);
    }).toList();
    final users = await Future.wait(tasks);
    // そのグループに所属していないユーザーのみ表示
    final List<User> userList = users.where((user) => user.isBelong).toList();
    this.users = userList;
    print(userList.toString());
    this.searching = true;
    notifyListeners();
  }
  Future<User> getUser(String id,String groupID) async {
    final user =await auth.currentUser();
    final doc = await db.collection('users').document(id).get();
    final invDoc = await db.collection('users').document(user.uid).collection('invitation').document(groupID).get();
    final bool isInv = invDoc.exists;
    final belongDoc = await db.collection('users').document(user.uid).collection('belongingGroup').document(groupID).get();
    final isBelong = belongDoc.exists;
    final currentUser = User(userID: doc.documentID,name: doc['name'],iconURL: doc['iconURL'],isBelong: isBelong,isInv: isInv);
    this.loading = true;
    notifyListeners();
    return currentUser;
  }
  Future invUser(String userID, String groupID) async {
    db.collection('users').document(userID).collection('invitation').document(groupID).setData({
       'isJoin': false,
      'invitationAt': FieldValue.serverTimestamp(),
    });
  }
  Future getInv(String uid) async {
    final docs = await db.collection('users').document(uid).collection('invitation').getDocuments();
    final List<Invitation> invs = docs.documents.map((doc) =>
    Invitation(groupID: doc.documentID,created: doc['invitationAt']
    )).toList();
    this.invs = invs;
    print(invs.toString());
    this.loading = true;
    notifyListeners();
  }
  Future<Group> getGroup(String id) async {
    final doc = await db.collection('groups').document(id).get();
    final group = Group(groupID: id,name: doc['name'],text: doc['text'],iconURL: doc['iconImage']);
    return group;
  }
  Future fetchGroup(String id) async {
    final doc = await db.collection('groups').document(id).get();
    final group = Group(groupID: doc.documentID,name: doc['name'],text: doc['text'],iconURL: doc['iconImage']);
    print(group.iconURL);
    print(group.name);
    this.group = group;
    this.loading = true;
    this.isImage = true;
    notifyListeners();
  }
  // グループ参加
  Future join(String id) async {
    final user = await auth.currentUser();
    await db.collection('groups').document(id).collection('groupUsers').document(
        user.uid).setData({
      'joinAt': FieldValue.serverTimestamp(),
    });
    db.collection('users').document(user.uid).collection('belongingGroup').document(id).setData({
      'joinAt': FieldValue.serverTimestamp(),
      'groupID': id
    });
    db.collection('users').document(user.uid).collection('invitation').document(id).delete();
  }
  Future chancel(String id) async {
    final user = await auth.currentUser();
    await db.collection('users').document(user.uid).collection('invitation').document(id).delete();
  }
  Future getFollowGroups(String uid) async {
    final doc = await db.collection('users').document(uid).collection('following').getDocuments();
    print(doc.toString());
    final docIds = doc.documents.map((doc) => doc.documentID).toList();
    List<Future<Group>> tasks = docIds.map((id) async {
      return _getFollowGroups(id);
    }).toList();
    final groups = await Future.wait(tasks);
    print(groups.toString());
    this.followList = groups;
    notifyListeners();
  }
  Future<Group> _getFollowGroups(String id) async {
    final doc = await db.collection('groups').document(id).get();
    final group = Group(groupID: id,name: doc['name'],text: doc['text'],iconURL: doc['iconImage'],isBelong: true,follower: doc['Follower'],userCount: doc['UserCount']);
    return group;
  }
}


