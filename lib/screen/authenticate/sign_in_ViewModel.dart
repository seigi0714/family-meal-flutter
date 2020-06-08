import 'package:flutter/material.dart';
import 'package:weight/services/auth.dart';

class SignInForm extends ChangeNotifier {
  final AuthService _auth = AuthService();

  String currentEmail = "";
  String currentPassword = "";
  String error = "";

  void setCurrentEmail(String val) {
    currentEmail = val;
    notifyListeners();
  }
  void setCurrentPassword(String val) {
    currentPassword = val;
    notifyListeners();
  }
  //　ログイン処理
  void SignInAction(_currentEmail, _currentPassword) async {
    dynamic result = await _auth.signInWithEmailAndPassword(
        currentEmail, currentPassword);
    print(currentEmail);
    print(currentPassword);
    if (result == null) {
      error = 'ログイン失敗';
      notifyListeners();
    }
  }
  // 新規登録処理
  void RegisterAction(_currentEmail, _currenrPassword) async {
    dynamic result = await _auth.registerWithEmailAndPassword(currentEmail, currentPassword);
    if (result == null) {
      error = 'ログイン失敗';
      notifyListeners();
    }
  }
}
