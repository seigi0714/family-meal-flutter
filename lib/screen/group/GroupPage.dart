import 'package:flutter/material.dart';
import 'package:weight/screen/group/group_detail.dart';
import 'package:weight/screen/group/group_model.dart';
import 'package:provider/provider.dart';
import 'package:weight/screen/group/add.dart';
import 'package:weight/screen/group/home.dart';


class GroupPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GroupHome();
  }
}

class PagesGroup extends StatelessWidget {
  var groupPages = [
    GroupAdd(),
    GroupDetail(),
  ];
  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<GroupModel>(context);
    final groupHome = GroupHome();
    return groupHome;
  }
}

