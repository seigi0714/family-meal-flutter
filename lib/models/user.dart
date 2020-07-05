import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  String userID;
  String name;
  String iconURL;
  bool isBelong;
  bool isInv;

  User({this.userID, this.name,this.iconURL,this.isBelong,this.isInv});
}

class UserData {
  final String userID;
  final String name;
  final Timestamp createAt;

  UserData({ this.userID, this.name, this.createAt});
}