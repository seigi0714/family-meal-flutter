import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weight/models/user.dart';
import 'package:weight/screen/group/GroupPage.dart';
import 'package:weight/screen/group/add.dart';
import 'package:weight/screen/group/home.dart';
import 'package:weight/screen/home/BottomNavigation.dart';
import 'package:weight/screen/User/user_edit.dart';
import 'package:weight/screen/User/user_model.dart';

class UserHome extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<UserModel>(context);
    return ChangeNotifierProvider<UserModel>(
      create: (_) => UserModel()..setCurrentUser(),
      child: Scaffold(
        appBar: AppBar(
          title: Text('aaa'),
        ),
        body: Consumer<UserModel>(
          builder: (context, model, child) {
            final user = model.currentUser;
            if (user != null) {
              return Container(
                height: double.infinity,
                child: Center(
                  child: Column(
                    children: <Widget>[
                      SizedBox(
                        height: 20,
                      ),
                      Container(
                        height: 90.0,
                        width: 90.0,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            fit: BoxFit.fill,
                            image: NetworkImage(user.iconURL),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        model.currentUserName,
                        style: TextStyle(
                          fontSize: 20,
                        ),
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Container(
                        height: 350,
                        padding: EdgeInsets.all(15),
                        child: GridView(
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 15,
                            childAspectRatio: 1.5,
                          ),

                          children: <Widget>[
                            Card(child: FlatButton(
                                child: Text('プロフィール編集'),
                                onPressed: () async {
                                  await Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) {
                                        return UserEdit();
                                      },
                                    ),
                                  );
                                  model.setCurrentUser();
                                })
                            ),
                            Card(child: FlatButton(
                                onPressed: () async {
                                  await Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) {
                                        return GroupPage();
                                      },
                                    ),
                                  );
                                },
                                child: Text('グループ'))),
                            Card(child: FlatButton(child: Text('フォロー'))),
                            Card(child: FlatButton(child: Text('お気に入り'))),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            } else {
              return Center(child: CircularProgressIndicator());
            } // ignore: missing_return
          },
        ),
      ),
    );
  }
}
