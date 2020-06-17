import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weight/screen/group/group_model.dart';

class GroupDetail extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<GroupModel>(context);
    final group = provider.currentGroup;
    return ChangeNotifierProvider<GroupModel>(
      create: (_) => GroupModel(),
      child: Scaffold(
        appBar: AppBar(
          leading: FlatButton(
            onPressed: () => provider.goHome(),
            child: Icon(
              Icons.arrow_back_ios,
              color: Colors.white,
            ),
          ),
          title: Text(
            group.name,
            style: TextStyle(color: Colors.white),
          ),
          actions: <Widget>[
            FlatButton(
                onPressed: null,
                child: Icon(
                  Icons.edit,
                  color: Colors.white,
                ))
          ],
        ),
        body: Column(
          children: <Widget>[
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
                                fontSize: 20,
                              ),
                            ),
                            Text(
                              'フォロワー',
                              style: TextStyle(
                                fontSize: 20,
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
                                fontSize: 20,
                              ),
                            ),
                            Text(
                              'メンバー',
                              style: TextStyle(
                                fontSize: 20,
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
            FlatButton(
                onPressed: null,
                child: Text(
                    'プロフィール編集',
                  style: TextStyle(
                    color: Colors.indigo
                  ),
                )
            ),
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
              )),
            )
          ],
        ),
      ),
    );
  }
}
