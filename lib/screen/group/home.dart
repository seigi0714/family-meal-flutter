import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weight/screen/group/group_detail.dart';
import 'package:weight/screen/group/group_model.dart';

import 'add.dart';
import 'group_search.dart';

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
                      decoration:BoxDecoration(
                        shape: BoxShape.circle,
                        image:DecorationImage(
                            fit: BoxFit.fill,
                            image:NetworkImage(group.iconURL)),
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
              children: <Widget>[
                Container(
                  child: FlatButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => GroupSearch()),
                      );
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text('ステキなグループを探そう！'),
                        Icon(Icons.search)
                      ],
                    ),
                  ),
                ),
                ListView(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  children: cards,
                ),
              ],
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
                  }
              );
            }
        ),
      ),
    );
  }
}
