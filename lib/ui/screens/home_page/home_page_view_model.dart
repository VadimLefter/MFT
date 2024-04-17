import 'package:flutter/material.dart';

class HomePageViewModel extends ChangeNotifier{
  String _bodyTitle = 'Aşteptaţi răspunsul...';
  String get bodyTitle => _bodyTitle;

  void updateBodyTitle() {
    _bodyTitle = 'Răspunsul este primit!';
    notifyListeners();
  }

}