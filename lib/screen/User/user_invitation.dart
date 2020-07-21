import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weight/models/Group.dart';
import 'package:weight/models/user.dart';
import 'package:weight/screen/User/user_model.dart';
import 'package:weight/screen/group/group_model.dart';

class Invitation extends StatelessWidget {
  Invitation({this.group});

  final Group group;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<UserModel>(
      create: (_) => UserModel(),
      child: Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(
            color: Colors.white, //change your color here
          ),
          title: Text(
            'グループに招待',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
        ),
        body: Consumer<UserModel>(builder: (context, model, child) {
          TextEditingController _searchText = TextEditingController(text: "");
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
                  model.searchUser(_searchText.text, group.groupID);
                },
              ),
              Flex(direction: Axis.horizontal, children: [
                Expanded(
                  child: model.searching == false
                      ? Center(
                          child: Text("Searching, please wait..."),
                        )
                      : model.users == null
                          ? Center(
                              child: Text("該当する投稿が見つかりませんでした"),
                            )
                          : UserList(users: model.users, group: group),
                ),
              ]),
            ],
          );
        }),
      ),
    );
  }
}

class UserList extends StatelessWidget {
  UserList({this.users,this.group});

  final List<User> users;
  final Group group;

  @override
  Widget build(BuildContext context) {
    final userCards = users
        .map((user) => Consumer<UserModel>(builder: (context, model, snapshot) {
              return Card(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8,horizontal: 0),
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
                          trailing:
                          user.isInv
                              ? FlatButton(
                                  color: Colors.amber,
                                  onPressed: () {},
                                  child: Text(
                                    '招待中',
                                    style: TextStyle(
                                        color: Colors.white,
                                      fontWeight: FontWeight.bold
                                    ),
                                  )
                               )
                              : FlatButton(
                                  color: Colors.amber,
                                  onPressed: () async {
                                    await inv(model,context,user.userID,group.groupID);
                                  },
                                  child: Text(
                                    '招待',
                                    style: TextStyle(
                                        color: Colors.white,
                                      fontWeight: FontWeight.bold
                                    ),
                                  )),
                          onTap: () async {}
                          ),
                    ),
              );
            }))
        .toList();
    return ChangeNotifierProvider<UserModel>(
        create: (_) => UserModel(),
        child: Consumer<UserModel>(
          builder: (context,model,snapshot) {
            return ListView(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              children: userCards,
            );
          }
        )
    );
  }
}
Future inv(UserModel model, BuildContext context,String userID, String groupID) async {
  try {
    await model.invUser(userID,groupID);
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('招待しました'),
          actions: <Widget>[
            FlatButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
    Navigator.pop(context);
  } catch (e) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(e.toString()),
          actions: <Widget>[
            FlatButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
