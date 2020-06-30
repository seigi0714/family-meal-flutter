import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weight/models/Post.dart';
import 'package:weight/models/user.dart';
import 'package:weight/screen/User/user_model.dart';
import 'package:weight/screen/home/home.dart';
import 'package:weight/screen/home/home_model.dart';
import 'package:weight/screen/post/post_model.dart';

class PostSearch extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<PostModel>(
      create: (_) => PostModel(),
      child: Scaffold(
        appBar: AppBar(
          title: Text('投稿検索'),
        ),
        body: Consumer<PostModel>(builder: (context, model, child) {
          TextEditingController _searchText = TextEditingController(text: "");
          final posts = model.posts;
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
                  model.searchPost(_searchText.text);
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
                    :PostList(posts:model.posts),
              ),
            ],
          );
        }),
      ),
    );
  }
}
class PostList extends StatelessWidget {
  PostList({this.posts});
  final List<Post> posts;
  @override
  Widget build(BuildContext context) {
    final postList = posts.map((post) => Column(
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        PostHeader(groupID: post.groupID),
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
    ), ).toList();
    return ListView(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      children: postList,
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
            return
              (model.loading)
              ?
              Padding(
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
            )
            : Container();
          }
      ),
    );
  }
}

class postActions extends StatelessWidget {
  postActions({this.post});
  final Post post;
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<PostModel>(
      create: (_) =>PostModel(),
      child: Consumer<PostModel>(
          builder: (context, model, child) {
            return Padding(
              padding: EdgeInsets.all(0.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  (model.isLike)
                      ? IconButton(
                    icon: Icon(Icons.star),
                    onPressed: () async {
                      post.isLike = false;
                      await model.unLikePost(post);
                    },
                  )
                      : IconButton(
                    icon: Icon(Icons.star_border),
                    onPressed: () async {
                      post.isLike = true;
                      await model.likePost(post);
// いいねの処
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




