import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:weight/models/Comment.dart';
import 'package:weight/models/Post.dart';
import 'package:weight/screen/post/post_model.dart';

class PostComment extends StatelessWidget {
  PostComment({this.post});

  final Post post;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('コメント')),
        body: ChangeNotifierProvider<PostModel>(
          create: (_) => PostModel()..fetchPostComments(post),
          child: SingleChildScrollView(
            reverse: true,
            child: Consumer<PostModel>(builder: (context, model, child) {
              TextEditingController _comment = TextEditingController(text: "");
              return Column(
                children: <Widget>[
                  model.postComments.length == 0
                      ? SizedBox(
                          height: 10,
                        )
                      : commentList(context, model, post),
                  Stack(children: <Widget>[
                    TextField(
                      controller: _comment,
                      decoration: InputDecoration(hintText: "コメントを入力してください"),
                      onChanged: (text) {
                        model.commentText = text;
                      },
                    ),
                    Positioned(
                        right: 10,
                        child: IconButton(
                            icon: Icon(
                              Icons.send,
                              color: Colors.grey,
                            ),
                            onPressed: () async {
                              await addComments(model, context, post);
                            }))
                  ])
                ],
              );
            }),
          ),
        ));
  }
}

Widget commentList(BuildContext context, PostModel model, Post post) {
  final commentCards = model.postComments
      .map((comment) => Container(
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      CommentUser(
                        userID: comment.userID,
                        created: comment.created,
                      ),
                      SizedBox(width: 10),
                      Text(comment.text)
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      comment.isMine
                          ? IconButton(
                              icon: Icon(Icons.delete, color: Colors.grey),
                              onPressed: () async {
                                await deleteComments(
                                    model, context, comment, post);
                                await model.fetchPostComments(post);
                              })
                          : SizedBox(width: 10),
                      popUpMenu(model, context, comment.userID)
                    ],
                  )
                ]),
          ))
      .toList();
  return ListView(
    shrinkWrap: true,
    physics: NeverScrollableScrollPhysics(),
    children: commentCards,
  );
}

class CommentUser extends StatelessWidget {
  CommentUser({this.userID, this.created});

  final String userID;
  final DateTime created;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<PostModel>(
      create: (_) => PostModel()..fetchUser(userID),
      child: Consumer<PostModel>(builder: (context, model, child) {
        return model.loading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : Container(
                padding: EdgeInsets.all(10),
                child: Row(
                  children: <Widget>[
                    Container(
                      height: 40.0,
                      width: 40.0,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                            fit: BoxFit.fill,
                            image: NetworkImage(model.user.iconURL)),
                      ),
                    ),
                    SizedBox(width: 10),
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            model.user.name,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            DateFormat('yyyy/MM/dd').format(created),
                            style: TextStyle(color: Colors.grey),
                          )
                        ])
                  ],
                ),
              );
      }),
    );
  }
}

Future addComments(PostModel model, BuildContext context, Post post) async {
  try {
    await model.sendComment(post, model.commentText);
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('コメントしました！'),
          actions: <Widget>[
            FlatButton(
              child: Text('OK'),
              onPressed: () async {
                await model.fetchPostComments(post);
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

Future deleteComments(
    PostModel model, BuildContext context, Comment comment, Post post) async {
  try {
    await model.commentsDelete(comment, post);
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('コメントを削除しました'),
          actions: <Widget>[
            FlatButton(
              child: Text('OK'),
              onPressed: () async {
                Navigator.of(context).pop();
                await model.fetchPostComments(post);
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
Widget popUpMenu(PostModel model, BuildContext context, String userID) {
  return PopupMenuButton<String>(
    icon: Icon(
        Icons.more_vert,
      color: Colors.grey,
    ),
    onSelected: (String s) async {
      if (s == '通報') {
        await reportUser(model, context, userID);
      } else {
        await hiddenUser(model, context, userID);
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
Future reportUser(PostModel model, BuildContext context, String userID) async {
  try {
    await model.reportUser(userID);
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

Future hiddenUser(PostModel model, BuildContext context, String userID) async {
  try {
    await model.hiddenUser(userID);
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
