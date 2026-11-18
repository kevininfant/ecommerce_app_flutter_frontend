import 'dart:convert';
import 'package:ecomerce_app/Models/cart_item.dart';
import 'package:ecomerce_app/Models/order.dart';
import 'package:ecomerce_app/constants/globel_variable.dart';
import 'package:ecomerce_app/constants/utils.dart';
import 'package:ecomerce_app/Providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class OrderProvider {
  Future<bool> placeOrder({
    required BuildContext context,
    required List<CartItem> cart,
    required double totalPrice,
    required String address,
    String paymentMethod = 'COD',
  }) async {
    final token =
        Provider.of<UserProvider>(context, listen: false).user.token;
    try {
      final res = await http.post(
        Uri.parse('$uri/order'),
        headers: {
          'Content-Type': 'application/json',
          'x-auth-token': token
        },
        body: jsonEncode({
          'cart': cart
              .map((i) => {
                    'product': i.product.toMap(),
                    'quantity': i.quantity
                  })
              .toList(),
          'totalPrice': totalPrice,
          'address': address,
          'paymentMethod': paymentMethod,
        }),
      );
      return res.statusCode == 200;
    } catch (e) {
      showSnackBar(context, e.toString());
      return false;
    }
  }

  Future<List<Order>> fetchOrders(BuildContext context) async {
    final token =
        Provider.of<UserProvider>(context, listen: false).user.token;
    try {
      final res = await http.get(
        Uri.parse('$uri/orders'),
        headers: {
          'Content-Type': 'application/json',
          'x-auth-token': token
        },
      );
      if (res.statusCode == 200) {
        return (jsonDecode(res.body) as List)
            .map((e) => Order.fromMap(e))
            .toList();
      }
    } catch (e) {
      showSnackBar(context, e.toString());
    }
    return [];
  }
}
