import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weight/models/user.dart';
import 'package:weight/screen/User/user_edit.dart';
import 'package:weight/screen/User/user_home.dart';
import 'package:weight/screen/User/user_model.dart';

class UserPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<UserModel>(
      create:(_) =>  UserModel()..setCurrentUser(),
      child: PageUser(),
    );
  }
}
class PageUser extends StatelessWidget {
  var userPages = [
    UserHome(),
    UserEdit(),
  ];
  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<UserModel>(context);
    return userPages[provider.currentPageIndex];
  }
}

