
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:weight/models/Group.dart';
import 'package:weight/models/Post.dart';

class HomeModel extends ChangeNotifier {
  final auth = FirebaseAuth.instance;
  final db = Firestore.instance;
  List<Group> belongGroup = [];
  List<Post> userPost = [];
  bool isLike = false;

  Future fetchUser()async {
    final FirebaseUser user = await auth.currentUser();
    final uid = user.uid;
    // ⓵ 自分の所属しているグループを取得
    final snapshot = await db
        .collection('users')
        .document(uid)
        .collection('belongingGroup')
        .getDocuments();
    // ⓶　⓵で取得したグループのリストをdocumentIDのリストに変換
    final documentIds =
    snapshot.documents.map((doc) => doc.documentID).toList();
    print(documentIds);

    // ⓶を使ってグループリストを作るメゾッドの配列を取得
    List<Future<Group>> tasks = documentIds.map((id) async {
      return _fetchGroup(id);
    }).toList();
    // ⓶を使って投稿記事を取って来るメゾッドの配列
    List<Future<Post>> getPosts = documentIds.map((id) async {
      return _fetchMyPostId(id);
    }).toList();

    // 自分のグループの作成したpostの作成
    final groups = await Future.wait(tasks);
    print(groups.toString());
    this.belongGroup = groups;

    notifyListeners();
  }
  //
  Future<Post> _fetchMyPostId(String id) async {
    final doc = await db.collection('groups').document(id).collection('posts').getDocuments();
    final postIds = doc.documents.map((doc) => doc.documentID).toList();
    List<Future<Post>> postGet = postIds.map((id) async {
      return _fetchMyPost(id);
    }).toList();
    final posts = await Future.wait(postGet);
    this.userPost = posts;
    notifyListeners();
  }

  Future<Post> _fetchMyPost(String id) async {
    final user = await auth.currentUser();
    final doc = await db.collection('posts').document(id).get();
    print(doc.toString());
    final likePost = await db.collection('users').document(user.uid).collection('likePost').getDocuments();
    final ids = likePost.documents.map((doc) => doc.documentID);
    final bool isLike = ids.contains(id);
    print(isLike.toString());
    final post = Post(name:doc['title'],text:doc['text'],postID:doc.documentID, groupID:doc['GroupID'],imageURL:doc['imageURL'],created:doc['created'], likes:doc['like'],isLike:isLike);
    return post;
  }



  // groupIdを使ってgroupのオブジェクトを取得するメソッドを用意
  Future<Group> _fetchGroup(String groupId) async {
    final doc = await db.collection('groups').document(groupId).get();
    final group = Group(
        doc.documentID,doc['name'], doc['text'], doc['iconImage'], doc['GroupUser'],
        doc['UserCount'], doc['Follower']);
    return group;
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

 }
 // いいね解除したときの処理
 Future unLikePost(Post post) async {
    final user =await auth.currentUser();
    db.collection('posts').document(post.postID).collection('likeUsers').document(user.uid).delete();
    db.collection('users').document(user.uid).collection('likePost').document(post.postID).delete();
 }
}