//
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weight/services/auth.dart';
import 'package:weight/services/BottomNavigation.dart';

class Home extends StatelessWidget {
  final AuthService _auth = AuthService();
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<BottomNavigationBarProvider>(
      create: (_) => BottomNavigationBarProvider(),
      child: BottomNavigationBarExample(),
    );
  }
}

