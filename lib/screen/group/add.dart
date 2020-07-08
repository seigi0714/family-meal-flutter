import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weight/models/Group.dart';
import 'package:weight/screen/group/home.dart';
import 'package:weight/shared/constants.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'dart:io';
import 'package:weight/screen/group/group_model.dart';

class GroupAdd extends StatelessWidget {
  GroupAdd({this.group});

  final Group group;
  final function = CloudFunctions.instance;

  @override
  Widget build(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    final bottomSpace = MediaQuery.of(context).viewInsets.bottom;
    final nameEditingController = TextEditingController();
    final textEditingController = TextEditingController();
    final bool isUpdate = group != null;
    if (isUpdate) {
      nameEditingController.text = group.name;
      textEditingController.text = group.text;
    }
    return ChangeNotifierProvider<GroupModel>(
      create: (_) => GroupModel(),
      child: Scaffold(
          appBar: AppBar(
            title: Text(
              isUpdate ? 'グループ編集' : 'グループ作成',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
          body: Consumer<GroupModel>(builder: (context, model, child) {
            if (isUpdate) {
              model.currentGroupName = group.name;
              model.currentGroupInfo = group.text;
              model.profileURL = group.iconURL;
            }
            return SingleChildScrollView(
              reverse: true,
              child: Column(
                children: <Widget>[
                  SizedBox(height: 20.0),
                  (model.currentImage == null)
                      ? isUpdate
                          ? Column(
                              children: <Widget>[
                                InkWell(
                                  onTap: () async {
                                    var image = await ImagePicker.pickImage(
                                        source: ImageSource.gallery);
                                    context.read<GroupModel>().imageSet(image);
                                  },
                                  child: Container(
                                    height: 150,
                                    width: 150,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      image: DecorationImage(
                                          fit: BoxFit.fill,
                                          image: NetworkImage(group.iconURL)),
                                    ),
                                  ),
                                ),
                                FlatButton(
                                    onPressed: () async {
                                      var image = await ImagePicker.pickImage(
                                          source: ImageSource.gallery);
                                      context
                                          .read<GroupModel>()
                                          .imageSet(image);
                                    },
                                    child: Text('プロフィール画像を変更'))
                              ],
                            )
                          : Container(
                              height: 200,
                              child: Center(
                                child: FlatButton(
                                    onPressed: () async {
                                      var image = await ImagePicker.pickImage(
                                          source: ImageSource.gallery);
                                      context
                                          .read<GroupModel>()
                                          .imageSet(image);
                                    },
                                    child: Text('プロフィール画像を変更')),
                              ))
                      : Image.file(
                          model.currentImage,
                          height: 200,
                        ),
                  SizedBox(height: 20.0),
                  TextField(
                    decoration: textInputDecoration.copyWith(hintText: 'グループ名'),
                    controller: nameEditingController,
                    onChanged: (text) {
                      model.currentGroupName = text;
                    },
                  ),
                  SizedBox(height: 50.0),
                  TextField(
                    decoration:
                        textInputDecoration.copyWith(hintText: '一言でグループ紹介'),
                    controller: textEditingController,
                    onChanged: (text) {
                      model.currentGroupInfo = text;
                    },
                  ),
                  SizedBox(
                    height: 20.0,
                  ),
                  SizedBox(
                      width: 160,
                      child: RaisedButton(
                          color: Colors.amber,
                          child: Text(
                            isUpdate ? '編集' : 'グループ作成',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          elevation: 1.0,
                          shape: StadiumBorder(),
                          onPressed: () async {
                            if (isUpdate) {
                              await updateGroup(model, context, group);
                            } else {
                              // firestoreに本を追加
                              await addGroup(model, context);
                            }
                          })),
                ],
              ),
            );
          })),
    );
  }
}

Future addGroup(GroupModel model, BuildContext context) async {
  try {
    await model.addGroup();
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('保存しました！'),
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

Future updateGroup(GroupModel model, BuildContext context, Group group) async {
  try {
    await model.updateGroup(group);
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('更新しました！'),
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
                return GroupHome();
              },
            ),
          ],
        );
      },
    );
  }
}
