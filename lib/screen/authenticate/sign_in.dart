import 'package:flutter/material.dart';
import 'package:weight/services/auth.dart';

class SignIn extends StatefulWidget {
  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {

  final AuthService _auth = AuthService();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('SignIn'),
        ),
        body: Container(
          height: double.infinity,
          child: RaisedButton(
            child: Text('Googleアカウントで認証'),
            onPressed: () async {
              dynamic result = await _auth.signInGoogle();
              if (result == null) {
                print('signing error');
              }else {
                print('signin');
                print('result');
              }
            },
          ),
        ),
    );
  }
}
