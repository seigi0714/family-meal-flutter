import 'package:provider/provider.dart';
import 'package:weight/screen/home/home.dart';
import 'package:weight/services/auth.dart';
import 'package:provider/provider.dart';
import 'package:weight/screen/authenticate/sign_in_ViewModel.dart';
import 'package:weight/shared/constants.dart';
import 'package:flutter/material.dart';
import 'package:weight/models/user.dart';


class Register extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
     final AuthService _auth = AuthService();
    return ChangeNotifierProvider<SignInForm>(
      create: (context) => SignInForm(),
      child: RegisterPage(),
    );
  }
}
class RegisterPage extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<SignInForm>(context);
    final user = Provider.of<User>(context);
    if (user == null){
      return Scaffold(
        appBar: AppBar(title: Text('新規登録')),
        body: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  SizedBox(height: 20.0),
                  TextFormField(
                    decoration: textInputDecoration.copyWith(hintText: 'email'),
                    validator: (val) => val.isEmpty ? 'Enter an Email' : null,
                    onChanged: (val) {
                      provider.currentEmail = val;
                    },
                  ),
                  SizedBox(height: 50.0),
                  TextFormField(
                    obscureText: true,
                    decoration:
                    textInputDecoration.copyWith(hintText: 'password'),
                    validator: (val) =>
                    val.length < 6 ? '6~12文字入力してください' : null,
                    onChanged: (val) {
                      provider.currentPassword = val ;
                    },
                  ),
                  SizedBox(
                    height: 50.0,
                  ),
                  RaisedButton(
                    color: Colors.amber,
                    child: Text(
                      '新規登録',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    elevation: 1.0,
                    shape: StadiumBorder(),
                    onPressed: ()  {
                      if (_formKey.currentState.validate()) {
                        String email = provider.currentEmail;
                        String password = provider.currentPassword;
                        context.read<SignInForm>().RegisterAction(email, password);
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    } else {
      return Home();
    }
  }
}
