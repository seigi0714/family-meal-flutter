import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:weight/models/user.dart';

class Post {
  Post(this.postID,this.groupID,this.imageURL,this.created,this.likes);
  String postID;
  String groupID;
  String imageURL;
  final Timestamp created;
  int likes;
}
