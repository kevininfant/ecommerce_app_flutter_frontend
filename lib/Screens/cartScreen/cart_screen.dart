import 'package:ecomerce_app/Models/cart_item.dart';
import 'package:ecomerce_app/Providers/cart_provider.dart';
import 'package:ecomerce_app/Screens/paymentScreen/payment_screen.dart';
import 'package:ecomerce_app/constants/globel_variable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CartScreen extends StatefulWidget {
  static const String routeName = '/cart';
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final _cartProvider = CartProvider();
  List<CartItem> _cartItems = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadCart();
  }

  Future<void> _loadCart() async {
    setState(() => _loading = true);
    final items = await _cartProvider.fetchCart(context);
    setState(() {
      _cartItems = items;
      _loading = false;
    });
  }

  double get _total =>
      _cartItems.fold(0, (sum, i) => sum + i.product.price * i.quantity);

  Widget _buildBody() {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_cartItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_cart_outlined,
                size: 80.sp, color: Colors.grey[300]),
            SizedBox(height: 16.h),
            Text('Your cart is empty',
                style:
                    TextStyle(fontSize: 18.sp, color: Colors.grey[500])),
            SizedBox(height: 12.h),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: GlobalVariables.secondaryColor),
              onPressed: () => Navigator.pop(context),
              child: const Text('Continue Shopping',
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    }
    return Column(
      children: [
        Expanded(
          child: RefreshIndicator(
            onRefresh: _loadCart,
            child: ListView.builder(
              padding: EdgeInsets.all(12.w),
              itemCount: _cartItems.length,
              itemBuilder: (ctx, i) => _CartItemCard(
                item: _cartItems[i],
                onChanged: _loadCart,
              ),
            ),
          ),
        ),
        _buildCheckoutBar(),
      ],
    );
  }

  Widget _buildCheckoutBar() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: const Offset(0, -2))
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total (${_cartItems.length} items)',
                  style: TextStyle(
                      fontSize: 15.sp, fontWeight: FontWeight.w500)),
              Text('\$${_total.toStringAsFixed(2)}',
                  style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: GlobalVariables.secondaryColor)),
            ],
          ),
          SizedBox(height: 12.h),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: GlobalVariables.secondaryColor,
                padding: EdgeInsets.symmetric(vertical: 14.h),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r)),
              ),
              onPressed: () => Navigator.pushNamed(
                context,
                PaymentScreen.routeName,
                arguments: {'cart': _cartItems, 'total': _total},
              ).then((_) => _loadCart()),
              child: Text('Proceed to Checkout',
                  style: TextStyle(
                      fontSize: 16.sp,
                      color: Colors.white,
                      fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // When pushed as a named route, wrap with Scaffold + AppBar
    final isRoute =
        ModalRoute.of(context)?.settings.name == CartScreen.routeName;

    if (isRoute) {
      return Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        appBar: AppBar(
          flexibleSpace: Container(
            decoration: const BoxDecoration(
                gradient: GlobalVariables.appBarGradient),
          ),
          title: const Text('My Cart',
              style: TextStyle(color: Colors.white)),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: _buildBody(),
      );
    }

    // When used as a tab inside HomeScreen, return body directly
    return _buildBody();
  }
}

class _CartItemCard extends StatelessWidget {
  final CartItem item;
  final VoidCallback onChanged;
  const _CartItemCard({required this.item, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final cartProvider = CartProvider();
    return Card(
      margin: EdgeInsets.only(bottom: 10.h),
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: Padding(
        padding: EdgeInsets.all(10.w),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8.r),
              child: Image.network(
                item.product.images.isNotEmpty
                    ? item.product.images[0]
                    : '',
                width: 70.w,
                height: 70.w,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 70.w,
                  height: 70.w,
                  color: GlobalVariables.greyBackgroundCOlor,
                  child: const Icon(Icons.image_not_supported),
                ),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.product.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 13.sp)),
                  SizedBox(height: 4.h),
                  Text('\$${item.product.price.toStringAsFixed(2)}',
                      style: TextStyle(
                          color: GlobalVariables.secondaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 14.sp)),
                  SizedBox(height: 2.h),
                  Text(
                      'Subtotal: \$${(item.product.price * item.quantity).toStringAsFixed(2)}',
                      style: TextStyle(
                          color: Colors.grey[500], fontSize: 11.sp)),
                ],
              ),
            ),
            Column(
              children: [
                IconButton(
                  icon: Icon(Icons.add_circle,
                      color: GlobalVariables.secondaryColor),
                  onPressed: () async {
                    await cartProvider.addToCart(context, item.product.id);
                    onChanged();
                  },
                ),
                Text('${item.quantity}',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16.sp)),
                IconButton(
                  icon: Icon(Icons.remove_circle,
                      color: Colors.grey[400]),
                  onPressed: () async {
                    await cartProvider.removeFromCart(
                        context, item.product.id);
                    onChanged();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
