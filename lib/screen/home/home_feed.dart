import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weight/models/Post.dart';
import 'package:weight/screen/User/user_model.dart';
import 'package:weight/screen/home/home.dart';
import 'package:weight/screen/home/home_model.dart';
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
                      : PostList(posts: posts)
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
                      PostHeader(groupID: post.groupID,),
                      // postImage
                      Flexible(
                        fit: FlexFit.loose,
                        child: Image.network(
                          post.imageURL,
                          fit: BoxFit.cover,
                        ),
                      ),
                      PostActions(post: post),
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
        return ListView(
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
      child: Consumer<HomeModel>(
        builder: (context,model,child) {
          final group = model.group;
          return Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 16.0, 8.0, 16.0),
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
                                group.iconURL
                            )),
                      ),
                    ),
                    new SizedBox(
                      width: 10.0,
                    ),
                    // groupname
                    new Text(
                      group.name,
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
          );
        }
      ),
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
      }),
    );
  }
}
