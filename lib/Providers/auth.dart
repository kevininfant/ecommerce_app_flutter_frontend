import 'dart:convert';
import 'package:ecomerce_app/Models/user.dart';
import 'package:ecomerce_app/Providers/user_provider.dart';
import 'package:ecomerce_app/Screens/adminScreen/admin_screen.dart';
import 'package:ecomerce_app/Screens/authScreen/authScreen.dart';
import 'package:ecomerce_app/Screens/homeScreen/home_screen.dart';
import 'package:ecomerce_app/constants/error_handling.dart';
import 'package:ecomerce_app/constants/globel_variable.dart';
import 'package:ecomerce_app/constants/utils.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider {
  void signUpUser({
    required BuildContext context,
    required String email,
    required String name,
    required String password,
  }) async {
    try {
      final res = await http.post(
        Uri.parse('$uri/signup'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({'name': name, 'email': email, 'password': password}),
      );
      httpErrorHandle(
        responce: res,
        context: context,
        onSuccess: () => showSnackBar(context, 'Account created! Please sign in.'),
      );
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }

  void signInUser({
    required BuildContext context,
    required String email,
    required String password,
  }) async {
    try {
      final res = await http.post(
        Uri.parse('$uri/signin'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({'email': email, 'password': password}),
      );
      httpErrorHandle(
        responce: res,
        context: context,
        onSuccess: () async {
          final prefs = await SharedPreferences.getInstance();
          final body = jsonDecode(res.body);
          await prefs.setString('x-auth-token', body['token']);
          if (context.mounted) {
            final user = UserModel.fromMap(body);
            Provider.of<UserProvider>(context, listen: false)
                .setUserFromModel(user);
            if (user.type == 'admin') {
              Navigator.pushNamedAndRemoveUntil(
                  context, AdminScreen.routeName, (r) => false);
            } else {
              Navigator.pushNamedAndRemoveUntil(
                  context, HomeScreen.routeName, (r) => false);
            }
          }
        },
      );
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }

  Future<void> getUserData(BuildContext context) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('x-auth-token') ?? '';
      if (token.isEmpty) return;
      final res = await http.get(
        Uri.parse('$uri/profile'),
        headers: {'Content-Type': 'application/json', 'x-auth-token': token},
      );
      if (res.statusCode == 200 && context.mounted) {
        final body = jsonDecode(res.body);
        body['token'] = token;
        Provider.of<UserProvider>(context, listen: false)
            .setUserFromModel(UserModel.fromMap(body));
      }
    } catch (_) {}
  }

  void signOut(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('x-auth-token');
    if (context.mounted) {
      Provider.of<UserProvider>(context, listen: false).setUserFromModel(
        UserModel(
            id: '', name: '', email: '', password: '',
            address: '', type: '', token: ''),
      );
      Navigator.pushNamedAndRemoveUntil(
          context, AuthScreen.routeName, (r) => false);
    }
  }
}
