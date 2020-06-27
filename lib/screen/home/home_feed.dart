import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weight/models/Post.dart';
import 'package:weight/screen/User/user_model.dart';
import 'package:weight/screen/home/home.dart';
import 'package:weight/screen/home/home_model.dart';
import 'package:weight/services/auth.dart';

class HomePage extends StatelessWidget {
  AuthService _auth = AuthService();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<HomeModel>(
      create: (_) => HomeModel()..fetchUser(),
      child: Scaffold(
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
        body: PostList(),
      ),
    );
  }
}

class PostList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<HomeModel>(
      create: (_) => HomeModel()..fetchUser(),
      child: Consumer<HomeModel>(builder: (context, model, child) {
        final groups = model.belongGroup;
        final posts = model.userPost;
        final postsCard = posts
            .map((post) => Card(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Padding(
                        padding:
                            const EdgeInsets.fromLTRB(16.0, 16.0, 8.0, 16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                // iconImage(group)
                                Container(
                                  height: 40.0,
                                  width: 40.0,
                                  decoration: new BoxDecoration(
                                    shape: BoxShape.circle,
                                    image: new DecorationImage(
                                        fit: BoxFit.fill,
                                        image: new NetworkImage(
                                            "https://so-sha.co.jp/cont/wp-content/themes/daishin-sosha/img/photo/menu/family/img02.png")),
                                  ),
                                ),
                                new SizedBox(
                                  width: 10.0,
                                ),
                                // groupname
                                new Text(
                                  "中村家",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                )
                              ],
                            ),
                            new IconButton(
                              icon: Icon(Icons.more_vert),
                              onPressed: null,
                            )
                          ],
                        ),
                      ),
                      // postImage
                      Flexible(
                        fit: FlexFit.loose,
                        child: Image.network(
                          post.imageURL,
                          fit: BoxFit.cover,
                        ),
                      ),
                      postActions(post: post),
                      Padding(
                        padding:
                            EdgeInsets.symmetric(vertical: 10, horizontal: 0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            new Text(
                              post.name,
                            ),
                            SizedBox(
                              width: 10.0,
                            ),
                            Text(post.text)
                          ],
                        ),
                      )
                    ],
                  ),
                ))
            .toList();
        return (posts.length == 0)
            ? Container(child: Text('グループをフォローしよう'))
            : ListView(
                children: postsCard,
              );
      }),
    );
  }
}

class postActions extends StatelessWidget {
  postActions({this.post});
  final Post post;
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<HomeModel>(
      create: (_) => HomeModel()..fetchUser(),
      child: Consumer<HomeModel>(
        builder: (context, model, child) {
          return Padding(
          padding: EdgeInsets.all(0.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              (post.isLike)
                  ? IconButton(
                icon: Icon(Icons.star),
                onPressed: () async {
                  post.isLike = false;
// いいねの処理
                  await model.unLikePost(post);
                  model.fetchUser();
                },
              )
                  : IconButton(
                icon: Icon(Icons.star_border),
                onPressed: () async {
                  post.isLike = true;
// いいねの処理
                  await model.likePost(post);
                  model.fetchUser();
                },
              ),
              Text('300'),
              SizedBox(
                width: 20.0,
              ),
              IconButton(
                icon: Icon(Icons.share),
                onPressed: () {},
              ),
            ],
          ),
    );
        }
      ),
    );
  }
}

