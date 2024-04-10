import 'package:flutter/material.dart';

abstract class AppNavigator {
  static void push(BuildContext context, Widget widget){
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => widget));
  }
}