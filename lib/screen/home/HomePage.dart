import 'package:flutter/material.dart';
import 'package:weight/services/auth.dart';

class HomePage extends StatelessWidget {

  AuthService _auth = AuthService();
  @override
  Widget build(BuildContext context) {
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
              onPressed: () {
            return _auth.signOut();
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
    );
  }
}

class PostList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemBuilder: (context, index) => index == 0
          ? Container(
                padding: EdgeInsets.only(top: 16.0),
                child: Center(
                  child: Text(
                      'ようこそ',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
           )
          : Column(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 16.0, 8.0, 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          // iconImage(group)
                          new Container(
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
                  child: new Image.network(
                    "https://morinagamilk.co.jp/files/25091-large",
                    fit: BoxFit.cover,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(0.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      new IconButton(
                          icon: Icon(Icons.star_border),
                        onPressed: (){},
                      ),
                      Text('300'),
                      SizedBox(
                        width: 20.0,
                      ),
                      IconButton(
                          icon: Icon(Icons.share),
                        onPressed: (){},
                      ),
                    ],
                  ),
                ),
                Padding(
                    padding: EdgeInsets.only(left: 10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        new Icon(Icons.person_pin),
                        new SizedBox(
                            width: 10,
                        ),
                        new Text("seigi"),
                      ],
                    ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      new Text(
                          '料理名',
                      ),
                      SizedBox(
                        width: 10.0,
                      ),
                      Text("ハンバーグ")
                    ],
                  ),
                )
              ],
            ),
    );
  }
}
