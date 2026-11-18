import 'package:ecomerce_app/Screens/adminScreen/admin_screen.dart';
import 'package:ecomerce_app/Screens/authScreen/authScreen.dart';
import 'package:ecomerce_app/Screens/cartScreen/cart_screen.dart';
import 'package:ecomerce_app/Screens/feedbackScreen/feedback_screen.dart';
import 'package:ecomerce_app/Screens/homeScreen/home_screen.dart';
import 'package:ecomerce_app/Screens/offersScreen/offers_screen.dart';
import 'package:ecomerce_app/Screens/orderDetailScreen/order_detail_screen.dart';
import 'package:ecomerce_app/Screens/paymentScreen/payment_screen.dart';
import 'package:ecomerce_app/Screens/productScreen/product_detail_screen.dart';
import 'package:ecomerce_app/Screens/profileScreen/profile_screen.dart';
import 'package:flutter/material.dart';

Route<dynamic> genarateRoute(RouteSettings settings) {
  switch (settings.name) {
    case '/':
    case AuthScreen.routeName:
      return MaterialPageRoute(
          settings: settings, builder: (_) => const AuthScreen());
    case HomeScreen.routeName:
      return MaterialPageRoute(
          settings: settings, builder: (_) => const HomeScreen());
    case ProductDetailScreen.routeName:
      return MaterialPageRoute(
          settings: settings, builder: (_) => const ProductDetailScreen());
    case CartScreen.routeName:
      return MaterialPageRoute(
          settings: settings, builder: (_) => const CartScreen());
    case PaymentScreen.routeName:
      return MaterialPageRoute(
          settings: settings, builder: (_) => const PaymentScreen());
    case ProfileScreen.routeName:
      return MaterialPageRoute(
          settings: settings, builder: (_) => const ProfileScreen());
    case OrderDetailScreen.routeName:
      return MaterialPageRoute(
          settings: settings, builder: (_) => const OrderDetailScreen());
    case OffersScreen.routeName:
      return MaterialPageRoute(
          settings: settings, builder: (_) => const OffersScreen());
    case FeedbackScreen.routeName:
      return MaterialPageRoute(
          settings: settings, builder: (_) => const FeedbackScreen());
    case AdminScreen.routeName:
      return MaterialPageRoute(
          settings: settings, builder: (_) => const AdminScreen());
    default:
      return MaterialPageRoute(
        builder: (_) => const Scaffold(
          body: Center(child: Text('Page not found')),
        ),
      );
  }
}
