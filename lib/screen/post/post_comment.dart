import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
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
          child: Consumer<PostModel>(builder: (context, model, child) {
            TextEditingController _comment = TextEditingController(text: "");
            return SingleChildScrollView(
              reverse: true,
              child: Column(
                children: <Widget>[
                  model.postComments == null
                      ? SizedBox(
                          height: 10,
                        )
                      : commentList(context, model,post),
                  Row(children: <Widget>[
                    TextField(
                      controller: _comment,
                      decoration: InputDecoration(hintText: "コメントを入力してください"),
                      onChanged: (text) {
                        model.commentText = text;
                      },
                    ),
                    RaisedButton(onPressed: () async {
                      await addComments(model, context, post);
                    })
                  ])
                ],
              ),
            );
          }),
        ));
  }
}

Widget commentList(BuildContext context, PostModel model,Post post) {
  final commentCards = model.postComments.map((comment) => Card(
        child: ListTile(
          leading: CommentUser(userID: comment.userID),
          title: Text(comment.text),
          trailing: IconButton(
              icon: Icon(Icons.delete),
              onPressed: () async {
                await deleteComments(model, context, comment,post);
              }),
        ),
      ));
  return ListView();
}

class CommentUser extends StatelessWidget {
  CommentUser({this.userID});

  final String userID;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<PostModel>(
      create: (_) => PostModel()..fetchUser(userID),
      child: Consumer<PostModel>(builder: (context, model, child) {
        return model.loading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : Row(
                children: <Widget>[
                  Container(
                    height: 60.0,
                    width: 60.0,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                          fit: BoxFit.fill,
                          image: NetworkImage(model.user.iconURL)),
                    ),
                  ),
                  Text(model.user.name)
                ],
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
          title: Text('保存しました！'),
          actions: <Widget>[
            FlatButton(
              child: Text('OK'),
              onPressed: () async {
                await model.fetchPostComments(post);
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
Future deleteComments(PostModel model, BuildContext context, Comment comment,Post post) async {
  try {
    await model.commentsDelete(comment,post);
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('保存しました！'),
          actions: <Widget>[
            FlatButton(
              child: Text('OK'),
              onPressed: () async {
                await model.fetchPostComments(post);
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
