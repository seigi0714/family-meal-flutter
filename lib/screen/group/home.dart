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
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          context.read<Group>().linkAddPage();
        },
      ),
    );
  }
}
