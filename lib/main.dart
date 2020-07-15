import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:weight/screen/wrapper.dart';
import 'package:weight/services/auth.dart';
import 'package:weight/models/user.dart';

void main() async {
  await DotEnv().load('.env');
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    // ⓵の状態を監視　
    return StreamProvider<User>.value(
      value: AuthService().user,
      child: MaterialApp(
        title: 'Flutter Demo',

        theme: ThemeData(
          primaryColor: Colors.amber,
          primaryIconTheme: Theme.of(context).primaryIconTheme.copyWith(
              color: Colors.white,
          ),
          textTheme: Theme.of(context).textTheme.apply(
            displayColor: Colors.white

          ),
        ),
        home:
            GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
             child: Wrapper(),
            ),
      ),
    );
  }
}

