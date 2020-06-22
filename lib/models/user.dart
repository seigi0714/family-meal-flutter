import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  String userID;
  String name;
  String iconURL;

  User({this.userID, this.name,this.iconURL});
}

class UserData {
  final String userID;
  final String name;
  final Timestamp createAt;

  UserData({ this.userID, this.name, this.createAt});
}