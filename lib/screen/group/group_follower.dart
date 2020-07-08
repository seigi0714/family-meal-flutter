import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weight/models/Group.dart';
import 'package:weight/models/user.dart';
import 'package:weight/screen/group/group_model.dart';

class GroupFollower extends StatelessWidget {
  GroupFollower({this.group});

  final Group group;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<GroupModel>(
        create: (_) => GroupModel()..getFollower(group),
        child: Scaffold(
            appBar: AppBar(
              title: Text(
                'フォロワー',
                style: TextStyle(color: Colors.white),
              ),
            ),
            body: Consumer<GroupModel>(builder: (context, model, child) {
              return model.users != null
                  ? FollowerList(context, model, group)
                  : Container(
                      child: Center(
                        child: Text('フォロワーがいません'),
                      ),
                    );
            })
        )
    );
  }
}

class FollowerList extends StatelessWidget {
  FollowerList(this.context, this.model, this.group);

  final BuildContext context;
  final GroupModel model;
  final Group group;

  @override
  Widget build(BuildContext context) {
    final users = model.users;
    final userList = users
        .map((user) =>
            Consumer<GroupModel>(builder: (context, model, snapshot) {
              return Card(
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
                      trailing: group.isBelong
                          ? user.isInv
                              ? FlatButton(
                                  color: Colors.amber,
                                  onPressed: () {},
                                  child: Text(
                                    '招待中',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  ))
                              : FlatButton(
                                  color: Colors.amber,
                                  onPressed: () {
                                    model.invUser(user.userID, group.groupID);
                                  },
                                  child: Text(
                                    '招待',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  ))
                          : Container(),
                      onTap: () async {}),
                ),
              );
            }))
        .toList();
    return ListView(
      children: userList,
    );
  }
}
