import 'package:ecomerce_app/Models/product.dart';
import 'package:ecomerce_app/Providers/cart_provider.dart';
import 'package:ecomerce_app/Providers/product_provider.dart';
import 'package:ecomerce_app/Screens/paymentScreen/payment_screen.dart';
import 'package:ecomerce_app/constants/globel_variable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProductDetailScreen extends StatefulWidget {
  static const String routeName = '/product-detail';
  const ProductDetailScreen({super.key});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final _cartProvider = CartProvider();
  final _productProvider = ProductProvider();
  double _userRating = 0;
  bool _addingToCart = false;
  int _selectedImage = 0;
  int _quantity = 1;

  @override
  Widget build(BuildContext context) {
    final product = ModalRoute.of(context)!.settings.arguments as Product;
    final avgRating = product.rating.isEmpty
        ? 0.0
        : product.rating.fold(0.0, (s, r) => s + (r['rating'] ?? 0)) /
            product.rating.length;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        flexibleSpace: Container(
          decoration:
              const BoxDecoration(gradient: GlobalVariables.appBarGradient),
        ),
        title: Text(product.name,
            style: const TextStyle(color: Colors.white),
            overflow: TextOverflow.ellipsis),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Main image
            Container(
              color: Colors.white,
              child: Column(
                children: [
                  Image.network(
                    product.images.isNotEmpty
                        ? product.images[_selectedImage]
                        : '',
                    width: double.infinity,
                    height: 280.h,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => Container(
                      height: 280.h,
                      color: GlobalVariables.greyBackgroundCOlor,
                      child: const Icon(Icons.image_not_supported, size: 60),
                    ),
                  ),
                  // Image thumbnails
                  if (product.images.length > 1)
                    SizedBox(
                      height: 60.h,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: EdgeInsets.symmetric(
                            horizontal: 12.w, vertical: 6.h),
                        itemCount: product.images.length,
                        itemBuilder: (ctx, i) => GestureDetector(
                          onTap: () => setState(() => _selectedImage = i),
                          child: Container(
                            width: 50.w,
                            margin: EdgeInsets.only(right: 8.w),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: _selectedImage == i
                                    ? GlobalVariables.secondaryColor
                                    : Colors.grey[300]!,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(6.r),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4.r),
                              child: Image.network(product.images[i],
                                  fit: BoxFit.cover),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            SizedBox(height: 8.h),

            // Product info card
            Container(
              color: Colors.white,
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category + stock row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 10.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: GlobalVariables.secondaryColor
                              .withOpacity(0.12),
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Text(product.category,
                            style: TextStyle(
                                color: GlobalVariables.secondaryColor,
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w600)),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 10.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: product.quantity > 0
                              ? Colors.green.withOpacity(0.1)
                              : Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Text(
                          product.quantity > 0
                              ? '✓ In Stock (${product.quantity})'
                              : '✗ Out of Stock',
                          style: TextStyle(
                              color: product.quantity > 0
                                  ? Colors.green[700]
                                  : Colors.red,
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10.h),

                  // Name
                  Text(product.name,
                      style: TextStyle(
                          fontSize: 20.sp, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8.h),

                  // Price row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('\$${product.price.toStringAsFixed(2)}',
                          style: TextStyle(
                              fontSize: 26.sp,
                              color: GlobalVariables.secondaryColor,
                              fontWeight: FontWeight.bold)),
                      SizedBox(width: 8.w),
                      Text(
                          '\$${(product.price * 1.2).toStringAsFixed(2)}',
                          style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.grey[400],
                              decoration: TextDecoration.lineThrough)),
                      SizedBox(width: 8.w),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 6.w, vertical: 2.h),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        child: Text('17% OFF',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 10.sp,
                                fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  SizedBox(height: 6.h),

                  // Rating row
                  Row(children: [
                    ...List.generate(
                        5,
                        (i) => Icon(
                              i < avgRating.round()
                                  ? Icons.star
                                  : Icons.star_border,
                              color: Colors.amber,
                              size: 16.sp,
                            )),
                    SizedBox(width: 6.w),
                    Text(avgRating.toStringAsFixed(1),
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 13.sp)),
                    Text(' (${product.rating.length} reviews)',
                        style: TextStyle(
                            color: Colors.grey[500], fontSize: 12.sp)),
                  ]),
                ],
              ),
            ),

            SizedBox(height: 8.h),

            // Quantity selector
            Container(
              color: Colors.white,
              padding: EdgeInsets.symmetric(
                  horizontal: 16.w, vertical: 12.h),
              child: Row(
                children: [
                  Text('Quantity:',
                      style: TextStyle(
                          fontSize: 14.sp, fontWeight: FontWeight.w500)),
                  const Spacer(),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Row(children: [
                      IconButton(
                        icon: const Icon(Icons.remove),
                        onPressed: () {
                          if (_quantity > 1)
                            setState(() => _quantity--);
                        },
                        iconSize: 18.sp,
                        padding: EdgeInsets.all(6.w),
                        constraints: const BoxConstraints(),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12.w),
                        child: Text('$_quantity',
                            style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold)),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () => setState(() => _quantity++),
                        iconSize: 18.sp,
                        padding: EdgeInsets.all(6.w),
                        constraints: const BoxConstraints(),
                      ),
                    ]),
                  ),
                ],
              ),
            ),

            SizedBox(height: 8.h),

            // Description
            Container(
              color: Colors.white,
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Product Description',
                      style: TextStyle(
                          fontSize: 15.sp, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8.h),
                  Text(product.description,
                      style: TextStyle(
                          fontSize: 13.sp,
                          color: Colors.grey[700],
                          height: 1.6)),
                ],
              ),
            ),

            SizedBox(height: 8.h),

            // Rate this product
            Container(
              color: Colors.white,
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Rate this Product',
                      style: TextStyle(
                          fontSize: 15.sp, fontWeight: FontWeight.bold)),
                  SizedBox(height: 10.h),
                  Row(
                    children: List.generate(5, (i) {
                      return GestureDetector(
                        onTap: () {
                          setState(() => _userRating = i + 1.0);
                          _productProvider.rateProduct(
                              context, product.id, i + 1.0);
                        },
                        child: Padding(
                          padding: EdgeInsets.only(right: 6.w),
                          child: Icon(
                            i < _userRating
                                ? Icons.star
                                : Icons.star_border,
                            color: Colors.amber,
                            size: 34.sp,
                          ),
                        ),
                      );
                    }),
                  ),
                  if (_userRating > 0)
                    Padding(
                      padding: EdgeInsets.only(top: 6.h),
                      child: Text(
                        'You rated: ${_userRating.toInt()}/5 ⭐',
                        style: TextStyle(
                            color: Colors.grey[600], fontSize: 12.sp),
                      ),
                    ),
                ],
              ),
            ),

            SizedBox(height: 100.h),
          ],
        ),
      ),

      // Bottom action bar
      bottomNavigationBar: Container(
        padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 16.h),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
                color: Colors.black12,
                blurRadius: 8,
                offset: const Offset(0, -2))
          ],
        ),
        child: Row(children: [
          Expanded(
            child: OutlinedButton.icon(
              icon: const Icon(Icons.shopping_cart_outlined),
              label: const Text('Add to Cart'),
              style: OutlinedButton.styleFrom(
                foregroundColor: GlobalVariables.secondaryColor,
                side: const BorderSide(
                    color: GlobalVariables.secondaryColor, width: 1.5),
                padding: EdgeInsets.symmetric(vertical: 14.h),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r)),
              ),
              onPressed: _addingToCart
                  ? null
                  : () async {
                      setState(() => _addingToCart = true);
                      for (int i = 0; i < _quantity; i++) {
                        await _cartProvider.addToCart(
                            context, product.id);
                      }
                      setState(() => _addingToCart = false);
                    },
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: ElevatedButton.icon(
              icon: const Icon(Icons.flash_on, color: Colors.white),
              label: const Text('Buy Now',
                  style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: GlobalVariables.secondaryColor,
                padding: EdgeInsets.symmetric(vertical: 14.h),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r)),
              ),
              onPressed: () async {
                setState(() => _addingToCart = true);
                await _cartProvider.addToCart(context, product.id);
                setState(() => _addingToCart = false);
                if (context.mounted) {
                  final cartItems = await _cartProvider.fetchCart(context);
                  if (context.mounted) {
                    final total = cartItems.fold(
                        0.0, (s, i) => s + i.product.price * i.quantity);
                    Navigator.pushNamed(
                      context,
                      PaymentScreen.routeName,
                      arguments: {'cart': cartItems, 'total': total},
                    );
                  }
                }
              },
            ),
          ),
        ]),
      ),
    );
  }
}
