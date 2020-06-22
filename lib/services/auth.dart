import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:weight/services/database.dart';
import 'package:weight/models/user.dart';

class AuthService {
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User _userFromFirebaseUser(FirebaseUser user) {
     return user != null ? User(userID: user.uid) : null;
  }
// userのログイン状況を表す⓵
  Stream<User> get user {
    return _auth.onAuthStateChanged
        .map((FirebaseUser user) => _userFromFirebaseUser(user));
  }
  // email&password register
   Future registerWithEmailAndPassword(String email,String name, String password) async {
       try {
         AuthResult result = await _auth.createUserWithEmailAndPassword(email: email, password: password);
         FirebaseUser user = result.user;
         String iconURL = 'https://lh3.googleusercontent.com/ogw/ADGmqu-lCe3avbX9Wvvi6fuveBxkGxZ7NfPReFDdtTYy=s64-c-mo';
         await DatabaseService(userID: user.uid).updateUserData(name,iconURL);
         return _userFromFirebaseUser(user);
       }catch (error) {
         print(error.toString());
         return null;
       }
   }
  // email sign i
  Future signInWithEmailAndPassword(String email, String password) async {
    try {
      AuthResult result = await _auth.signInWithEmailAndPassword(email: email, password: password);
      FirebaseUser user = result.user;
      return user;
    } catch (error) {
      print(error.toString());
      return null;
    }
  }

  //グーグル認証
  Future<FirebaseUser> signInGoogle() async {
    try {
      GoogleSignInAccount googleUser = await _googleSignIn.signIn();
      GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      AuthCredential credential = GoogleAuthProvider.getCredential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      FirebaseUser user = (await _auth.signInWithCredential(credential)).user;
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
      print('logout');
    } catch(e){
      print(e.tostring());
      return null;
    }
  }
}