import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weight/models/Group.dart';
import 'package:weight/screen/group/group_detail.dart';
import 'group_model.dart';

class GroupSearch extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<GroupModel>(
      create: (_) => GroupModel(),
      child: Scaffold(
        appBar: AppBar(
          title: Text('グループ検索', style: TextStyle(color: Colors.white)),
        ),
        body: Consumer<GroupModel>(builder: (context, model, child) {
          TextEditingController _searchText = TextEditingController(text: "");
          final groups =
              model.groups.where((group) => group.isHidden != true).toList();
          return ListView(
            children: <Widget>[
              TextField(
                controller: _searchText,
                decoration: InputDecoration(hintText: "Search query here..."),
              ),
              FlatButton(
                color: Colors.blue,
                child: Text(
                  "Search",
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () {
                  model.searchGroup(_searchText.text);
                },
              ),
              model.searching == true
                  ? groups.length == 0
                      ? Center(
                          child: Text("該当する投稿が見つかりませんでした"),
                        )
                      : GroupList(groups: groups)
                  : Center(
                      child: Text("Searching, please wait..."),
                    ),
            ],
          );
        }),
      ),
    );
  }
}

class GroupList extends StatelessWidget {
  GroupList({this.groups});

  final List<Group> groups;

  @override
  Widget build(BuildContext context) {
    final cards = groups
        .map((group) => Card(
            child: ListTile(
                leading: Container(
                  height: 60.0,
                  width: 60.0,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                        fit: BoxFit.fill, image: NetworkImage(group.iconURL)),
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
                })))
        .toList();
    return ListView(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      children: cards,
    );
  }
}
