import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {

  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future signInGoogle() async {
    try {
      AuthResult result = await _auth.
    }
  }
}