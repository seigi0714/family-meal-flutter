import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weight/models/user.dart';
import 'package:weight/screen/home/home.dart';
import 'package:weight/screen/authenticate/sign_in.dart';



class Wrapper extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    // ⓵からuserの状態を受け取る
    final user = Provider.of<User>(context);
    if (user == null){
      return SignIn();
    } else {
      return Home();
    }
   }
}
