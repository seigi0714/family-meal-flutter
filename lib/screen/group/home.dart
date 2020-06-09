import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weight/screen/group/group_model.dart';

class GroupHome extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'FamilyMeal',
          style: TextStyle(
              color: Colors.white
          ),
        ),
      ),
      body: Container(
        height: double.infinity,
        child: Column(
          children: <Widget>[
            SizedBox(
              height: 10,
            ),
            Text(
              'グループ一覧',
            ),
            belongGroupList(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          context.read<Group>().linkAddPage();
        },
      ),
    );
  }
}

class belongGroupList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        SizedBox(
          height: 10.0,
        ),
        Card(
          margin: EdgeInsets.all(10.0),
          elevation: 5.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(4.0),
            ),
          ),
          child: Container(
              height: 100.0,
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Column(
                        children: <Widget>[
                          SizedBox(
                            height: 10,
                          ),
                          Container(
                            height: 60.0,
                            width: 60.0,
                            decoration: new BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.black12,
                              ),
                              image: new DecorationImage(
                                  fit: BoxFit.fill,
                                  image: new NetworkImage(
                                      "https://so-sha.co.jp/cont/wp-content/themes/daishin-sosha/img/photo/menu/family/img02.png")),
                            ),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Text(
                            "中村家",
                            style: TextStyle(
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        children: <Widget>[
                          Row(

                            children: <Widget>[
                              SizedBox(
                                width: 10.0,
                              ),
                              FlatButton(
                                onPressed: () {
                                  // メンバー一覧ページ
                                },
                                child: Text(
                                  'メンバー3人',
                                  style: TextStyle(
                                    color: Colors.indigoAccent,
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 10.0,
                              ),
                              FlatButton(
                                onPressed: () {
                                  // フォロワー一覧ページ
                                },
                                child: Text(
                                  'フォロワー10人',
                                  style: TextStyle(
                                    color: Colors.indigoAccent,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                                vertical: 10, horizontal: 5),
                            child: Text('美味しく楽しくがモットーです。'),
                          )
                        ],
                      ),
                    ],
                  )
                ],
              )
          ),
        ),
      ],
    )
    ,;
  }
}

