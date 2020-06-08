import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weight/screen/authenticate/sign_in.dart';
import 'package:weight/services/auth.dart';
import 'dart:async';

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
}
