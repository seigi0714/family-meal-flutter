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
  final TextEditingController emailEditController = TextEditingController();
  final TextEditingController nameEditController = TextEditingController();
  final TextEditingController passEditController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<SignInForm>(context);
    final user = Provider.of<User>(context);
    if (user == null){
      return Scaffold(
        appBar: AppBar(title: Text('新規登録')),
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            reverse: true,
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: <Widget>[
                    SizedBox(height: 20.0),
                    TextField(
                      decoration: textInputDecoration.copyWith(hintText: 'email'),
                      controller: emailEditController,
                      onChanged: (val) {
                        provider.currentEmail = val;
                      },
                    ),
                    SizedBox(height: 50.0),
                    TextField(
                      decoration: textInputDecoration.copyWith(hintText: 'name'),
                      controller: nameEditController,
                      onChanged: (text) {
                        provider.currentName = text;
                      },
                    ),
                    SizedBox(height: 50.0),
                    TextField(
                      obscureText: true,
                      decoration:
                      textInputDecoration.copyWith(hintText: 'password'),
                      controller: passEditController,
                      onChanged: (text) {
                        provider.currentPassword = text;
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
                          String email = provider.currentEmail;
                          String password = provider.currentPassword;
                          String name = provider.currentName;
                          context.read<SignInForm>().RegisterAction(email,name,password);
                      },
                    ),
                  ],
                ),
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
