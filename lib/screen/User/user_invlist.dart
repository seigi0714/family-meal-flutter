import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weight/models/Invitation.dart';
import 'package:weight/screen/User/user_model.dart';

class InvList extends StatelessWidget {
  InvList({this.uid});

  final String uid;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<UserModel>(
      create: (_) => UserModel()..getInv(uid),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            '招待状',
            style: TextStyle(color: Colors.white),
          ),
        ),
        body: Consumer<UserModel>(builder: (context, model, child) {
          final invitations = model.invs;
          final invCard = invitations
              .map(
                (inv) => Container(
                  child: Card(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical:8.0,horizontal: 0),
                      child: ListTile(
                        leading: Container(
                            width: 60,
                            height: 60,
                            child: GroupIcon(groupID: inv.groupID)),
                        title: Container(
                            width: 50, child: GroupName(groupID: inv.groupID)),
                        trailing: model.isSelect
                        ? Container()
                        : Container(
                          width: 200,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                              children: <Widget>[
                                IconButton(
                                    icon: Icon(
                                        Icons.check,
                                      color: Colors.green,
                                    ),
                                    onPressed: () async {
                                      await model.join(inv.groupID);
                                    }
                                ),
                                IconButton(
                                    icon: Icon(
                                        Icons.not_interested,
                                      color: Colors.red,
                                    ),
                                    onPressed: () async {
                                      await model.chancel(inv.groupID);
                                    }
                                    )
                              ],
                            ),
                        ),
                        ),
                    ),
                  ),
                ),
              )
              .toList();
          return model.loading
              ? ListView(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  children: invCard,
                )
              : Container();
        }),
      ),
    );
  }
}

class GroupIcon extends StatelessWidget {
  GroupIcon({this.groupID});

  final String groupID;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<UserModel>(
      create: (_) => UserModel()..fetchGroup(groupID),
      child: Consumer<UserModel>(builder: (context, model, child) {
        return model.isImage
            ? Container(
                height: 60.0,
                width: 60.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                      fit: BoxFit.fill,
                      image: NetworkImage(model.group.iconURL)),
                ),
              )
            : Center(child: CircularProgressIndicator());
      }),
    );
  }
}

class GroupName extends StatelessWidget {
  GroupName({this.groupID});

  final String groupID;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<UserModel>(
      create: (_) => UserModel()..fetchGroup(groupID),
      child: Consumer<UserModel>(builder: (context, model, child) {
        return model.isImage
            ? Text(
                model.group.name,
              )
            : Center(
                child: CircularProgressIndicator(),
              );
      }),
    );
  }
}
