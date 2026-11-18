import 'dart:async';
import 'dart:convert';
import 'package:ecomerce_app/Models/banner_model.dart';
import 'package:ecomerce_app/Models/product.dart';
import 'package:ecomerce_app/Providers/product_provider.dart';
import 'package:ecomerce_app/Providers/user_provider.dart';
import 'package:ecomerce_app/Screens/cartScreen/cart_screen.dart';
import 'package:ecomerce_app/Screens/feedbackScreen/feedback_screen.dart';
import 'package:ecomerce_app/Screens/offersScreen/offers_screen.dart';
import 'package:ecomerce_app/Screens/productScreen/product_detail_screen.dart';
import 'package:ecomerce_app/Screens/profileScreen/profile_screen.dart';
import 'package:ecomerce_app/constants/globel_variable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  static const String routeName = '/home';
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  List<Product> _products = [];
  List<Product> _filtered = [];
  List<BannerModel> _sliderBanners = [];
  List<BannerModel> _footerBanners = [];
  bool _loading = true;
  String _selectedCategory = 'All';
  final _searchController = TextEditingController();
  final _productProvider = ProductProvider();
  final _bannerController = PageController();
  int _currentBanner = 0;
  Timer? _bannerTimer;

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  @override
  void dispose() {
    _bannerTimer?.cancel();
    _bannerController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadAll() async {
    setState(() => _loading = true);
    await Future.wait([_loadProducts(), _loadBanners()]);
    setState(() => _loading = false);
    _startBannerTimer();
  }

  Future<void> _loadProducts() async {
    final products = await _productProvider.fetchAllProducts(context);
    _products = products;
    _filtered = products;
  }

  Future<void> _loadBanners() async {
    final token = Provider.of<UserProvider>(context, listen: false).user.token;
    try {
      final sliderRes = await http.get(
        Uri.parse('$uri/banners?type=slider'),
        headers: {'x-auth-token': token},
      );
      final footerRes = await http.get(
        Uri.parse('$uri/banners?type=footer'),
        headers: {'x-auth-token': token},
      );
      if (sliderRes.statusCode == 200) {
        _sliderBanners = (jsonDecode(sliderRes.body) as List)
            .map((e) => BannerModel.fromMap(e))
            .toList();
      }
      if (footerRes.statusCode == 200) {
        _footerBanners = (jsonDecode(footerRes.body) as List)
            .map((e) => BannerModel.fromMap(e))
            .toList();
      }
    } catch (_) {}
  }

  void _startBannerTimer() {
    if (_sliderBanners.isEmpty) return;
    _bannerTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!mounted) return;
      final next = (_currentBanner + 1) % _sliderBanners.length;
      _bannerController.animateToPage(next,
          duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
    });
  }

  void _filterByCategory(String category) {
    setState(() {
      _selectedCategory = category;
      _filtered = category == 'All'
          ? _products
          : _products.where((p) => p.category == category).toList();
    });
  }

  void _search(String query) {
    setState(() {
      _filtered = query.isEmpty
          ? _products
          : _products
              .where((p) =>
                  p.name.toLowerCase().contains(query.toLowerCase()) ||
                  p.category.toLowerCase().contains(query.toLowerCase()))
              .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final pages = [_buildHome(), const CartScreen(), const ProfileScreen()];
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: GlobalVariables.appBarGradient),
        ),
        title: Row(children: [
          Icon(Icons.shopping_bag_rounded,
              color: GlobalVariables.secondaryColor, size: 26.sp),
          SizedBox(width: 6.w),
          Text('ShopEasy',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20.sp,
                  color: Colors.white)),
        ]),
        actions: [
          IconButton(
            icon: const Icon(Icons.local_offer_outlined, color: Colors.white),
            onPressed: () =>
                Navigator.pushNamed(context, OffersScreen.routeName),
            tooltip: 'Offers',
          ),
          IconButton(
            icon: const Icon(Icons.feedback_outlined, color: Colors.white),
            onPressed: () =>
                Navigator.pushNamed(context, FeedbackScreen.routeName),
            tooltip: 'Feedback',
          ),
        ],
      ),
      body: pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: GlobalVariables.selectedNavBarColor,
        unselectedItemColor: GlobalVariables.unselectedNavBarColor,
        onTap: (i) => setState(() => _currentIndex = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart), label: 'Cart'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildHome() {
    return RefreshIndicator(
      onRefresh: _loadAll,
      child: _loading
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
              slivers: [
                // Search bar
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(12.w, 12.h, 12.w, 6.h),
                    child: TextField(
                      controller: _searchController,
                      onChanged: _search,
                      decoration: InputDecoration(
                        hintText: 'Search products...',
                        prefixIcon: const Icon(Icons.search),
                        filled: true,
                        fillColor: GlobalVariables.greyBackgroundCOlor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30.r),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: EdgeInsets.symmetric(
                            vertical: 0, horizontal: 16.w),
                      ),
                    ),
                  ),
                ),

                // Slider banners
                if (_sliderBanners.isNotEmpty)
                  SliverToBoxAdapter(child: _buildSliderBanner()),

                // Category chips
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 44.h,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: EdgeInsets.symmetric(
                          horizontal: 12.w, vertical: 4.h),
                      children:
                          ['All', ...GlobalVariables.categories].map((cat) {
                        final selected = _selectedCategory == cat;
                        return Padding(
                          padding: EdgeInsets.only(right: 8.w),
                          child: ChoiceChip(
                            label: Text(cat),
                            selected: selected,
                            selectedColor: GlobalVariables.secondaryColor,
                            labelStyle: TextStyle(
                                color: selected
                                    ? Colors.white
                                    : Colors.black87,
                                fontSize: 12.sp),
                            onSelected: (_) => _filterByCategory(cat),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),

                // Section title
                SliverToBoxAdapter(
                  child: Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
                    child: Text(
                      _selectedCategory == 'All'
                          ? 'All Products'
                          : _selectedCategory,
                      style: TextStyle(
                          fontSize: 16.sp, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),

                // Products grid
                _filtered.isEmpty
                    ? SliverToBoxAdapter(
                        child: Center(
                          child: Padding(
                            padding: EdgeInsets.all(40.h),
                            child: Text('No products found',
                                style: TextStyle(
                                    color: Colors.grey[500],
                                    fontSize: 14.sp)),
                          ),
                        ),
                      )
                    : SliverPadding(
                        padding: EdgeInsets.symmetric(horizontal: 12.w),
                        sliver: SliverGrid(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.70,
                            crossAxisSpacing: 10.w,
                            mainAxisSpacing: 10.h,
                          ),
                          delegate: SliverChildBuilderDelegate(
                            (ctx, i) => _ProductCard(product: _filtered[i]),
                            childCount: _filtered.length,
                          ),
                        ),
                      ),

                // Footer banners
                if (_footerBanners.isNotEmpty)
                  SliverToBoxAdapter(child: _buildFooterBanners()),

                SliverToBoxAdapter(child: SizedBox(height: 20.h)),

                // Footer address
                SliverToBoxAdapter(child: _buildFooterAddress()),
              ],
            ),
    );
  }

  Widget _buildFooterAddress() {
    return Container(
      width: double.infinity,
      color: const Color(0xFF1A1A2E),
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 28.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo row
          Row(children: [
            Icon(Icons.shopping_bag_rounded,
                color: GlobalVariables.secondaryColor, size: 28.sp),
            SizedBox(width: 8.w),
            Text('ShopEasy',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1)),
          ]),
          SizedBox(height: 6.h),
          Text('Your one-stop online shopping destination',
              style: TextStyle(color: Colors.white54, fontSize: 11.sp)),
          SizedBox(height: 20.h),
          Divider(color: Colors.white12),
          SizedBox(height: 16.h),

          // Contact info
          Text('Contact Us',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 13.sp,
                  fontWeight: FontWeight.bold)),
          SizedBox(height: 10.h),
          _footerRow(Icons.location_on_outlined,
              '123, ShopEasy Tower, MG Road,\nBangalore - 560001, Karnataka, India'),
          SizedBox(height: 8.h),
          _footerRow(Icons.phone_outlined, '+91 98765 43210'),
          SizedBox(height: 8.h),
          _footerRow(Icons.email_outlined, 'support@shopeasy.com'),
          SizedBox(height: 8.h),
          _footerRow(Icons.access_time_outlined, 'Mon - Sat: 9:00 AM – 6:00 PM'),
          SizedBox(height: 20.h),
          Divider(color: Colors.white12),
          SizedBox(height: 12.h),

          // Quick links
          Text('Quick Links',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 13.sp,
                  fontWeight: FontWeight.bold)),
          SizedBox(height: 10.h),
          Wrap(
            spacing: 16.w,
            runSpacing: 6.h,
            children: [
              'Home', 'Offers', 'My Orders', 'Feedback', 'Privacy Policy', 'Terms of Service'
            ].map((link) => Text(link,
                style: TextStyle(
                    color: Colors.white60,
                    fontSize: 11.sp,
                    decoration: TextDecoration.underline,
                    decorationColor: Colors.white30))).toList(),
          ),
          SizedBox(height: 20.h),
          Divider(color: Colors.white12),
          SizedBox(height: 12.h),

          // Copyright
          Center(
            child: Text(
              '© ${DateTime.now().year} ShopEasy. All rights reserved.',
              style: TextStyle(color: Colors.white38, fontSize: 10.sp),
            ),
          ),
          SizedBox(height: 4.h),
          Center(
            child: Text(
              'Made with ❤️ in India',
              style: TextStyle(color: Colors.white38, fontSize: 10.sp),
            ),
          ),
          SizedBox(height: 8.h),
        ],
      ),
    );
  }

  Widget _footerRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: GlobalVariables.secondaryColor, size: 15.sp),
        SizedBox(width: 8.w),
        Expanded(
          child: Text(text,
              style: TextStyle(color: Colors.white60, fontSize: 11.sp, height: 1.5)),
        ),
      ],
    );
  }

  Widget _buildSliderBanner() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      height: 160.h,
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14.r),
            child: PageView.builder(
              controller: _bannerController,
              itemCount: _sliderBanners.length,
              onPageChanged: (i) => setState(() => _currentBanner = i),
              itemBuilder: (ctx, i) {
                final b = _sliderBanners[i];
                return Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(b.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                            color: GlobalVariables.greyBackgroundCOlor)),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withOpacity(0.6),
                            Colors.transparent
                          ],
                        ),
                      ),
                    ),
                    if (b.title.isNotEmpty)
                      Positioned(
                        bottom: 14.h,
                        left: 14.w,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(b.title,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold)),
                            if (b.subtitle.isNotEmpty)
                              Text(b.subtitle,
                                  style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 11.sp)),
                          ],
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
          // Dots indicator
          Positioned(
            bottom: 8.h,
            right: 12.w,
            child: Row(
              children: List.generate(
                _sliderBanners.length,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: EdgeInsets.only(left: 4.w),
                  width: _currentBanner == i ? 16.w : 6.w,
                  height: 6.h,
                  decoration: BoxDecoration(
                    color: _currentBanner == i
                        ? Colors.white
                        : Colors.white54,
                    borderRadius: BorderRadius.circular(3.r),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooterBanners() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(14.w, 16.h, 14.w, 8.h),
          child: Text('Special Deals',
              style:
                  TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
        ),
        SizedBox(
          height: 120.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            itemCount: _footerBanners.length,
            itemBuilder: (ctx, i) {
              final b = _footerBanners[i];
              return Container(
                width: 260.w,
                margin: EdgeInsets.only(right: 10.w),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12.r),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(b.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                              color: GlobalVariables.greyBackgroundCOlor)),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.black.withOpacity(0.5),
                              Colors.transparent
                            ],
                            begin: Alignment.bottomLeft,
                            end: Alignment.topRight,
                          ),
                        ),
                      ),
                      if (b.title.isNotEmpty)
                        Positioned(
                          bottom: 10.h,
                          left: 10.w,
                          child: Text(b.title,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13.sp)),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _ProductCard extends StatelessWidget {
  final Product product;
  const _ProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    final avgRating = product.rating.isEmpty
        ? 0.0
        : product.rating.fold(0.0, (s, r) => s + (r['rating'] ?? 0)) /
            product.rating.length;

    return GestureDetector(
      onTap: () => Navigator.pushNamed(
          context, ProductDetailScreen.routeName,
          arguments: product),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
                color: Colors.black12,
                blurRadius: 6,
                offset: const Offset(0, 2))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius:
                  BorderRadius.vertical(top: Radius.circular(12.r)),
              child: Image.network(
                product.images.isNotEmpty ? product.images[0] : '',
                height: 130.h,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 130.h,
                  color: GlobalVariables.greyBackgroundCOlor,
                  child: const Icon(Icons.image_not_supported, size: 40),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 12.sp)),
                  SizedBox(height: 3.h),
                  Text('\$${product.price.toStringAsFixed(2)}',
                      style: TextStyle(
                          color: GlobalVariables.secondaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 14.sp)),
                  SizedBox(height: 3.h),
                  Row(children: [
                    Icon(Icons.star, color: Colors.amber, size: 12.sp),
                    SizedBox(width: 2.w),
                    Text(avgRating.toStringAsFixed(1),
                        style: TextStyle(
                            fontSize: 10.sp, color: Colors.grey[600])),
                    SizedBox(width: 4.w),
                    Text(product.category,
                        style: TextStyle(
                            color: Colors.grey[400], fontSize: 10.sp)),
                  ]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
