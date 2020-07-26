import 'dart:io';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:algolia/algolia.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:weight/models/Comment.dart';
import 'package:weight/models/Group.dart';
import 'package:weight/models/Post.dart';
import 'package:weight/models/user.dart';

class PostModel extends ChangeNotifier{
  final db = Firestore.instance;
  final auth = FirebaseAuth.instance;
  final function = CloudFunctions.instance;

  String currentPostName = "";
  String currentPostInfo = "";
  String profileURL = "";
  String commentText = "";
  List<Comment> postComments = [];
  File currentImage;
  bool loading = true;
  bool searching = true;
  bool isLike = false;
  List<Post> posts = [];
  User user;

  Future fetchPost(Group group)async {
    final FirebaseUser user = await auth.currentUser();
    final uid = user.uid;
    final snapshots =await db.collection('groups').document(group.groupID).collection('posts').getDocuments();
    final docIds = snapshots.documents.map((doc) => doc.documentID).toList();
    List<Future<Post>> tasks = docIds.map((id) async {
      return _fetchMyPost(id);
    }).toList();
    final posts = await Future.wait(tasks);
    this.posts = posts.where((doc) => doc.isHidden != true).toList();
    notifyListeners();
  }
  Future fetchPostComments(Post post) async {
    final user = await auth.currentUser();
    final doc = await db.collection('posts').document(post.postID).collection('comments').getDocuments();
    final groupUsers = await db.collection('groups').document(post.groupID).collection('groupUsers').getDocuments();
    final List<String> userIds = groupUsers.documents.map((doc) => doc.documentID).toList();
    final List<String> commentIds = doc.documents.map((doc) => doc.documentID).toList();
    List<Future<Comment>> tasks = commentIds.map((id) async {
      return _fetchPostComments(id,userIds,post.postID,user.uid);
    }).toList();
    final List<Comment> results = await Future.wait(tasks);
    this.postComments = results;
    this.loading = true;
    notifyListeners();
  }
  Future<Comment> _fetchPostComments(String id,List<String> ids,String postID,String uid) async {
    final doc = await db.collection('posts').document(postID).collection('comments').document(id).get();
    final bool isGroupUser = ids.contains(doc['userID']);
    final bool isMine = doc['userID'] == uid;
    final DateTime created = doc['created'].toDate();
    final hiddenUser = await db.collection('users').document(uid).collection('hiddenUsers').document(doc['userID']).get();
    final bool isHidden = hiddenUser.exists;
    print(isHidden);
    final comment = Comment(commentID: doc.documentID,postID: doc['postID'],userID: doc['userID'],text: doc['text'],created: created,isGroupUser: isGroupUser,isMine: isMine,isHidden: isHidden);
    return comment;
  }
  Future<Post> _fetchMyPost(String id) async {
    final user = await auth.currentUser();
    final doc = await db.collection('posts').document(id).get();
    final hiddenDoc = await db.collection('users').document(user.uid).collection('hiddenGroup').document(doc['GroupID']).get();
    final isHidden = hiddenDoc.exists;
    final likePost = await db.collection('users').document(user.uid).collection('likePost').getDocuments();
    final ids = likePost.documents.map((doc) => doc.documentID);
    final bool isLike = ids.contains(id);
    final posts = Post(name:doc['name'],text:doc['text'],postID:id, groupID:doc['GroupID'], created:doc['created'],imageURL:doc['imageURL'],likes:doc['like'],isLike:isLike,isHidden: isHidden);
    this.isLike = isLike;
    return posts;
  }
  Future fetchUser(String id) async {
    final doc = await db.collection('users').document(id).get();
    final user = User(userID: id,name: doc['name'],iconURL: doc['iconURL']);
    this.user = user;
    this.loading = false;
    notifyListeners();
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
  Future addPost(String name, String text, String imageURL,String groupID) async {
    db.collection('posts').add({
      'name': name,
      'text': text,
      'imageURL': imageURL,
      'GroupID' : groupID,
      'like': 0,
      'commentCounts': 0,
      'created': FieldValue.serverTimestamp()
    }).then((docRef){
      function
          .getHttpsCallable(functionName: 'copyPost')
          .call({
        'postID': docRef.documentID,
      });
    });
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
    print(results.toString());
    final postIds = results.map((result) => result.objectID);
    List<Future<Post>> tasks = postIds.map((id) async {
      return _fetchMyPost(id);
    }).toList();
    final posts = await Future.wait(tasks);
    this.posts = posts.where((doc) => doc.isHidden != true).toList();
    print(posts.toString());
    this.searching = false;
    notifyListeners();
  }
  Future fetchLikePost(id) async {
    final doc = await db.collection('users').document(id).collection('likePost').getDocuments();
    final postIds = doc.documents.map((doc) => doc.documentID).toList();
    List<Future<Post>> tasks = postIds.map((id) async {
      return _fetchMyPost(id);
    }).toList();
    final likePost = await Future.wait(tasks);
    this.posts = likePost.where((doc) => doc.isHidden != true).toList();
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
  Future sendComment(Post post,String text) async {
    final user = await auth.currentUser();
    db.collection('posts').document(post.postID).collection('comments').add({
      'userID': user.uid,
      'groupID': post.groupID,
      'created': FieldValue.serverTimestamp(),
      'postID': post.postID,
      'text': text
    });
  }
  Future commentsDelete(Comment comment,Post post) async {
    await db.collection('posts').document(post.postID).collection('comments').document(comment.commentID).delete();
  }
  Future reportUser(String userID) async {
    final user = await auth.currentUser();
    await db.collection('users').document(user.uid).collection('reportUsers').document(userID).setData({
      'reporter': user.uid,
      'target': userID
    });
  }
  Future hiddenUser(String userID) async {
    final user = await auth.currentUser();
    await db.collection('users').document(user.uid).collection('hiddenUsers').document(userID).setData({
      'userID': userID
    });
  }
}