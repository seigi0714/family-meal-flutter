import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weight/models/Group.dart';
import 'package:weight/screen/group/group_model.dart';
import 'package:weight/screen/post/post_like_list.dart';

class GroupMember extends StatelessWidget {
  GroupMember({this.group});
  final Group group;
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<GroupModel>(
      create: (_) => GroupModel()..getMember(group),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'メンバー',
            style: TextStyle(
              color: Colors.white
            ),
          ),
        ),
        body: Consumer<GroupModel>(builder: (context, model, child) {
          return model.users != null
              ? MemberList(context, model)
              : Container(
            child: Center(
              child: Text('フォロワーがいません'),
            ),
          );
        }),
      ),
    );
  }
}

class MemberList extends StatelessWidget {
  MemberList(this.context,this.model);
  final BuildContext context;
  final GroupModel model;
  @override
  Widget build(BuildContext context) {
    final users = model.users;
    final userList = users
        .map((user) =>
          Card(
            child: Padding(
              padding:
              const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
              child: ListTile(
                  leading: Container(
                    height: 60.0,
                    width: 60.0,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                          fit: BoxFit.fill,
                          image: NetworkImage(user.iconURL)),
                    ),
                  ),
                  title: Text(
                    user.name,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                onTap: () async {}
            ),
          )
        ))
        .toList();
    return ListView(
      children: userList,
    );
  }
}
