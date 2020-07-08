import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:weight/screen/User/user_model.dart';

class UserEdit extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final textEditingController = TextEditingController();
    return ChangeNotifierProvider<UserModel>(
      create: (_) => UserModel()..setCurrentUser(),
      child: Scaffold(
          appBar: AppBar(
            title: Text(
                '編集',
              style: TextStyle(
                color: Colors.white
              ),
            ),
          ),
          body: Consumer<UserModel>(
            builder: (context, model, child) {
              final user = model.currentUser;
              if (model.loading) {
                textEditingController.text = user.name;
                model.currentUserName = model.currentUser.name;
                model.currentImageURL = model.currentUser.iconURL;
                return Container(
                  height: double.infinity,
                  child: Center(
                    child: Column(
                      children: <Widget>[
                        SizedBox(
                          height: 40,
                        ),
                        GestureDetector(
                          onTap: () async {
                            var image = await ImagePicker.pickImage(
                                source: ImageSource.gallery);
                            context.read<UserModel>().imageSet(image);
                          },
                          child: (model.currentImage == null)
                              ? Container(
                                  height: 120,
                                  width: 120,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    image: DecorationImage(
                                      fit: BoxFit.fill,
                                      image: NetworkImage(user.iconURL),
                                    ),
                                  ),
                                )
                              : Container(
                                  height: 120,
                                  width: 120,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                  ),
                                  child: Image.file(model.currentImage),
                                ),
                        ),
                        FlatButton(
                            onPressed: () async {
                              var image = await ImagePicker.pickImage(
                                  source: ImageSource.gallery);
                              model.imageSet(image);
                            },
                            child: Text(
                              'プロフィール画像を変更',
                              style: TextStyle(color: Colors.indigo),
                            )),
                        SizedBox(
                          height: 10,
                        ),
                        user != null
                        ? Container(
                          width: 100,
                          child: TextField(
                            style: TextStyle(
                              fontSize: 20,
                            ),
                            textAlign: TextAlign.center,
                            controller: textEditingController,
                            onChanged: (text) {
                              model.currentUserName = text;
                            },
                          ),
                        )
                        : Container(),
                        SizedBox(
                          height: 30,
                        ),
                        RaisedButton(
                                onPressed: () async {
                                  if(model.currentImage != null){
                                    return model.uploadImage(model.currentImage);
                                  }
                                  await model.updateUser();
                                  Navigator.of(context).pop();
                                },
                                color: Colors.amber,
                                child: Text(
                                    '編集',
                                  style: TextStyle(
                                    color: Colors.white
                                  ),
                                ),
                              )
                      ],
                    ),
                  ),
                );
              } else {
                return Center(child: CircularProgressIndicator());
              }
            },
          )),
    );
  }
}

class UserView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

