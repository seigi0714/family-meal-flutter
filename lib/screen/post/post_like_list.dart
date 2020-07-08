import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weight/screen/User/user_model.dart';
import 'package:weight/screen/group/group_detail.dart';
import 'package:weight/screen/home/home_model.dart';
import 'package:weight/screen/post/post_model.dart';

class LikePostList extends StatelessWidget {
  LikePostList({this.uid});

  final String uid;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<PostModel>(
        create: (_) => PostModel()..fetchLikePost(uid),
        child: Scaffold(
          appBar: AppBar(
            title: Text(
              'いいねした投稿',
              style: TextStyle(
                color: Colors.white
              ),
            ),
          ),
          body: Consumer<PostModel>(builder: (context, model, child) {
            final posts = model.posts;
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
                                  image: NetworkImage(
                                      post.imageURL
                                  )),
                            ),
                          )
                              : Container(
                            height: 500,
                          ),
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
                          )
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
        ));
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
                              return GroupDetail(group:group);
                            },
                          ),
                        );
                      },
                      child: Row(
                        children: <Widget>[
                          // iconImage(group)
                          (group.iconURL != null)
                              ?
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
          }
      ),
    );
  }
}
