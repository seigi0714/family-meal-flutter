import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:weight/models/user.dart';

class DatabaseService {
  final String userID;
  DatabaseService({ this.userID });
  // usersコレクション
  final CollectionReference brewCollection = Firestore.instance.collection('users');

  Future<void> updateUserData(String name,String iconURL) async {
    return await brewCollection.document(userID).setData({
      'name': name,
      'iconURL': iconURL,
      'createAt': FieldValue.serverTimestamp(),
    });
  }
}