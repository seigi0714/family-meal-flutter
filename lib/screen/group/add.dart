import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weight/shared/constants.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'dart:io';
import 'package:weight/screen/group/group_model.dart';

class GroupAdd extends StatelessWidget {
  final function = CloudFunctions.instance;

  @override
  Widget build(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    return ChangeNotifierProvider<GroupModel>(
      create: (_) => GroupModel(),
      child: Scaffold(
          appBar: AppBar(
            title: Text(
              'グループ作成',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
          body: Consumer<GroupModel>(
              builder: (context, model, child) {
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 20, horizontal: 15),
                child: Container(
                  height: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(10)),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: <Widget>[
                        SizedBox(height: 20.0),
                        (model.currentImage == null)
                            ? Container(
                                height: 200,
                                child: Center(
                                  child: FlatButton(
                                      onPressed: () async {
                                        var image = await ImagePicker.pickImage(
                                            source: ImageSource.gallery);
                                        context.read<GroupModel>().imageSet(image);
                                      },
                                      child: Text('プロフィール画像を変更')),
                                ))
                            : Image.file(
                                model.currentImage,
                                height: 100,
                                width: 100,
                              ),
                        SizedBox(height: 20.0),
                        TextFormField(
                          decoration: textInputDecoration.copyWith(hintText: 'グループ名'),
                          validator: (val) =>
                              val.length > 20 ? '20文字以上の名前は付られません' : null,
                          onChanged: (val) {
                            model.currentGroupName = val;
                          },
                        ),
                        SizedBox(height: 50.0),
                        TextFormField(
                          decoration:
                              textInputDecoration.copyWith(hintText: '一言でグループ紹介'),
                          validator: (val) =>
                              val.length > 30 ? '30文字いないで入力してください' : null,
                          onChanged: (val) {
                            model.currentGroupInfo = val;
                          },
                        ),
                        SizedBox(
                          height: 20.0,
                        ),
                        RaisedButton(
                            color: Colors.amber,
                            child: Text(
                              'グループ作成',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            elevation: 1.0,
                            shape: StadiumBorder(),
                            onPressed: () async {
                              if (_formKey.currentState.validate()) {
                                String name = model.currentGroupName;
                                String text = model.currentGroupInfo;
                                File image = model.currentImage;
                                await model.uploadImage(image);
                                await function
                                    .getHttpsCallable(functionName: 'addGroup')
                                    .call({
                                  "name": name,
                                  "text": text,
                                  "image": model.profileURL
                                });
                                Navigator.of(context).pop();
                              }
                            }),
                      ],
                    ),
                  ),
                ),
              );
            }
          )
      ),
    );
  }
}
