import 'package:ecomerce_app/Models/order.dart';
import 'package:ecomerce_app/constants/globel_variable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class OrderDetailScreen extends StatelessWidget {
  static const String routeName = '/order-detail';
  const OrderDetailScreen({super.key});

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
    final order = ModalRoute.of(context)!.settings.arguments as Order;

    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration:
              const BoxDecoration(gradient: GlobalVariables.appBarGradient),
        ),
        title: Text(
            'Order #${order.id.substring(order.id.length - 6).toUpperCase()}',
            style: const TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status tracker
            _buildStatusTracker(order.status),
            SizedBox(height: 16.h),

            // Order info card
            _card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionTitle('Order Information'),
                  SizedBox(height: 10.h),
                  _infoRow('Order ID',
                      '#${order.id.substring(order.id.length - 6).toUpperCase()}'),
                  _infoRow('Date',
                      DateTime.fromMillisecondsSinceEpoch(order.orderedAt)
                          .toString()
                          .substring(0, 16)),
                  _infoRow('Payment Method', order.paymentMethod),
                  _infoRow('Payment Status', order.paymentStatus,
                      valueColor: order.paymentStatus == 'Paid'
                          ? Colors.green
                          : Colors.orange),
                  _infoRow('Status', Order.statusLabel(order.status),
                      valueColor: _statusColor(order.status)),
                ],
              ),
            ),
            SizedBox(height: 12.h),

            // Delivery address
            _card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionTitle('Delivery Address'),
                  SizedBox(height: 8.h),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.location_on,
                          color: GlobalVariables.secondaryColor,
                          size: 18.sp),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(order.address,
                            style: TextStyle(
                                fontSize: 13.sp,
                                color: Colors.grey[700],
                                height: 1.4)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 12.h),

            // Products
            _card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionTitle('Items Ordered'),
                  SizedBox(height: 10.h),
                  ...order.products.map((item) {
                    final product = item['product'] as Map<String, dynamic>;
                    final qty = item['quantity'] as int;
                    final price = (product['price'] as num).toDouble();
                    final images =
                        List<String>.from(product['images'] ?? []);
                    return Padding(
                      padding: EdgeInsets.only(bottom: 12.h),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8.r),
                            child: images.isNotEmpty
                                ? Image.network(images[0],
                                    width: 60.w,
                                    height: 60.w,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Container(
                                        width: 60.w,
                                        height: 60.w,
                                        color: GlobalVariables
                                            .greyBackgroundCOlor))
                                : Container(
                                    width: 60.w,
                                    height: 60.w,
                                    color:
                                        GlobalVariables.greyBackgroundCOlor,
                                    child: const Icon(
                                        Icons.image_not_supported)),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(product['name'] ?? '',
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13.sp)),
                                SizedBox(height: 4.h),
                                Text('Qty: $qty',
                                    style: TextStyle(
                                        color: Colors.grey[500],
                                        fontSize: 12.sp)),
                              ],
                            ),
                          ),
                          Text(
                              '\$${(price * qty).toStringAsFixed(2)}',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14.sp)),
                        ],
                      ),
                    );
                  }),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Total',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15.sp)),
                      Text('\$${order.totalPrice.toStringAsFixed(2)}',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18.sp,
                              color: GlobalVariables.secondaryColor)),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusTracker(int currentStatus) {
    final steps = ['Placed', 'Processing', 'Shipped', 'Delivered'];
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Order Status',
              style:
                  TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold)),
          SizedBox(height: 16.h),
          Row(
            children: List.generate(steps.length * 2 - 1, (i) {
              if (i.isOdd) {
                final stepIndex = i ~/ 2;
                return Expanded(
                  child: Container(
                    height: 3.h,
                    color: stepIndex < currentStatus
                        ? Colors.green
                        : Colors.grey[300],
                  ),
                );
              }
              final stepIndex = i ~/ 2;
              final done = stepIndex <= currentStatus;
              return Column(
                children: [
                  Container(
                    width: 28.w,
                    height: 28.w,
                    decoration: BoxDecoration(
                      color: done ? Colors.green : Colors.grey[300],
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      done ? Icons.check : Icons.circle,
                      color: Colors.white,
                      size: 14.sp,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(steps[stepIndex],
                      style: TextStyle(
                          fontSize: 9.sp,
                          color: done ? Colors.green : Colors.grey,
                          fontWeight: done
                              ? FontWeight.bold
                              : FontWeight.normal)),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _card({required Widget child}) => Container(
        width: double.infinity,
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14.r),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
        ),
        child: child,
      );

  Widget _sectionTitle(String t) => Text(t,
      style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold));

  Widget _infoRow(String label, String value, {Color? valueColor}) =>
      Padding(
        padding: EdgeInsets.only(bottom: 6.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: TextStyle(
                    color: Colors.grey[600], fontSize: 12.sp)),
            Text(value,
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 12.sp,
                    color: valueColor ?? Colors.black87)),
          ],
        ),
      );
}
