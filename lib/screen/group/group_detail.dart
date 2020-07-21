import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weight/models/Group.dart';
import 'package:weight/models/PopUpMenu.dart';
import 'package:weight/models/Post.dart';
import 'package:weight/screen/User/user_invitation.dart';
import 'package:weight/screen/group/add.dart';
import 'package:weight/screen/group/group_model.dart';
import 'package:weight/screen/post/post_add.dart';
import 'package:weight/screen/post/post_model.dart';
import 'package:weight/screen/Report/report_page.dart';

import 'group_follower.dart';
import 'group_member.dart';

class GroupDetail extends StatelessWidget {
  GroupDetail({this.group});

  final Group group;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<GroupModel>(
      create: (_) => GroupModel()..getGroups(group.groupID),
      child: Consumer<GroupModel>(builder: (context, model, child) {
        return model.loading
            ? Scaffold(
                appBar: AppBar(
                  title: Text(
                    model.group.name,
                    style: TextStyle(color: Colors.white),
                  ),
                  actions: <Widget>[
                    model.group.isBelong
                        ? IconButton(
                            padding: EdgeInsets.all(0),
                            onPressed: () async {
                              await Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) {
                                    return PostAdd(group: model.group);
                                  },
                                ),
                              );
                              model.getGroups(model.group.groupID);
                            },
                            icon: Icon(
                              Icons.edit,
                              color: Colors.white,
                            ))
                        : Container(),
                    popUpMenu(model, context, group)
                  ],
                ),
                body: Consumer<GroupModel>(builder: (context, model, child) {
                  final List<Post> posts = model.posts;
                  final imageList = posts
                      .map((post) => Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.black),
                              image: DecorationImage(
                                image: NetworkImage(post.imageURL),
                                fit: BoxFit.fill,
                              ),
                            ),
                          ))
                      .toList();
                  return ListView(children: <Widget>[
                    SizedBox(
                      height: 20,
                    ),
                    Container(
                      height: 100,
                      width: double.infinity,
                      padding: EdgeInsets.only(
                        left: 15,
                      ),
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: <Widget>[
                            Container(
                              height: 90.0,
                              width: 90.0,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                image: DecorationImage(
                                    fit: BoxFit.fill,
                                    image: NetworkImage(model.group.iconURL)),
                              ),
                            ),
                            SizedBox(
                              width: 30,
                            ),
                            FlatButton(
                                onPressed: () async {
                                  await Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) {
                                        return GroupFollower(group: group);
                                      },
                                    ),
                                  );
                                },
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Text(
                                      model.group.follower.toString(),
                                      style: TextStyle(
                                        fontSize: 15,
                                      ),
                                    ),
                                    Text(
                                      'フォロワー',
                                      style: TextStyle(
                                        fontSize: 15,
                                      ),
                                    )
                                  ],
                                )),
                            FlatButton(
                                onPressed: () async {
                                  await Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) {
                                        return GroupMember(group: group);
                                      },
                                    ),
                                  );
                                },
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Text(
                                      model.group.userCount.toString(),
                                      style: TextStyle(
                                        fontSize: 15,
                                      ),
                                    ),
                                    Text(
                                      'メンバー',
                                      style: TextStyle(
                                        fontSize: 15,
                                      ),
                                    ),
                                  ],
                                ))
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      model.group.name,
                      style: TextStyle(
                        fontSize: 30,
                      ),
                    ),
                    Text(
                      model.group.text,
                      style: TextStyle(fontSize: 15, color: Colors.grey),
                    ),
                    (model.group.isBelong)
                        ? Column(
                            children: <Widget>[
                              Container(
                                child: FlatButton(
                                    onPressed: () async {
                                      await Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) {
                                            return GroupAdd(group: model.group);
                                          },
                                        ),
                                      );
                                      model.getGroups(model.group.groupID);
                                    },
                                    child: Text(
                                      'プロフィール編集',
                                      style: TextStyle(color: Colors.indigo),
                                    )),
                              ),
                              RaisedButton(
                                  child: Text(
                                    "メンバーを招待",
                                    style: TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                  color: Colors.amber,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  onPressed: () async {
                                    await Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) {
                                          return Invitation(group: model.group);
                                        },
                                      ),
                                    );
                                  }),
                            ],
                          )
                        : (model.isFollow)
                            ? FlatButton(
                                onPressed: () async {
                                  model.isFollow = false;
                                  await model
                                      .unFollowGroup(model.group.groupID);
                                },
                                child: Text(
                                  'フォローを解除',
                                  style: TextStyle(color: Colors.indigo),
                                ))
                            : FlatButton(
                                onPressed: () async {
                                  model.isFollow = true;
                                  await model.followGroup(model.group.groupID);
                                },
                                child: Text(
                                  'グループをフォロー',
                                  style: TextStyle(color: Colors.indigo),
                                )),
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      height: 40,
                      width: double.infinity,
                      decoration: BoxDecoration(
                          border: Border.symmetric(
                              vertical: BorderSide(color: Colors.grey))),
                      child: Center(
                        child: Text(
                          '投稿一覧',
                          style: TextStyle(fontSize: 30, color: Colors.grey),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    ImageList(group: model.group)
                  ]);
                }))
            : Container(
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              );
      }),
    );
  }
}

class GroupActions extends StatelessWidget {
  GroupActions({this.group, this.model, this.context});

  final Group group;
  final GroupModel model;
  final BuildContext context;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<GroupModel>(
        create: (_) => GroupModel(),
        child: (model.group.isBelong)
            ? Column(
                children: <Widget>[
                  Container(
                    child: FlatButton(
                        onPressed: () async {
                          await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) {
                                return GroupAdd(group: model.group);
                              },
                            ),
                          );
                          model.getGroups(model.group.groupID);
                        },
                        child: Text(
                          'プロフィール編集',
                          style: TextStyle(color: Colors.indigo),
                        )),
                  ),
                  RaisedButton(
                      child: Text(
                        "メンバーを招待",
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      color: Colors.amber,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      onPressed: () async {
                        await Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) {
                              return Invitation(group: model.group);
                            },
                          ),
                        );
                      }),
                ],
              )
            : (model.group.isFollow)
                ? FlatButton(
                    onPressed: () async {
                      model.group.isFollow = false;
                      await model.unFollowGroup(model.group.groupID);
                    },
                    child: Text(
                      'フォローを解除',
                      style: TextStyle(color: Colors.indigo),
                    ))
                : FlatButton(
                    onPressed: () async {
                      model.group.isFollow = true;
                      await model.followGroup(model.group.groupID);
                    },
                    child: Text(
                      'グループをフォロー',
                      style: TextStyle(color: Colors.indigo),
                    )));
  }
}

class ImageList extends StatelessWidget {
  ImageList({this.group});

  final Group group;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<GroupModel>(
        create: (_) => GroupModel()..fetchPost(group),
        child: Consumer<GroupModel>(builder: (context, model, child) {
          return model.posts != null ? ImageView(model) : Container();
        }));
  }
}

class ImageView extends StatelessWidget {
  ImageView(this.model);

  final GroupModel model;

  @override
  Widget build(BuildContext context) {
    final posts = model.posts;
    final imageList = posts
        .map((post) => Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black),
                image: DecorationImage(
                  image: NetworkImage(post.imageURL),
                  fit: BoxFit.fill,
                ),
              ),
            ))
        .toList();
    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: 4,
      crossAxisSpacing: 4.0,
      // 縦スペース
      mainAxisSpacing: 4.0,
      children: imageList,
    );
  }
}

Widget popUpMenu(GroupModel model, BuildContext context, Group group) {
  return PopupMenuButton<String>(
    icon: Icon(Icons.menu),
    onSelected: (String s) async {
      if (s == '通報') {
        await reportGroup(model, context, group);
      } else {
        await hiddenGroup(model, context, group);
      }
    },
    itemBuilder: (BuildContext context) {
      final List<String> _items = ['通報', '非表示'];
      return _items.map((String s) {
        return PopupMenuItem(
          child: Text(s),
          value: s,
        );
      }).toList();
    },
  );
}

Future reportGroup(GroupModel model, BuildContext context, Group group) async {
  try {
    await model.reportGroup(group);
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('通報'),
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
    Navigator.of(context).pop();
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

Future hiddenGroup(GroupModel model, BuildContext context, Group group) async {
  try {
    await model.hiddenGroup(group);
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('ブロック'),
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
    Navigator.of(context).pop();
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
