import 'dart:convert';
import 'package:ecomerce_app/Models/cart_item.dart';
import 'package:ecomerce_app/constants/globel_variable.dart';
import 'package:ecomerce_app/constants/utils.dart';
import 'package:ecomerce_app/Providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class CartProvider {
  Future<List<CartItem>> fetchCart(BuildContext context) async {
    final token =
        Provider.of<UserProvider>(context, listen: false).user.token;
    try {
      http.Response res = await http.get(
        Uri.parse('$uri/cart'),
        headers: {'Content-Type': 'application/json', 'x-auth-token': token},
      );
      if (res.statusCode == 200) {
        final List decoded = jsonDecode(res.body);
        return decoded.map((e) => CartItem.fromMap(e)).toList();
      }
    } catch (e) {
      showSnackBar(context, e.toString());
    }
    return [];
  }

  Future<void> addToCart(BuildContext context, String productId) async {
    final token =
        Provider.of<UserProvider>(context, listen: false).user.token;
    try {
      http.Response res = await http.post(
        Uri.parse('$uri/add-to-cart'),
        headers: {'Content-Type': 'application/json', 'x-auth-token': token},
        body: jsonEncode({'id': productId}),
      );
      if (res.statusCode == 200) {
        showSnackBar(context, 'Added to cart!');
      }
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }

  Future<void> removeFromCart(BuildContext context, String productId) async {
    final token =
        Provider.of<UserProvider>(context, listen: false).user.token;
    try {
      await http.delete(
        Uri.parse('$uri/remove-from-cart/$productId'),
        headers: {'Content-Type': 'application/json', 'x-auth-token': token},
      );
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }
}
