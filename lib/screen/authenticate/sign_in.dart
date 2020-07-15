import 'package:flutter/material.dart';
import 'package:weight/services/auth.dart';
import 'package:weight/screen/authenticate/sign_in_ViewModel.dart';
import 'package:weight/shared/constants.dart';
import 'package:weight/screen/authenticate/Register.dart';
import 'package:provider/provider.dart';

class SignIn extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final AuthService _auth = AuthService();
    return ChangeNotifierProvider<SignInForm>(
      create: (context) => SignInForm(),
      child: SignInFormPage(),
    );
  }
}
class SignInFormPage extends StatelessWidget {
  final TextEditingController emailTextEditController = TextEditingController();
  final TextEditingController passTextEditController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<SignInForm>(context);
    return Scaffold(
      appBar: AppBar(title: Text('SignIn')),
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
                    controller: emailTextEditController,
                    onChanged: (text) {
                      provider.currentEmail = text;
                    },
                  ),
                  SizedBox(height: 50.0),
                  TextField(
                    obscureText: true,
                    decoration:
                    textInputDecoration.copyWith(hintText: 'password'),
                    controller: passTextEditController,
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
                      'ログイン',
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
                        context.read<SignInForm>().SignInAction(email, password);
                    },
                  ),
                  SizedBox(
                    height: 30.0,
                  ),
                  errorText(),
                  SizedBox(height: 20.0),
                  FlatButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Register()),
                      );
                    },
                    child: Text('新規登録はこちら',
                        style: TextStyle(
                          color: Colors.indigo,
                        )),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class SignInButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SignInForm>(context, listen: false);
    // currentEmailの状態
    final currentEmail = context.watch<SignInForm>().currentEmail;
    // PassWordの今の状態
    final currentPassword = context.watch<SignInForm>().currentPassword;
    return RaisedButton(
      color: Colors.amber,
      child: Text(
        'ログイン',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      elevation: 1.0,
      shape: StadiumBorder(),
      onPressed: () async {
          provider.SignInAction(currentEmail, currentPassword);
      },
    );
  }
}

class errorText extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<SignInForm>(
      builder: (context, SignInForm, child) {
        return Text(
          SignInForm.error,
          style: TextStyle(color: Colors.red, fontSize: 14.0),
        );
      },
    );
  }
}
