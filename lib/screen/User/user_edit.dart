import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:weight/screen/User/user_model.dart';

class UserEdit extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    final textEditingController = TextEditingController();

    return ChangeNotifierProvider<UserModel>(
      create: (_) =>
      UserModel()
        ..setCurrentUser(),
      child: Scaffold(
        appBar: AppBar(
          title: Text('編集'),
        ),
        body: Consumer<UserModel>(
          builder: (context, model, child) {
            final user = model.currentUser;
            textEditingController.text = user.name;
            if (user != null) {
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
                Container(
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
                ),
                SizedBox(
                  height: 30,
                ),
                RaisedButton(
                  onPressed: () async {
                    final String imageURL = await model.uploadImage(model.currentImage);
                    var name = model.currentUserName;
                    await model.updateUser(imageURL, name);
                    Navigator.of(context).pop();
                  },
                  color: Colors.amber,
                  child: Text('登録'),
                )
                ],
              ),
            ),
            );
            } else {
            return Center(child: CircularProgressIndicator(
            ));
            }
          },
        ),
      ),
    );
  }
}
