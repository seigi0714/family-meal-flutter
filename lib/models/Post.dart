import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:weight/models/user.dart';

class Post {
  Post({this.name,this.text,this.postID,this.groupID,this.imageURL,this.created,this.likes,this.isLike,this.isHidden});
  String name;
  String text;
  String postID;
  String groupID;
  String imageURL;
  final Timestamp created;
  int likes;
  bool isLike;
  bool isHidden;
}
