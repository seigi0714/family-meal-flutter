class Comment {
  Comment({this.commentID,this.postID,this.userID,this.text,this.created,this.isGroupUser,this.isMine,this.isHidden});
  final String commentID;
  final String postID;
  final String userID;
  final String text;
  final DateTime created;
  final bool isGroupUser;
  final bool isMine;
  final bool isHidden;
}