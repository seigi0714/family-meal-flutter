import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weight/screen/group/group_detail.dart';
import 'package:weight/screen/group/group_model.dart';

import 'add.dart';

class GroupHome extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<GroupModel>(
      create: (_) => GroupModel()..fetchMyGroups(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'FamilyMeal',
            style: TextStyle(color: Colors.white),
          ),
        ),
        body: Consumer<GroupModel>(
          builder: (context, model, child) {
            final groups = model.groups;
            final cards = groups
                .map((group) => Card(
                      child: ListTile(
                          leading: Container(
                            height: 60.0,
                            width: 60.0,
                            decoration: new BoxDecoration(
                              shape: BoxShape.circle,
                              image: new DecorationImage(
                                  fit: BoxFit.fill,
                                  image: new NetworkImage(group.iconURL)),
                            ),
                          ),
                          title: Text(
                            group.name,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            group.text,
                            style: TextStyle(fontSize: 10, color: Colors.grey),
                          ),
                          onTap: () async {
                            await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) {
                                  return GroupDetail(group: group);
                                },
                              ),
                            );
                      }
                    )))
                .toList();
            return ListView(
              children: cards,
            );
          },
        ),
        floatingActionButton: Consumer<GroupModel>(
            builder: (context, model, child) {
            return FloatingActionButton(
              child: Icon(Icons.add),
              onPressed: () async {
                await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) {
                      return GroupAdd();
                    },
                  ),
                );
                model.fetchMyGroups();
              },
            );
          }
        ),
      ),
    );
  }
}
