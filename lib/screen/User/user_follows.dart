import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weight/screen/User/user_model.dart';
import 'package:weight/screen/group/group_detail.dart';

class FollowList extends StatelessWidget {
  FollowList({this.uid});
  final String uid;

  @override
  Widget build(BuildContext context) {
    /*final provider = Provider.of<UserModel>(context);*/
    return Scaffold(
      appBar: AppBar(
        title: Text(
            'フォロー',
          style: TextStyle(
            color: Colors.white
          ),
        ),
      ),
      body: ChangeNotifierProvider<UserModel>(
          create: (_) => UserModel()..getFollowGroups(uid),
        child:
          Consumer<UserModel>(
          builder: (context, model,child) {
            return model.followList != null
                ? FollowingList()
            : Container(
            child: Text('フォローしているグループがありません'),
            );
          }
        )
      ),
    );
  }
}

class FollowingList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<UserModel>(
        builder: (context,model,child){
          final followListCard = model.followList.map((group) =>
              Card(
                  child: ListTile(
                      leading: Container(
                        height: 60.0,
                        width: 60.0,
                        decoration:BoxDecoration(
                          shape: BoxShape.circle,
                          image:DecorationImage(
                              fit: BoxFit.fill,
                              image:NetworkImage(group.iconURL)),
                        ),
                      ),
                      title: Text(
                        group.name,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        group.text,
                        style: TextStyle(fontSize: 10, color: Colors.grey),
                      ),
                      onTap: () async {
                        await Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) {
                              return GroupDetail(group: group);
                            },
                          ),
                        );
                      }
                  )))
              .toList();
      return ListView(
        children: followListCard,
      );
    });
  }
}

