import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weight/screen/group/group_model.dart';

class GroupAdd extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<Group>(context);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: Icon(Icons.arrow_back_ios),
            onPressed: () {
              context.read<Group>().GoHome();
            }),
        title: Text(
          'グループ作成',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
