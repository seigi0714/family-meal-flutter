import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'group_model.dart';

class GroupSearch extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<GroupModel>(
      create: (_) => GroupModel(),
      child: Scaffold(
        appBar: AppBar(
          title: Text('投稿検索'),
        ),
        body: Consumer<GroupModel>(builder: (context, model, child) {
          TextEditingController _searchText = TextEditingController(text: "");
          final groups = model.groups;
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
                  model.searching = true;
                  model.searchGroup(_searchText.text);
                },
              ),
              Expanded(
                child: model.searching == true
                    ? Center(
                  child: Text("Searching, please wait..."),
                )
                    : model.posts.length == 0
                    ? Center(
                  child: Text("該当する投稿が見つかりませんでした"),
                )
                    : Container(),
              ),
            ],
          );
        }),
      ),
    );
  }
}
