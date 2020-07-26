import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weight/models/Group.dart';
import 'package:weight/models/Post.dart';
import 'package:weight/screen/User/user_model.dart';
import 'package:weight/screen/group/group_detail.dart';
import 'package:weight/screen/home/home.dart';
import 'package:weight/screen/home/home_model.dart';
import 'package:weight/screen/post/post_comment.dart';
import 'package:weight/screen/post/post_search.dart';
import 'package:weight/services/auth.dart';

class HomePage extends StatelessWidget {
  AuthService _auth = AuthService();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<HomeModel>(
        create: (_) => HomeModel()..fetchFeedPost(),
        child: Consumer<HomeModel>(builder: (context, model, child) {
          final groups = model.belongGroup;
          final posts = model.userPost;
          return Scaffold(
              appBar: AppBar(
                title: Text(
                  'familyMeal',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
                actions: <Widget>[
                  FlatButton(
                    onPressed: () async {
                      await _auth.signOut();
                    },
                    child: Text(
                      "ログアウト",
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              body: (model.loading)
                  ? (posts.length == 0)
                      ? Container(
                          child: FlatButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => PostSearch()),
                              );
                            },
                            child: Row(
                              children: <Widget>[
                                Text('お気に入りの写真を見つけに行こう'),
                                Icon(Icons.search)
                              ],
                            ),
                          ),
                        )
                      : ListView(
                          children: <Widget>[
                            Container(
                              child: FlatButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => PostSearch()),
                                  );
                                },
                                child: Row(
                                  children: <Widget>[
                                    Text('お気に入りの写真を見つけに行こう'),
                                    Icon(Icons.search)
                                  ],
                                ),
                              ),
                            ),
                            PostList(posts: posts),
                          ],
                        )
                  : Center(
                      child: Container(child: CircularProgressIndicator())));
        }));
  }
}

class PostList extends StatelessWidget {
  PostList({this.posts});

  List<Post> posts;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<HomeModel>(
      create: (_) => HomeModel(),
      child: Consumer<HomeModel>(builder: (context, model, child) {
        final groups = model.belongGroup;
        final postsCard = posts
            .map((post) => Card(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      PostHeader(
                        groupID: post.groupID,
                      ),
                      // postImage
                      (post.imageURL != null)
                          ? Container(
                              height: 500,
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                    fit: BoxFit.fill,
                                    image: NetworkImage(post.imageURL)),
                              ),
                            )
                          : Container(),
                      PostActions(post: post),
                      Padding(
                        padding:
                            EdgeInsets.symmetric(vertical: 10, horizontal: 0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              post.name,
                            ),
                            SizedBox(
                              width: 10.0,
                            ),
                            Text(post.text)
                          ],
                        ),
                      ),
                    ],
                  ),
                ))
            .toList();
        return ListView(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          children: postsCard,
        );
      }),
    );
  }
}

class PostHeader extends StatelessWidget {
  PostHeader({this.groupID});

  final String groupID;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<HomeModel>(
      create: (_) => HomeModel()..getGroup(groupID),
      child: Consumer<HomeModel>(builder: (context, model, child) {
        final group = model.group;
        return (model.loading)
            ? Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 16.0, 8.0, 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    InkWell(
                      onTap: () async {
                        await Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) {
                              return GroupDetail(group: group);
                            },
                          ),
                        );
                      },
                      child: Row(
                        children: <Widget>[
                          // iconImage(group)
                          (group.iconURL != null)
                              ? Container(
                                  height: 40.0,
                                  width: 40.0,
                                  decoration: new BoxDecoration(
                                    shape: BoxShape.circle,
                                    image: new DecorationImage(
                                        fit: BoxFit.fill,
                                        image: new NetworkImage(group.iconURL)),
                                  ),
                                )
                              : Container(),
                          new SizedBox(
                            width: 10.0,
                          ),
                          // groupname
                          Text(
                            group.name,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              )
            : Container();
      }),
    );
  }
}

class PostActions extends StatelessWidget {
  PostActions({this.post});

  final Post post;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<HomeModel>(
      create: (_) => HomeModel()..fetchUser(),
      child: Consumer<HomeModel>(builder: (context, model, child) {
        return Padding(
          padding: EdgeInsets.all(0.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              (post.isLike)
                  ? IconButton(
                      icon: Icon(
                        Icons.star,
                        color: Colors.amber,
                      ),
                      onPressed: () async {
                        post.isLike = false;
                        // いいねの処理
                        await model.unLikePost(post);
                        model.fetchUser();
                      },
                    )
                  : IconButton(
                      icon: Icon(
                        Icons.star_border,
                        color: Colors.amber,
                      ),
                      onPressed: () async {
                        post.isLike = true;
// いいねの処理
                        await model.likePost(post);
                        model.fetchUser();
                      },
                    ),
              Text(post.likes.toString()),
              SizedBox(
                width: 10.0,
              ),
              IconButton(
                  icon: Icon(
                      Icons.comment,
                      color: Colors.amber),
                onPressed: () async {
                  await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) {
                        return PostComment(post: post);
                      },
                    ),
                  );
                },
              ),
              Text(post.commentCounts.toString())
            ],
          ),
        );
      }),
    );
  }
}
Widget popUpMenu(HomeModel model, BuildContext context, Group group) {
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
Future reportGroup(HomeModel model, BuildContext context, Group group) async {
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
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
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
Future hiddenGroup(HomeModel model, BuildContext context, Group group) async {
  try {
    await model.hiddenGroup(group);
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('対象のグループをブロックしました'),
          actions: <Widget>[
            FlatButton(
              child: Text('OK'),
              onPressed: () {
                model.fetchFeedPost();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
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