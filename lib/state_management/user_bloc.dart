import 'package:flutter/material.dart';

class UserBloc extends ChangeNotifier{

  bool _isLogged = false;
  bool get isLogged => _isLogged;
  set isLogged(bool value) {
    _isLogged = value;
    notifyListeners();
  }

  Map _user = {};
  Map get user => _user;
  set user(Map value) {
    _user = value;
    notifyListeners();
  }

  double _distance = 0.0;
  double get distance => _distance;
  set distance(double value) {
    _distance = value;
    notifyListeners();
  }

  String _start = "";
  String get start => _start;
  set start(String value) {
    _start = value;
    notifyListeners();
  }

  String _destination = "";
  String get destination => _destination;
  set destination(String value) {
    _destination = value;
    notifyListeners();
  }

}