import 'package:ecomerce_app/Models/user.dart';
import 'package:flutter/material.dart';

class UserProvider extends ChangeNotifier {
  UserModel _user = UserModel(
    id: '', name: '', email: '', password: '',
    address: '', type: '', token: '',
  );

  UserModel get user => _user;

  void setUser(String json) {
    _user = UserModel.fromJson(json);
    notifyListeners();
  }

  void setUserFromModel(UserModel user) {
    _user = user;
    notifyListeners();
  }
}
