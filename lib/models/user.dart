import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String userID;

  User({ this.userID});
}

class UserData {
  final String userID;
  final String name;
  final Timestamp createAt;

  UserData({ this.userID, this.name, this.createAt});
}