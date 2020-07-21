import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weight/screen/Report/report_model.dart';

class Report extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            '通報',
          style: TextStyle(
            color: Colors.white
          ),
        ),
      ),
      body: ChangeNotifierProvider<ReportModel>(
          create: (_) => ReportModel(),
              child: Consumer<ReportModel>(
          builder: (context,model,child){
            return Column(
              children: <Widget>[
                Text('通報')
              ],
            );
    }),
      )
    );
  }
}
