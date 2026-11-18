import 'dart:convert';
import 'package:ecomerce_app/Models/banner_model.dart';
import 'package:ecomerce_app/Models/order.dart';
import 'package:ecomerce_app/Models/product.dart';
import 'package:ecomerce_app/Providers/user_provider.dart';
import 'package:ecomerce_app/constants/globel_variable.dart';
import 'package:ecomerce_app/constants/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class AdminScreen extends StatefulWidget {
  static const String routeName = '/admin';
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Map<String, dynamic> _stats = {};
  List<Product> _products = [];
  List<BannerModel> _banners = [];
  List<Order> _orders = [];
  List<dynamic> _feedbacks = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _loadAll();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String get _token =>
      Provider.of<UserProvider>(context, listen: false).user.token;

  Future<void> _loadAll() async {
    setState(() => _loading = true);
    await Future.wait([
      _loadStats(),
      _loadProducts(),
      _loadBanners(),
      _loadOrders(),
      _loadFeedbacks(),
    ]);
    setState(() => _loading = false);
  }

  Future<void> _loadStats() async {
    try {
      final res = await http.get(Uri.parse('$uri/admin/stats'),
          headers: {'x-auth-token': _token});
      if (res.statusCode == 200) _stats = jsonDecode(res.body);
    } catch (_) {}
  }

  Future<void> _loadProducts() async {
    try {
      final res = await http.get(Uri.parse('$uri/admin/products'),
          headers: {'x-auth-token': _token});
      if (res.statusCode == 200) {
        _products = (jsonDecode(res.body) as List)
            .map((e) => Product.fromMap(e))
            .toList();
      }
    } catch (_) {}
  }

  Future<void> _loadBanners() async {
    try {
      final res = await http.get(Uri.parse('$uri/admin/banners'),
          headers: {'x-auth-token': _token});
      if (res.statusCode == 200) {
        _banners = (jsonDecode(res.body) as List)
            .map((e) => BannerModel.fromMap(e))
            .toList();
      }
    } catch (_) {}
  }

  Future<void> _loadOrders() async {
    try {
      final res = await http.get(Uri.parse('$uri/admin/orders'),
          headers: {'x-auth-token': _token});
      if (res.statusCode == 200) {
        _orders = (jsonDecode(res.body) as List)
            .map((e) => Order.fromMap(e))
            .toList();
      }
    } catch (_) {}
  }

  Future<void> _loadFeedbacks() async {
    try {
      final res = await http.get(Uri.parse('$uri/admin/feedback'),
          headers: {'x-auth-token': _token});
      if (res.statusCode == 200) _feedbacks = jsonDecode(res.body);
    } catch (_) {}
  }

  Future<void> _deleteProduct(String id) async {
    try {
      await http.delete(Uri.parse('$uri/admin/products/$id'),
          headers: {'x-auth-token': _token});
      await _loadProducts();
      setState(() {});
      if (mounted) showSnackBar(context, 'Product deleted');
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }

  Future<void> _deleteBanner(String id) async {
    try {
      await http.delete(Uri.parse('$uri/admin/banners/$id'),
          headers: {'x-auth-token': _token});
      await _loadBanners();
      setState(() {});
      if (mounted) showSnackBar(context, 'Banner deleted');
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }

  Future<void> _updateOrderStatus(String id, int status) async {
    try {
      await http.put(
        Uri.parse('$uri/admin/orders/$id/status'),
        headers: {
          'Content-Type': 'application/json',
          'x-auth-token': _token
        },
        body: jsonEncode({'status': status}),
      );
      await _loadOrders();
      setState(() {});
      if (mounted) showSnackBar(context, 'Order status updated');
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }

  void _showAddProductDialog([Product? existing]) {
    final nameC = TextEditingController(text: existing?.name ?? '');
    final descC = TextEditingController(text: existing?.description ?? '');
    final priceC = TextEditingController(
        text: existing != null ? existing.price.toString() : '');
    final qtyC = TextEditingController(
        text: existing != null ? existing.quantity.toString() : '');
    final imgC = TextEditingController(
        text: existing?.images.isNotEmpty == true ? existing!.images[0] : '');
    String category = existing?.category ?? GlobalVariables.categories[0];

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          title: Text(existing == null ? 'Add Product' : 'Edit Product'),
          content: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              _dialogField(nameC, 'Product Name'),
              SizedBox(height: 10.h),
              _dialogField(descC, 'Description', maxLines: 3),
              SizedBox(height: 10.h),
              _dialogField(priceC, 'Price', type: TextInputType.number),
              SizedBox(height: 10.h),
              _dialogField(qtyC, 'Quantity', type: TextInputType.number),
              SizedBox(height: 10.h),
              _dialogField(imgC, 'Image URL'),
              SizedBox(height: 10.h),
              DropdownButtonFormField<String>(
                value: category,
                decoration: InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r)),
                ),
                items: GlobalVariables.categories
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) => setS(() => category = v!),
              ),
            ]),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: GlobalVariables.secondaryColor),
              onPressed: () async {
                final body = jsonEncode({
                  'name': nameC.text,
                  'description': descC.text,
                  'price': double.tryParse(priceC.text) ?? 0,
                  'quantity': int.tryParse(qtyC.text) ?? 0,
                  'images': [imgC.text],
                  'category': category,
                });
                if (existing == null) {
                  await http.post(Uri.parse('$uri/admin/products'),
                      headers: {
                        'Content-Type': 'application/json',
                        'x-auth-token': _token
                      },
                      body: body);
                } else {
                  await http.put(
                      Uri.parse('$uri/admin/products/${existing.id}'),
                      headers: {
                        'Content-Type': 'application/json',
                        'x-auth-token': _token
                      },
                      body: body);
                }
                Navigator.pop(ctx);
                await _loadProducts();
                setState(() {});
                if (mounted) showSnackBar(context, 'Product saved!');
              },
              child: const Text('Save', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddBannerDialog([BannerModel? existing]) {
    final imgC = TextEditingController(text: existing?.imageUrl ?? '');
    final titleC = TextEditingController(text: existing?.title ?? '');
    final subC = TextEditingController(text: existing?.subtitle ?? '');
    String type = existing?.type ?? 'slider';

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          title: Text(existing == null ? 'Add Banner' : 'Edit Banner'),
          content: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              _dialogField(imgC, 'Image URL'),
              SizedBox(height: 10.h),
              _dialogField(titleC, 'Title'),
              SizedBox(height: 10.h),
              _dialogField(subC, 'Subtitle'),
              SizedBox(height: 10.h),
              DropdownButtonFormField<String>(
                value: type,
                decoration: InputDecoration(
                  labelText: 'Type',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r)),
                ),
                items: ['slider', 'footer']
                    .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                    .toList(),
                onChanged: (v) => setS(() => type = v!),
              ),
            ]),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: GlobalVariables.secondaryColor),
              onPressed: () async {
                final body = jsonEncode({
                  'imageUrl': imgC.text,
                  'title': titleC.text,
                  'subtitle': subC.text,
                  'type': type,
                  'isActive': true,
                });
                if (existing == null) {
                  await http.post(Uri.parse('$uri/admin/banners'),
                      headers: {
                        'Content-Type': 'application/json',
                        'x-auth-token': _token
                      },
                      body: body);
                } else {
                  await http.put(
                      Uri.parse('$uri/admin/banners/${existing.id}'),
                      headers: {
                        'Content-Type': 'application/json',
                        'x-auth-token': _token
                      },
                      body: body);
                }
                Navigator.pop(ctx);
                await _loadBanners();
                setState(() {});
                if (mounted) showSnackBar(context, 'Banner saved!');
              },
              child: const Text('Save', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dialogField(TextEditingController c, String label,
      {int maxLines = 1, TextInputType type = TextInputType.text}) {
    return TextFormField(
      controller: c,
      maxLines: maxLines,
      keyboardType: type,
      decoration: InputDecoration(
        labelText: label,
        border:
            OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration:
              const BoxDecoration(gradient: GlobalVariables.appBarGradient),
        ),
        title: Row(children: [
          Icon(Icons.admin_panel_settings,
              color: Colors.white, size: 22.sp),
          SizedBox(width: 8.w),
          Text('Admin CRM',
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18.sp)),
        ]),
        iconTheme: const IconThemeData(color: Colors.white),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          indicatorColor: GlobalVariables.secondaryColor,
          tabs: const [
            Tab(icon: Icon(Icons.dashboard), text: 'Dashboard'),
            Tab(icon: Icon(Icons.inventory_2), text: 'Products'),
            Tab(icon: Icon(Icons.image), text: 'Banners'),
            Tab(icon: Icon(Icons.receipt_long), text: 'Orders'),
            Tab(icon: Icon(Icons.feedback), text: 'Feedback'),
          ],
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildDashboard(),
                _buildProducts(),
                _buildBanners(),
                _buildOrders(),
                _buildFeedbacks(),
              ],
            ),
    );
  }

  Widget _buildDashboard() {
    return RefreshIndicator(
      onRefresh: _loadAll,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Overview',
                style: TextStyle(
                    fontSize: 18.sp, fontWeight: FontWeight.bold)),
            SizedBox(height: 14.h),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12.w,
              mainAxisSpacing: 12.h,
              childAspectRatio: 1.4,
              children: [
                _statCard('Total Orders',
                    '${_stats['totalOrders'] ?? 0}', Icons.receipt_long,
                    Colors.blue),
                _statCard('Products',
                    '${_stats['totalProducts'] ?? 0}', Icons.inventory_2,
                    Colors.green),
                _statCard('Users',
                    '${_stats['totalUsers'] ?? 0}', Icons.people,
                    Colors.purple),
                _statCard('Revenue',
                    '\$${(_stats['totalRevenue'] ?? 0).toStringAsFixed(0)}',
                    Icons.attach_money, Colors.orange),
              ],
            ),
            SizedBox(height: 20.h),
            Text('Recent Orders',
                style: TextStyle(
                    fontSize: 16.sp, fontWeight: FontWeight.bold)),
            SizedBox(height: 10.h),
            ..._orders.take(5).map((o) => _orderTile(o)),
          ],
        ),
      ),
    );
  }

  Widget _statCard(
      String label, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 6)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(icon, color: color, size: 22.sp),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value,
                  style: TextStyle(
                      fontSize: 22.sp, fontWeight: FontWeight.bold)),
              Text(label,
                  style: TextStyle(
                      color: Colors.grey[500], fontSize: 11.sp)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProducts() {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: GlobalVariables.secondaryColor,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Product',
            style: TextStyle(color: Colors.white)),
        onPressed: () => _showAddProductDialog(),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await _loadProducts();
          setState(() {});
        },
        child: _products.isEmpty
            ? const Center(child: Text('No products'))
            : ListView.builder(
                padding: EdgeInsets.fromLTRB(12.w, 12.h, 12.w, 80.h),
                itemCount: _products.length,
                itemBuilder: (ctx, i) {
                  final p = _products[i];
                  return Card(
                    margin: EdgeInsets.only(bottom: 10.h),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r)),
                    child: ListTile(
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8.r),
                        child: p.images.isNotEmpty
                            ? Image.network(p.images[0],
                                width: 50.w,
                                height: 50.w,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                    width: 50.w,
                                    height: 50.w,
                                    color: GlobalVariables
                                        .greyBackgroundCOlor))
                            : Container(
                                width: 50.w,
                                height: 50.w,
                                color: GlobalVariables.greyBackgroundCOlor),
                      ),
                      title: Text(p.name,
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13.sp)),
                      subtitle: Text(
                          '${p.category} · \$${p.price} · Qty: ${p.quantity}',
                          style: TextStyle(fontSize: 11.sp)),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit,
                                color: Colors.blue, size: 20.sp),
                            onPressed: () => _showAddProductDialog(p),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete,
                                color: Colors.red, size: 20.sp),
                            onPressed: () => _confirmDelete(
                                'Delete "${p.name}"?',
                                () => _deleteProduct(p.id)),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }

  Widget _buildBanners() {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: GlobalVariables.secondaryColor,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Banner',
            style: TextStyle(color: Colors.white)),
        onPressed: () => _showAddBannerDialog(),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await _loadBanners();
          setState(() {});
        },
        child: _banners.isEmpty
            ? const Center(child: Text('No banners'))
            : ListView.builder(
                padding: EdgeInsets.fromLTRB(12.w, 12.h, 12.w, 80.h),
                itemCount: _banners.length,
                itemBuilder: (ctx, i) {
                  final b = _banners[i];
                  return Card(
                    margin: EdgeInsets.only(bottom: 10.h),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r)),
                    child: Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.vertical(
                              top: Radius.circular(12.r)),
                          child: Image.network(
                            b.imageUrl,
                            height: 100.h,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                                height: 100.h,
                                color: GlobalVariables.greyBackgroundCOlor,
                                child: const Icon(
                                    Icons.image_not_supported)),
                          ),
                        ),
                        ListTile(
                          title: Text(b.title.isNotEmpty ? b.title : 'No title',
                              style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13.sp)),
                          subtitle: Text(
                              'Type: ${b.type} · ${b.isActive ? "Active" : "Inactive"}',
                              style: TextStyle(fontSize: 11.sp)),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit,
                                    color: Colors.blue, size: 20.sp),
                                onPressed: () => _showAddBannerDialog(b),
                              ),
                              IconButton(
                                icon: Icon(Icons.delete,
                                    color: Colors.red, size: 20.sp),
                                onPressed: () => _confirmDelete(
                                    'Delete this banner?',
                                    () => _deleteBanner(b.id)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }

  Widget _buildOrders() {
    return RefreshIndicator(
      onRefresh: () async {
        await _loadOrders();
        setState(() {});
      },
      child: _orders.isEmpty
          ? const Center(child: Text('No orders'))
          : ListView.builder(
              padding: EdgeInsets.all(12.w),
              itemCount: _orders.length,
              itemBuilder: (ctx, i) {
                final o = _orders[i];
                return Card(
                  margin: EdgeInsets.only(bottom: 10.h),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r)),
                  child: Padding(
                    padding: EdgeInsets.all(12.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Order #${o.id.substring(o.id.length - 6).toUpperCase()}',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13.sp),
                            ),
                            Text('\$${o.totalPrice.toStringAsFixed(2)}',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: GlobalVariables.secondaryColor,
                                    fontSize: 14.sp)),
                          ],
                        ),
                        SizedBox(height: 4.h),
                        Text(
                            '${o.userName} · ${o.userEmail}',
                            style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 11.sp)),
                        Text(
                            '${o.products.length} items · ${o.paymentMethod} · ${o.paymentStatus}',
                            style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 11.sp)),
                        SizedBox(height: 8.h),
                        Row(
                          children: [
                            Text('Status: ',
                                style: TextStyle(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w500)),
                            Expanded(
                              child: DropdownButton<int>(
                                value: o.status,
                                isDense: true,
                                underline: const SizedBox(),
                                items: [
                                  DropdownMenuItem(
                                      value: 0,
                                      child: Text('Order Placed',
                                          style:
                                              TextStyle(fontSize: 12.sp))),
                                  DropdownMenuItem(
                                      value: 1,
                                      child: Text('Processing',
                                          style:
                                              TextStyle(fontSize: 12.sp))),
                                  DropdownMenuItem(
                                      value: 2,
                                      child: Text('Shipped',
                                          style:
                                              TextStyle(fontSize: 12.sp))),
                                  DropdownMenuItem(
                                      value: 3,
                                      child: Text('Delivered',
                                          style:
                                              TextStyle(fontSize: 12.sp))),
                                ],
                                onChanged: (v) =>
                                    _updateOrderStatus(o.id, v!),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildFeedbacks() {
    return RefreshIndicator(
      onRefresh: () async {
        await _loadFeedbacks();
        setState(() {});
      },
      child: _feedbacks.isEmpty
          ? const Center(child: Text('No feedback yet'))
          : ListView.builder(
              padding: EdgeInsets.all(12.w),
              itemCount: _feedbacks.length,
              itemBuilder: (ctx, i) {
                final f = _feedbacks[i];
                return Card(
                  margin: EdgeInsets.only(bottom: 10.h),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r)),
                  child: Padding(
                    padding: EdgeInsets.all(14.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                          children: [
                            Text(f['userName'] ?? '',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13.sp)),
                            Row(
                              children: List.generate(
                                  5,
                                  (j) => Icon(
                                        j < (f['rating'] ?? 0)
                                            ? Icons.star
                                            : Icons.star_border,
                                        color: Colors.amber,
                                        size: 14.sp,
                                      )),
                            ),
                          ],
                        ),
                        SizedBox(height: 4.h),
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 8.w, vertical: 2.h),
                          decoration: BoxDecoration(
                            color: GlobalVariables.secondaryColor
                                .withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Text(f['category'] ?? 'General',
                              style: TextStyle(
                                  fontSize: 10.sp,
                                  color: GlobalVariables.secondaryColor)),
                        ),
                        SizedBox(height: 6.h),
                        Text(f['message'] ?? '',
                            style: TextStyle(
                                fontSize: 12.sp,
                                color: Colors.grey[700],
                                height: 1.4)),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _orderTile(Order o) {
    return Card(
      margin: EdgeInsets.only(bottom: 8.h),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.r)),
      child: ListTile(
        title: Text(
            'Order #${o.id.substring(o.id.length - 6).toUpperCase()}',
            style:
                TextStyle(fontWeight: FontWeight.w600, fontSize: 13.sp)),
        subtitle: Text('${o.userName} · ${o.products.length} items',
            style: TextStyle(fontSize: 11.sp)),
        trailing: Text('\$${o.totalPrice.toStringAsFixed(2)}',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: GlobalVariables.secondaryColor,
                fontSize: 13.sp)),
      ),
    );
  }

  void _confirmDelete(String msg, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text(msg),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
            style:
                ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(context);
              onConfirm();
            },
            child: const Text('Delete',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
