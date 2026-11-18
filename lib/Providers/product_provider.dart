import 'dart:convert';
import 'package:ecomerce_app/Models/product.dart';
import 'package:ecomerce_app/constants/error_handling.dart';
import 'package:ecomerce_app/constants/globel_variable.dart';
import 'package:ecomerce_app/constants/utils.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:ecomerce_app/Providers/user_provider.dart';

class ProductProvider {
  Future<List<Product>> fetchAllProducts(BuildContext context) async {
    final token =
        Provider.of<UserProvider>(context, listen: false).user.token;
    try {
      http.Response res = await http.get(
        Uri.parse('$uri/products'),
        headers: {'Content-Type': 'application/json', 'x-auth-token': token},
      );
      if (res.statusCode == 200) {
        final List decoded = jsonDecode(res.body);
        return decoded.map((e) => Product.fromMap(e)).toList();
      }
    } catch (e) {
      showSnackBar(context, e.toString());
    }
    return [];
  }

  Future<List<Product>> fetchProductsByCategory(
      BuildContext context, String category) async {
    final token =
        Provider.of<UserProvider>(context, listen: false).user.token;
    try {
      http.Response res = await http.get(
        Uri.parse('$uri/products/category/$category'),
        headers: {'Content-Type': 'application/json', 'x-auth-token': token},
      );
      if (res.statusCode == 200) {
        final List decoded = jsonDecode(res.body);
        return decoded.map((e) => Product.fromMap(e)).toList();
      }
    } catch (e) {
      showSnackBar(context, e.toString());
    }
    return [];
  }

  Future<List<Product>> searchProducts(
      BuildContext context, String query) async {
    final token =
        Provider.of<UserProvider>(context, listen: false).user.token;
    try {
      http.Response res = await http.get(
        Uri.parse('$uri/search?q=$query'),
        headers: {'Content-Type': 'application/json', 'x-auth-token': token},
      );
      if (res.statusCode == 200) {
        final List decoded = jsonDecode(res.body);
        return decoded.map((e) => Product.fromMap(e)).toList();
      }
    } catch (e) {
      showSnackBar(context, e.toString());
    }
    return [];
  }

  void rateProduct(BuildContext context, String productId, double rating) async {
    final token =
        Provider.of<UserProvider>(context, listen: false).user.token;
    try {
      await http.post(
        Uri.parse('$uri/rate-product'),
        headers: {'Content-Type': 'application/json', 'x-auth-token': token},
        body: jsonEncode({'id': productId, 'rating': rating}),
      );
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }
}
