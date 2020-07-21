class Group {
  Group({this.groupID,this.name, this.text, this.iconURL, this.userID,this.userCount,this.follower,this.postIds,this.isBelong,this.isFollow,this.isHidden});
 String groupID;
  String name;
  String text;
  String iconURL;
  String userID;
  int userCount;
  int follower;
  List postIds;
  bool isBelong;
  bool isFollow;
  bool isHidden;
}