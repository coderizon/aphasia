import 'package:flutter/material.dart';

class AppState extends ChangeNotifier {
  bool _sessionScreenOpened = false;

  set sessionScreenOpened(bool opened) {
    _sessionScreenOpened = opened;
    notifyListeners();
  }

  bool get sessionScreenOpened => _sessionScreenOpened;
}
