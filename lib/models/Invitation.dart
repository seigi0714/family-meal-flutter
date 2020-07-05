import 'package:cloud_firestore/cloud_firestore.dart';
class Invitation {
  Invitation({this.groupID,this.created});
  String groupID;
  final Timestamp created;
}