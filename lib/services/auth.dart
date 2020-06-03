import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  //グーグル認証
  Future<FirebaseUser> signInGoogle() async {
    try {
      GoogleSignInAccount googleUser = await _googleSignIn.signIn();
      GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      AuthCredential credential = GoogleAuthProvider.getCredential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      AuthResult authResult = await _auth.signInWithCredential(credential);
      FirebaseUser user = authResult.user;
      print("signed in " + user.displayName);
      return user;
    }catch(e) {
      print(e);
      return null;
    }
  }

  // ログアウト
  Future signOut() async {
    try {
      return await _auth.signOut();
    } catch(e){
      print(e.tostring());
      return null;
    }
  }
}