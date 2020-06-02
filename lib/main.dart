import 'package:flutter/material.dart';
import 'package:weight/services/next_page.dart';
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
            primarySwatch: Colors.amber,
      ),
      home: MyHomePage()
    );
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Achoooo!'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios),
            tooltip: 'Next page',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => NextPage(),
                ),
              );
            },
          ),
        ],
      ),
    );
    throw UnimplementedError();
  }
}
