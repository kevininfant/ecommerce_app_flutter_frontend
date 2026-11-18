import 'dart:convert';
import 'package:ecomerce_app/Models/offer_model.dart';
import 'package:ecomerce_app/Providers/user_provider.dart';
import 'package:ecomerce_app/constants/globel_variable.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class OffersScreen extends StatefulWidget {
  static const String routeName = '/offers';
  const OffersScreen({super.key});

  @override
  State<OffersScreen> createState() => _OffersScreenState();
}

class _OffersScreenState extends State<OffersScreen> {
  List<OfferModel> _offers = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadOffers();
  }

  Future<void> _loadOffers() async {
    final token =
        Provider.of<UserProvider>(context, listen: false).user.token;
    try {
      final res = await http.get(
        Uri.parse('$uri/offers'),
        headers: {'x-auth-token': token},
      );
      if (res.statusCode == 200) {
        setState(() {
          _offers = (jsonDecode(res.body) as List)
              .map((e) => OfferModel.fromMap(e))
              .toList();
          _loading = false;
        });
      }
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration:
              const BoxDecoration(gradient: GlobalVariables.appBarGradient),
        ),
        title: const Text('Offers & Coupons',
            style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _offers.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.local_offer_outlined,
                          size: 60.sp, color: Colors.grey[300]),
                      SizedBox(height: 12.h),
                      Text('No offers available',
                          style: TextStyle(
                              color: Colors.grey[500], fontSize: 15.sp)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: EdgeInsets.all(16.w),
                  itemCount: _offers.length,
                  itemBuilder: (ctx, i) => _OfferCard(offer: _offers[i]),
                ),
    );
  }
}

class _OfferCard extends StatelessWidget {
  final OfferModel offer;
  const _OfferCard({required this.offer});

  @override
  Widget build(BuildContext context) {
    final expiry = DateTime.tryParse(offer.expiresAt);
    final daysLeft = expiry != null
        ? expiry.difference(DateTime.now()).inDays
        : 0;

    return Container(
      margin: EdgeInsets.only(bottom: 14.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        children: [
          // Top colored banner
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  GlobalVariables.secondaryColor,
                  GlobalVariables.secondaryColor.withOpacity(0.7),
                ],
              ),
              borderRadius:
                  BorderRadius.vertical(top: Radius.circular(16.r)),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(10.w),
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Text(
                    '${offer.discountPercent}%\nOFF',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14.sp,
                        height: 1.2),
                  ),
                ),
                SizedBox(width: 14.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(offer.title,
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16.sp)),
                      SizedBox(height: 4.h),
                      Text(offer.description,
                          style: TextStyle(
                              color: Colors.white70, fontSize: 12.sp)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Bottom coupon code section
          Padding(
            padding: EdgeInsets.all(14.w),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: 14.w, vertical: 10.h),
                    decoration: BoxDecoration(
                      color: GlobalVariables.greyBackgroundCOlor,
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(
                          color: GlobalVariables.secondaryColor
                              .withOpacity(0.3),
                          style: BorderStyle.solid),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.local_offer,
                            color: GlobalVariables.secondaryColor,
                            size: 16.sp),
                        SizedBox(width: 6.w),
                        Text(offer.code,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14.sp,
                                letterSpacing: 1.5,
                                color: GlobalVariables.secondaryColor)),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 10.w),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: GlobalVariables.secondaryColor,
                    padding: EdgeInsets.symmetric(
                        horizontal: 16.w, vertical: 10.h),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r)),
                  ),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: offer.code));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Code "${offer.code}" copied!'),
                        backgroundColor: Colors.green,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  child: Text('Copy',
                      style: TextStyle(
                          color: Colors.white, fontSize: 13.sp)),
                ),
              ],
            ),
          ),

          // Expiry
          Padding(
            padding: EdgeInsets.fromLTRB(14.w, 0, 14.w, 12.h),
            child: Row(
              children: [
                Icon(Icons.access_time,
                    size: 13.sp, color: Colors.grey[400]),
                SizedBox(width: 4.w),
                Text(
                  daysLeft > 0
                      ? 'Expires in $daysLeft days'
                      : 'Expires today!',
                  style: TextStyle(
                      color: daysLeft <= 1 ? Colors.red : Colors.grey[500],
                      fontSize: 11.sp),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
