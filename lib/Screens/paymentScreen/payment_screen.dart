import 'package:ecomerce_app/Models/cart_item.dart';
import 'package:ecomerce_app/Providers/order_provider.dart';
import 'package:ecomerce_app/Providers/user_provider.dart';
import 'package:ecomerce_app/Screens/homeScreen/home_screen.dart';
import 'package:ecomerce_app/constants/globel_variable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class PaymentScreen extends StatefulWidget {
  static const String routeName = '/payment';
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();
  // Card fields
  final _cardNameController = TextEditingController();
  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();
  // UPI field
  final _upiController = TextEditingController();
  bool _placing = false;
  final _orderProvider = OrderProvider();

  String get _paymentMethod {
    switch (_tabController.index) {
      case 0: return 'Card';
      case 1: return 'UPI';
      case 2: return 'COD';
      default: return 'COD';
    }
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this, initialIndex: 2);
    final address =
        Provider.of<UserProvider>(context, listen: false).user.address;
    if (address.isNotEmpty) _addressController.text = address;
  }

  @override
  void dispose() {
    _tabController.dispose();
    _addressController.dispose();
    _cardNameController.dispose();
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    _upiController.dispose();
    super.dispose();
  }

  Future<void> _placeOrder(List<CartItem> cart, double total) async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _placing = true);
    final success = await _orderProvider.placeOrder(
      context: context,
      cart: cart,
      totalPrice: total,
      address: _addressController.text.trim(),
      paymentMethod: _paymentMethod,
    );
    setState(() => _placing = false);
    if (success && mounted) _showSuccessDialog(total);
  }

  void _showSuccessDialog(double total) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80.w,
              height: 80.w,
              decoration: const BoxDecoration(
                  color: Colors.green, shape: BoxShape.circle),
              child: Icon(Icons.check, color: Colors.white, size: 44.sp),
            ),
            SizedBox(height: 16.h),
            Text('Order Placed!',
                style: TextStyle(
                    fontSize: 22.sp, fontWeight: FontWeight.bold)),
            SizedBox(height: 8.h),
            Text('Your order of \$${total.toStringAsFixed(2)} has been placed.',
                textAlign: TextAlign.center,
                style:
                    TextStyle(color: Colors.grey[600], fontSize: 13.sp)),
            SizedBox(height: 6.h),
            Container(
              padding:
                  EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: GlobalVariables.secondaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Text('Payment: $_paymentMethod',
                  style: TextStyle(
                      color: GlobalVariables.secondaryColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 12.sp)),
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: GlobalVariables.secondaryColor,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r)),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushNamedAndRemoveUntil(
                    context, HomeScreen.routeName, (r) => false);
              },
              child: const Text('Continue Shopping',
                  style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final cart = args['cart'] as List<CartItem>;
    final total = args['total'] as double;

    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration:
              const BoxDecoration(gradient: GlobalVariables.appBarGradient),
        ),
        title: const Text('Checkout',
            style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Order summary card
              _buildOrderSummary(cart, total),
              SizedBox(height: 16.h),

              // Delivery address
              _sectionTitle('Delivery Address'),
              SizedBox(height: 8.h),
              TextFormField(
                controller: _addressController,
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: 'Enter your full delivery address',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.r)),
                  prefixIcon: const Icon(Icons.location_on_outlined),
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Enter delivery address' : null,
              ),
              SizedBox(height: 20.h),

              // Payment method tabs
              _sectionTitle('Payment Method'),
              SizedBox(height: 10.h),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14.r),
                  boxShadow: [
                    BoxShadow(color: Colors.black12, blurRadius: 8)
                  ],
                ),
                child: Column(
                  children: [
                    TabBar(
                      controller: _tabController,
                      onTap: (_) => setState(() {}),
                      labelColor: GlobalVariables.secondaryColor,
                      unselectedLabelColor: Colors.grey,
                      indicatorColor: GlobalVariables.secondaryColor,
                      indicatorSize: TabBarIndicatorSize.tab,
                      tabs: [
                        Tab(
                          icon: Icon(Icons.credit_card, size: 20.sp),
                          text: 'Card',
                        ),
                        Tab(
                          icon: Icon(Icons.account_balance_wallet_outlined,
                              size: 20.sp),
                          text: 'UPI',
                        ),
                        Tab(
                          icon: Icon(Icons.delivery_dining, size: 20.sp),
                          text: 'COD',
                        ),
                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.all(16.w),
                      child: [
                        _buildCardForm(),
                        _buildUpiForm(),
                        _buildCodInfo(),
                      ][_tabController.index],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24.h),

              // Place order button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: GlobalVariables.secondaryColor,
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r)),
                  ),
                  onPressed:
                      _placing ? null : () => _placeOrder(cart, total),
                  child: _placing
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.lock_outline,
                                color: Colors.white, size: 18.sp),
                            SizedBox(width: 8.w),
                            Text(
                                'Place Order · \$${total.toStringAsFixed(2)}',
                                style: TextStyle(
                                    fontSize: 16.sp,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                ),
              ),
              SizedBox(height: 8.h),
              Center(
                child: Text('🔒 Secure & Encrypted Payment',
                    style: TextStyle(
                        color: Colors.grey[500], fontSize: 11.sp)),
              ),
              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderSummary(List<CartItem> cart, double total) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Order Summary',
              style:
                  TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold)),
          SizedBox(height: 10.h),
          ...cart.map((item) => Padding(
                padding: EdgeInsets.only(bottom: 6.h),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6.r),
                      child: Image.network(
                        item.product.images.isNotEmpty
                            ? item.product.images[0]
                            : '',
                        width: 40.w,
                        height: 40.w,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                            width: 40.w,
                            height: 40.w,
                            color: GlobalVariables.greyBackgroundCOlor),
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Text(
                        '${item.product.name} x${item.quantity}',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 12.sp),
                      ),
                    ),
                    Text(
                      '\$${(item.product.price * item.quantity).toStringAsFixed(2)}',
                      style: TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 12.sp),
                    ),
                  ],
                ),
              )),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Subtotal',
                  style: TextStyle(fontSize: 13.sp, color: Colors.grey[600])),
              Text('\$${total.toStringAsFixed(2)}',
                  style: TextStyle(fontSize: 13.sp)),
            ],
          ),
          SizedBox(height: 4.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Delivery',
                  style: TextStyle(fontSize: 13.sp, color: Colors.grey[600])),
              Text('FREE',
                  style: TextStyle(
                      fontSize: 13.sp,
                      color: Colors.green,
                      fontWeight: FontWeight.w600)),
            ],
          ),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 15.sp)),
              Text('\$${total.toStringAsFixed(2)}',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18.sp,
                      color: GlobalVariables.secondaryColor)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCardForm() {
    return Column(children: [
      TextFormField(
        controller: _cardNameController,
        decoration: InputDecoration(
          labelText: 'Cardholder Name',
          prefixIcon: const Icon(Icons.person_outline),
          border:
              OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
        ),
        validator: (v) => _tabController.index == 0 && (v == null || v.isEmpty)
            ? 'Enter cardholder name'
            : null,
      ),
      SizedBox(height: 12.h),
      TextFormField(
        controller: _cardNumberController,
        keyboardType: TextInputType.number,
        maxLength: 16,
        decoration: InputDecoration(
          labelText: 'Card Number',
          prefixIcon: const Icon(Icons.credit_card),
          border:
              OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
          counterText: '',
          suffixIcon: Padding(
            padding: EdgeInsets.all(8.w),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.payment, color: Colors.blue[800], size: 20.sp),
                SizedBox(width: 4.w),
                Icon(Icons.payment, color: Colors.red, size: 20.sp),
              ],
            ),
          ),
        ),
        validator: (v) => _tabController.index == 0 && (v == null || v.length < 16)
            ? 'Enter valid 16-digit card number'
            : null,
      ),
      SizedBox(height: 12.h),
      Row(children: [
        Expanded(
          child: TextFormField(
            controller: _expiryController,
            keyboardType: TextInputType.datetime,
            decoration: InputDecoration(
              labelText: 'MM/YY',
              prefixIcon: const Icon(Icons.calendar_today),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r)),
            ),
            validator: (v) => _tabController.index == 0 &&
                    (v == null || v.isEmpty)
                ? 'Required'
                : null,
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: TextFormField(
            controller: _cvvController,
            keyboardType: TextInputType.number,
            maxLength: 3,
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'CVV',
              prefixIcon: const Icon(Icons.lock_outline),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r)),
              counterText: '',
            ),
            validator: (v) =>
                _tabController.index == 0 && (v == null || v.length < 3)
                    ? 'Invalid CVV'
                    : null,
          ),
        ),
      ]),
    ]);
  }

  Widget _buildUpiForm() {
    return Column(children: [
      Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: Colors.purple.withOpacity(0.05),
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: Colors.purple.withOpacity(0.2)),
        ),
        child: Row(children: [
          Icon(Icons.account_balance_wallet,
              color: Colors.purple, size: 24.sp),
          SizedBox(width: 10.w),
          Text('Pay instantly with UPI',
              style: TextStyle(
                  color: Colors.purple[700],
                  fontWeight: FontWeight.w600,
                  fontSize: 13.sp)),
        ]),
      ),
      SizedBox(height: 14.h),
      TextFormField(
        controller: _upiController,
        keyboardType: TextInputType.emailAddress,
        decoration: InputDecoration(
          labelText: 'UPI ID (e.g. name@upi)',
          prefixIcon: const Icon(Icons.alternate_email),
          border:
              OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
        ),
        validator: (v) => _tabController.index == 1 && (v == null || v.isEmpty)
            ? 'Enter UPI ID'
            : null,
      ),
      SizedBox(height: 12.h),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: ['GPay', 'PhonePe', 'Paytm', 'BHIM'].map((app) {
          return GestureDetector(
            onTap: () => _upiController.text = 'user@$app',
            child: Container(
              padding:
                  EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Text(app,
                  style: TextStyle(
                      fontSize: 11.sp, fontWeight: FontWeight.w500)),
            ),
          );
        }).toList(),
      ),
    ]);
  }

  Widget _buildCodInfo() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.05),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
      ),
      child: Column(children: [
        Icon(Icons.delivery_dining, color: Colors.orange, size: 48.sp),
        SizedBox(height: 10.h),
        Text('Cash on Delivery',
            style: TextStyle(
                fontSize: 16.sp, fontWeight: FontWeight.bold)),
        SizedBox(height: 6.h),
        Text(
          'Pay when your order arrives at your doorstep. No advance payment required.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey[600], fontSize: 12.sp),
        ),
        SizedBox(height: 10.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 16.sp),
            SizedBox(width: 4.w),
            Text('Free delivery on all COD orders',
                style: TextStyle(
                    color: Colors.green[700], fontSize: 12.sp)),
          ],
        ),
      ]),
    );
  }

  Widget _sectionTitle(String title) => Text(title,
      style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold));
}
