import 'package:flutter/material.dart';
import 'package:weight/services/auth.dart';
import 'package:weight/screen/home/home.dart';
import 'package:weight/shared/constants.dart';
import 'package:weight/screen/authenticate/Register.dart';

class SignIn extends StatefulWidget {
  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  String error = '';
  bool loading = false;

  //  textfield
  String email = '';
  String password = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('SignIn'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Container(
                padding: EdgeInsets.symmetric(vertical: 60.0, horizontal: 20.0),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.grey,
                    ),
                  ),
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: <Widget>[
                      SizedBox(height: 20.0),
                      TextFormField(
                        decoration:
                            textInputDecoration.copyWith(hintText: 'email'),
                        validator: (val) =>
                            val.isEmpty ? 'Enter an Email' : null,
                        onChanged: (val) {
                          setState(() => email = val);
                        },
                      ),
                      SizedBox(height: 20.0),
                      TextFormField(
                        obscureText: true,
                        decoration:
                            textInputDecoration.copyWith(hintText: 'password'),
                        validator: (val) =>
                            val.length < 6 ? '6~12文字入力してください' : null,
                        onChanged: (val) => {setState(() => password = val)},
                      ),
                      SizedBox(height: 20.0),
                      RaisedButton(
                        color: Colors.amber,
                        child: Text(
                          'ログイン',
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        elevation: 1.0,
                        shape: StadiumBorder(),
                        onPressed: () async {
                          if (_formKey.currentState.validate()) {
                            setState(() => loading = true);
                            dynamic result = await _auth
                                .signInWithEmailAndPassword(email, password);
                            if (result == null) {
                              setState(() {
                                loading = false;
                                error = 'ログイン失敗';
                              });
                            }
                          }
                        },
                      ),
                      SizedBox(height: 20.0),
                      FlatButton(
                          onPressed: (){
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => Register()),
                            );
                          },
                          child: Text(
                            '新規登録はこちら',
                            style: TextStyle(
                              color: Colors.indigo,
                            )
                          ),
                      ),
                      SizedBox(height: 20.0),
                      Text(error,
                          style: TextStyle(color: Colors.red, fontSize: 14.0))

                    ],
                  ),
                ),
              ),

              Container(
                  padding: const EdgeInsets.only(top: 30.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                    Text('Google ログインはこちら'),
                    RaisedButton(
                      child: Text('Googleアカウントで認証'),
                      color: Colors.white,
                      shape: StadiumBorder(
                          side: BorderSide(color: Colors.black26)),
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
                  ])),
            ],
          ),
        ),
      ),
    );
  }
}
