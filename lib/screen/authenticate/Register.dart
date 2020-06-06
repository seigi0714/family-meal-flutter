import 'package:weight/services/auth.dart';
import 'package:weight/shared/constants.dart';
import 'package:weight/screen/home/home.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class  Register extends StatefulWidget {
  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {

  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  String error = '';
  String email = '';
  String password = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
    appBar: AppBar(
       title: Text('新規登録'),
    ),
    body: Padding(
      padding: EdgeInsets.symmetric(vertical: 40.0, horizontal: 20.0),
      child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(10),
          ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  SizedBox(height: 20.0),
                  TextFormField(
                    decoration: textInputDecoration.copyWith(hintText: 'email'),
                    validator: (val) => val.isEmpty ? 'Enter an Email' : null,
                    onChanged: (val) {
                      setState(() => email = val);
                    },
                  ),
                  SizedBox(height: 20.0),
                  TextFormField(
                    decoration: textInputDecoration.copyWith(hintText: 'password'),
                    obscureText: true,
                    validator: (val) => val.length < 6  ? '6~12文字入力してください' : null,
                    onChanged: (val) => {
                      setState(() => password = val)
                    },
                  ),
                  SizedBox(height: 20.0),
                  RaisedButton(
                    color: Colors.amber,
                    child: Text(
                      '新規登録',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    elevation: 1.0,
                    shape: StadiumBorder(),
                    onPressed: () async {
                      if(_formKey.currentState.validate()) {
                        dynamic result = await _auth.registerWithEmailAndPassword(email, password);
                        if(result == null) {
                          setState((){
                            error = '登録に失敗しました';
                          });
                        }else{
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Home(),
                            ),
                          );
                        }
                      }
                    },
                  ),
                  SizedBox(height: 20.0),
                  Text(
                      error,
                      style: TextStyle(color: Colors.red, fontSize: 14.0)
                  )
                ],
              ),
            ),
            Text('Google ログインはこちら'),
            RaisedButton(
              child: Text('Googleアカウントで認証'),
              color: Colors.white,
              shape: StadiumBorder(
                  side: BorderSide(color: Colors.black26)
              ),
              onPressed: () async {
                dynamic result = await _auth.signInGoogle();
                if (result == null) {
                  print('signing error');
                } else {
                  print(result);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Home(),
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    ),
    );
  }
}
