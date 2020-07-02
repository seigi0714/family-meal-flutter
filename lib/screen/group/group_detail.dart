import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weight/models/Group.dart';
import 'package:weight/models/Post.dart';
import 'package:weight/screen/group/group_model.dart';
import 'package:weight/screen/post/post_add.dart';
import 'package:weight/screen/post/post_model.dart';

class GroupDetail extends StatelessWidget {
  GroupDetail({this.group});

  final Group group;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<GroupModel>(
      create: (_) =>
      GroupModel()
        ..fetchPost(group),
      child: Consumer<GroupModel>(builder: (context, model, child) {
        return Scaffold(
            appBar: AppBar(
              title: Text(
                group.name,
                style: TextStyle(color: Colors.white),
              ),
              actions: <Widget>[
                FlatButton(
                    onPressed: () async {
                      await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) {
                            return PostAdd(group: group);
                          },
                        ),
                      );
                      model.getPosts(group.postIds);
                    },
                    child: Icon(
                      Icons.edit,
                      color: Colors.white,
                    ))
              ],
            ),
            body: Consumer<GroupModel>(builder: (context, model, child) {
              final List<Post> posts = model.posts;
              final imageList = posts
                  .map((post) =>
                  Container(
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
                                image: NetworkImage(group.iconURL)),
                          ),
                        ),
                        SizedBox(
                          width: 30,
                        ),
                        FlatButton(
                            onPressed: () {},
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text(
                                  group.userCount.toString(),
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
                            onPressed: () {},
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text(
                                  group.follower.toString(),
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
                  group.name,
                  style: TextStyle(
                    fontSize: 30,
                  ),
                ),
                Text(
                  group.text,
                  style: TextStyle(fontSize: 15, color: Colors.grey),
                ),
                GroupActions(group: group),
                SizedBox(
                  height: 20,
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
                ImageList(group: group)
              ]);
            }));
      }),
    );
  }
}

class GroupActions extends StatelessWidget {
  GroupActions({this.group});

  final Group group;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<GroupModel>(
        create: (_) =>
        GroupModel()
          ..getGroups(group.groupID),
        child: Consumer<GroupModel>(builder: (context, model, child) {
          final currentGroup = model.group;
          return (model.loading)
              ? Center(
            child: CircularProgressIndicator(),
          )
              : (currentGroup.isBelong)
              ? FlatButton(
              onPressed: null,
              child: Text(
                'プロフィール編集',
                style: TextStyle(color: Colors.indigo),
              ))
              : (currentGroup.isFollow)
              ? FlatButton(
              onPressed: () async {
                currentGroup.isFollow = false;
                await model.unFollowGroup(currentGroup.groupID);
              },
              child: Text(
                'フォローを解除',
                style: TextStyle(color: Colors.indigo),
              ))
              : FlatButton(
              onPressed: () async {
                currentGroup.isFollow = true;
                await model.followGroup(currentGroup.groupID);
              },
              child: Text(
                'グループをフォロー',
                style: TextStyle(color: Colors.indigo),
              ));
        }));
  }
}

class ImageList extends StatelessWidget {
  ImageList({this.group});

  final Group group;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<GroupModel>(
        create: (_) =>
        GroupModel()
          ..getPosts(group.postIds),
        child: Consumer<GroupModel>(builder: (context, model, child) {
          final posts = model.posts;
          final imageList = posts
              .map((post) =>
              Container(
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
        }));
  }
}
