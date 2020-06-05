import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:weight/models/user.dart';

class DatabaseService {
  final String userID;
  DatabaseService({ this.userID });
  // usersコレクション
  final CollectionReference brewCollection = Firestore.instance.collection('users');

  Future<void> updateUserData(String name, int strength) async {
    return await brewCollection.document(userID).setData({
      'name': name,
      'strength': strength,
      'createAt': FieldValue.serverTimestamp(),
    });
  }
}