import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weight/models/Post.dart';
import 'package:weight/screen/post/post_model.dart';

class PostComment extends StatelessWidget {
  PostComment({this.post});
  final Post post;

  @override
  Widget build(BuildContext context) {
    final bool isComment = post.commentCounts != 0;
    return Scaffold(
      appBar: AppBar(
        title: Text('コメント')
      ),
      body: ChangeNotifierProvider<PostModel>(
          create: (_) => PostModel()..fetchPostComments(post),
        child: Consumer(
            builder: (context,model,child){
              return Container();
            }
        ),
      )
    );
  }
}
