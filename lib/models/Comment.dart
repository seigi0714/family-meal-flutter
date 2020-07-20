class Comment {
  Comment({this.commentID,this.postID,this.userID,this.text,this.created,this.isGroupUser});
  final String commentID;
  final String postID;
  final String userID;
  final String text;
  final String created;
  final bool isGroupUser;
}