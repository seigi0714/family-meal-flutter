import 'package:flutter/material.dart';
import 'package:weight/services/auth.dart';

class Home extends StatelessWidget {
  final AuthService _auth = AuthService();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('HomePage'),
        actions: <Widget>[
          FlatButton(
            child:Text('ログアウト'),
            onPressed: () async{
              await _auth.signOut();
            },
          )
        ],

      ),
    );
  }
}
