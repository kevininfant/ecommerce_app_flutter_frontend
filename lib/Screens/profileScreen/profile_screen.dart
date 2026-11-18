import 'dart:convert';
import 'package:ecomerce_app/Models/order.dart';
import 'package:ecomerce_app/Providers/auth.dart';
import 'package:ecomerce_app/Providers/order_provider.dart';
import 'package:ecomerce_app/Providers/user_provider.dart';
import 'package:ecomerce_app/Screens/orderDetailScreen/order_detail_screen.dart';
import 'package:ecomerce_app/constants/globel_variable.dart';
import 'package:ecomerce_app/constants/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  static const String routeName = '/profile';
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _addressController = TextEditingController();
  final _nameController = TextEditingController();
  final _orderProvider = OrderProvider();
  List<Order> _orders = [];
  bool _loadingOrders = true;
  bool _editingProfile = false;

  @override
  void initState() {
    super.initState();
    final user = Provider.of<UserProvider>(context, listen: false).user;
    _addressController.text = user.address;
    _nameController.text = user.name;
    _loadOrders();
  }

  @override
  void dispose() {
    _addressController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _loadOrders() async {
    setState(() => _loadingOrders = true);
    final orders = await _orderProvider.fetchOrders(context);
    setState(() {
      _orders = orders;
      _loadingOrders = false;
    });
  }

  Future<void> _updateAddress() async {
    final token =
        Provider.of<UserProvider>(context, listen: false).user.token;
    try {
      final res = await http.put(
        Uri.parse('$uri/address'),
        headers: {
          'Content-Type': 'application/json',
          'x-auth-token': token,
        },
        body: jsonEncode({'address': _addressController.text.trim()}),
      );
      if (res.statusCode == 200 && mounted) {
        showSnackBar(context, 'Address updated!');
        setState(() => _editingProfile = false);
      }
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }

  Color _statusColor(int s) {
    switch (s) {
      case 0: return Colors.orange;
      case 1: return Colors.blue;
      case 2: return Colors.purple;
      case 3: return Colors.green;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;

    return SingleChildScrollView(
      child: Column(
        children: [
          // Profile header
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
                gradient: GlobalVariables.appBarGradient),
            padding:
                EdgeInsets.fromLTRB(20.w, 30.h, 20.w, 24.h),
            child: Column(
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 44.r,
                      backgroundColor: Colors.white,
                      child: Text(
                        user.name.isNotEmpty
                            ? user.name[0].toUpperCase()
                            : 'U',
                        style: TextStyle(
                            fontSize: 34.sp,
                            fontWeight: FontWeight.bold,
                            color: GlobalVariables.secondaryColor),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: () =>
                            setState(() => _editingProfile = !_editingProfile),
                        child: Container(
                          padding: EdgeInsets.all(4.w),
                          decoration: const BoxDecoration(
                              color: GlobalVariables.secondaryColor,
                              shape: BoxShape.circle),
                          child: Icon(Icons.edit,
                              color: Colors.white, size: 14.sp),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                Text(user.name,
                    style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
                SizedBox(height: 4.h),
                Text(user.email,
                    style:
                        TextStyle(fontSize: 13.sp, color: Colors.white70)),
                SizedBox(height: 4.h),
                Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: 10.w, vertical: 3.h),
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    user.type == 'admin' ? '👑 Admin' : '👤 Customer',
                    style: TextStyle(
                        color: Colors.white, fontSize: 11.sp),
                  ),
                ),
              ],
            ),
          ),

          // Stats row
          Container(
            color: Colors.white,
            padding: EdgeInsets.symmetric(vertical: 14.h),
            child: Row(
              children: [
                _statItem('${_orders.length}', 'Orders'),
                _divider(),
                _statItem(
                    _orders
                        .where((o) => o.status == 3)
                        .length
                        .toString(),
                    'Delivered'),
                _divider(),
                _statItem(
                    _orders
                        .where((o) => o.status < 3)
                        .length
                        .toString(),
                    'Active'),
              ],
            ),
          ),

          SizedBox(height: 8.h),

          // Edit profile section
          if (_editingProfile)
            Container(
              color: Colors.white,
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Edit Profile',
                      style: TextStyle(
                          fontSize: 15.sp, fontWeight: FontWeight.bold)),
                  SizedBox(height: 12.h),
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Full Name',
                      prefixIcon: const Icon(Icons.person_outline),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.r)),
                    ),
                  ),
                  SizedBox(height: 12.h),
                  TextFormField(
                    controller: _addressController,
                    maxLines: 2,
                    decoration: InputDecoration(
                      labelText: 'Delivery Address',
                      prefixIcon:
                          const Icon(Icons.location_on_outlined),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.r)),
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Row(children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () =>
                            setState(() => _editingProfile = false),
                        child: const Text('Cancel'),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor:
                                GlobalVariables.secondaryColor),
                        onPressed: _updateAddress,
                        child: const Text('Save',
                            style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  ]),
                ],
              ),
            ),

          if (_editingProfile) SizedBox(height: 8.h),

          // My Orders
          Container(
            color: Colors.white,
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('My Orders',
                        style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.bold)),
                    TextButton(
                      onPressed: _loadOrders,
                      child: const Text('Refresh'),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                _loadingOrders
                    ? const Center(child: CircularProgressIndicator())
                    : _orders.isEmpty
                        ? Container(
                            padding: EdgeInsets.all(24.w),
                            decoration: BoxDecoration(
                              color: GlobalVariables.greyBackgroundCOlor,
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Center(
                              child: Column(children: [
                                Icon(Icons.shopping_bag_outlined,
                                    size: 40.sp,
                                    color: Colors.grey[400]),
                                SizedBox(height: 8.h),
                                Text('No orders yet',
                                    style: TextStyle(
                                        color: Colors.grey[500],
                                        fontSize: 14.sp)),
                              ]),
                            ),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            physics:
                                const NeverScrollableScrollPhysics(),
                            itemCount: _orders.length,
                            itemBuilder: (ctx, i) {
                              final order = _orders[i];
                              return GestureDetector(
                                onTap: () => Navigator.pushNamed(
                                  context,
                                  OrderDetailScreen.routeName,
                                  arguments: order,
                                ),
                                child: Card(
                                  margin:
                                      EdgeInsets.only(bottom: 10.h),
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(12.r)),
                                  child: Padding(
                                    padding: EdgeInsets.all(14.w),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment
                                                  .spaceBetween,
                                          children: [
                                            Text(
                                              'Order #${order.id.substring(order.id.length - 6).toUpperCase()}',
                                              style: TextStyle(
                                                  fontWeight:
                                                      FontWeight.bold,
                                                  fontSize: 13.sp),
                                            ),
                                            Container(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 8.w,
                                                  vertical: 3.h),
                                              decoration: BoxDecoration(
                                                color: _statusColor(
                                                        order.status)
                                                    .withOpacity(0.12),
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        20.r),
                                              ),
                                              child: Text(
                                                Order.statusLabel(
                                                    order.status),
                                                style: TextStyle(
                                                    color: _statusColor(
                                                        order.status),
                                                    fontSize: 11.sp,
                                                    fontWeight:
                                                        FontWeight.w600),
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 6.h),
                                        Row(children: [
                                          Icon(Icons.shopping_bag_outlined,
                                              size: 14.sp,
                                              color: Colors.grey[500]),
                                          SizedBox(width: 4.w),
                                          Text(
                                              '${order.products.length} item(s)',
                                              style: TextStyle(
                                                  color: Colors.grey[600],
                                                  fontSize: 12.sp)),
                                          const Spacer(),
                                          Text(
                                              '\$${order.totalPrice.toStringAsFixed(2)}',
                                              style: TextStyle(
                                                  fontWeight:
                                                      FontWeight.bold,
                                                  fontSize: 14.sp,
                                                  color: GlobalVariables
                                                      .secondaryColor)),
                                        ]),
                                        SizedBox(height: 4.h),
                                        Row(children: [
                                          Icon(Icons.payment,
                                              size: 12.sp,
                                              color: Colors.grey[400]),
                                          SizedBox(width: 4.w),
                                          Text(order.paymentMethod,
                                              style: TextStyle(
                                                  color: Colors.grey[500],
                                                  fontSize: 11.sp)),
                                          SizedBox(width: 8.w),
                                          Text('·',
                                              style: TextStyle(
                                                  color: Colors.grey[400])),
                                          SizedBox(width: 8.w),
                                          Text(
                                            DateTime.fromMillisecondsSinceEpoch(
                                                    order.orderedAt)
                                                .toString()
                                                .substring(0, 10),
                                            style: TextStyle(
                                                color: Colors.grey[400],
                                                fontSize: 11.sp),
                                          ),
                                          const Spacer(),
                                          Icon(Icons.arrow_forward_ios,
                                              size: 12.sp,
                                              color: Colors.grey[400]),
                                        ]),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
              ],
            ),
          ),

          SizedBox(height: 8.h),

          // Sign out
          Container(
            color: Colors.white,
            padding: EdgeInsets.all(16.w),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.logout, color: Colors.white),
                label: Text('Sign Out',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 15.sp,
                        fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[400],
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r)),
                ),
                onPressed: () => AuthProvider().signOut(context),
              ),
            ),
          ),
          SizedBox(height: 20.h),
        ],
      ),
    );
  }

  Widget _statItem(String value, String label) {
    return Expanded(
      child: Column(children: [
        Text(value,
            style: TextStyle(
                fontSize: 20.sp, fontWeight: FontWeight.bold)),
        Text(label,
            style: TextStyle(color: Colors.grey[500], fontSize: 12.sp)),
      ]),
    );
  }

  Widget _divider() => Container(
      height: 30.h, width: 1, color: Colors.grey[200]);
}
