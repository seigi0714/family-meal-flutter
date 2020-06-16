import 'package:flutter/material.dart';
import 'package:weight/screen/group/group_model.dart';
import 'package:provider/provider.dart';
import 'package:weight/screen/group/add.dart';
import 'package:weight/screen/group/home.dart';


class GroupPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<GroupModel>(
        create: (_) => GroupModel(),
        child: PagesGroup(),
    );
  }
}

class PagesGroup extends StatelessWidget {
  var groupPages = [
    GroupHome(),
    GroupAdd(),
  ];
  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<GroupModel>(context);
    return Scaffold(
      body: groupPages[provider.currentPageIndex],
    );
  }
}

