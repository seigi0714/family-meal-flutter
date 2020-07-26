import 'dart:io';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:weight/models/Group.dart';
import 'package:weight/screen/post/post_model.dart';
import 'package:weight/shared/constants.dart';

class PostAdd extends StatelessWidget {
  PostAdd({this.group});

  final Group group;

  @override
  Widget build(BuildContext context) {
    final function = CloudFunctions.instance;
    final TextEditingController titleEditController = TextEditingController();
    final TextEditingController textEditingController = TextEditingController();
    return ChangeNotifierProvider<PostModel>(
      create: (_) => PostModel(),
      child: Scaffold(
          appBar: AppBar(
            title: Text('写真投稿'),
          ),
          body: Consumer<PostModel>(builder: (context, model, child) {
            return GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: SingleChildScrollView(
                reverse: true,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Column(children: <Widget>[
                    SizedBox(
                      height: 30,
                    ),
                    (model.currentImage == null)
                        ? Container(
                            height: 200,
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey)),
                            child: InkWell(
                                onTap: () async {
                                  var image = await ImagePicker.pickImage(
                                      source: ImageSource.gallery);
                                  model.imageSet(image);
                                },
                                child: Center(
                                  child: FlatButton(
                                    onPressed: () async {
                                      var image = await ImagePicker.pickImage(
                                          source: ImageSource.gallery);
                                      model.imageSet(image);
                                    },
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: <Widget>[
                                        Icon(Icons.camera_enhance),
                                        Text('写真を投稿')
                                      ],
                                    ),
                                  ),
                                )),
                          )
                        : Image.file(
                            model.currentImage,
                            height: 200,
                          ),
                    Column(children: <Widget>[
                      Container(
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius:
                                BorderRadius.all(Radius.circular(5.0))),
                        child: TextField(
                          decoration: textInputDecoration.copyWith(
                            hintText: '料理名',
                          ),
                          controller: titleEditController,
                          onChanged: (text) {
                            model.currentPostName = text;
                          },
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius:
                                BorderRadius.all(Radius.circular(5.0))),
                        child: TextField(
                          decoration: textInputDecoration.copyWith(
                              hintText: 'キャプテーション'),
                          controller: textEditingController,
                          keyboardType: TextInputType.multiline,
                          maxLines: 5,
                          onChanged: (text) {
                            model.currentPostInfo = text;
                          },
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      RaisedButton(
                          color: Colors.amber,
                          child: Text(
                            '投稿',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          elevation: 1.0,
                          shape: StadiumBorder(),
                          onPressed: () async {
                              String name = model.currentPostName;
                              String text = model.currentPostInfo;
                              File image = model.currentImage;

                              await model.uploadImage(image);
                              await model.addPost(
                                  name, text, model.profileURL, group.groupID);
                              Navigator.of(context).pop();
                            }
                          ),
                    ]),
                  ]),
                ),
              ),
            );
          })),
    );
  }
}
