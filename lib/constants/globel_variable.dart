import 'package:flutter/material.dart';

String uri = 'http://172.23.84.205:3000/api';

class GlobalVariables {
  static const appBarGradient = LinearGradient(
    colors: [
      Color.fromARGB(255, 29, 201, 192),
      Color.fromARGB(255, 125, 221, 216),
    ],
    stops: [0.5, 1.0],
  );

  static const secondaryColor = Color.fromRGBO(255, 153, 0, 1);
  static const backgroundColor = Colors.white;
  static const Color greyBackgroundCOlor = Color(0xffebecee);
  static var selectedNavBarColor = Colors.cyan[800]!;
  static const unselectedNavBarColor = Colors.black87;

  static const List<String> categories = [
    'Mobiles',
    'Electronics',
    'Fashion',
    'Appliances',
    'Books',
    'Essentials',
  ];

  static const List<Map<String, dynamic>> categoryIcons = [
    {'title': 'Mobiles', 'icon': Icons.phone_android},
    {'title': 'Electronics', 'icon': Icons.laptop},
    {'title': 'Fashion', 'icon': Icons.checkroom},
    {'title': 'Appliances', 'icon': Icons.kitchen},
    {'title': 'Books', 'icon': Icons.menu_book},
    {'title': 'Essentials', 'icon': Icons.spa},
  ];
}
