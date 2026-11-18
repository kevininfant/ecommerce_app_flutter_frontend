import 'dart:convert';
import 'package:ecomerce_app/Providers/user_provider.dart';
import 'package:ecomerce_app/constants/globel_variable.dart';
import 'package:ecomerce_app/constants/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class FeedbackScreen extends StatefulWidget {
  static const String routeName = '/feedback';
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final _formKey = GlobalKey<FormState>();
  final _messageController = TextEditingController();
  double _rating = 0;
  String _category = 'General';
  bool _submitting = false;

  final _categories = [
    'General', 'Product Quality', 'Delivery', 'Customer Service', 'App Experience'
  ];

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_rating == 0) {
      showSnackBar(context, 'Please select a rating');
      return;
    }
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);
    final token =
        Provider.of<UserProvider>(context, listen: false).user.token;
    try {
      final res = await http.post(
        Uri.parse('$uri/feedback'),
        headers: {
          'Content-Type': 'application/json',
          'x-auth-token': token,
        },
        body: jsonEncode({
          'message': _messageController.text.trim(),
          'rating': _rating.toInt(),
          'category': _category,
        }),
      );
      if (res.statusCode == 200 && mounted) {
        showSnackBar(context, 'Thank you for your feedback! 🎉');
        _messageController.clear();
        setState(() {
          _rating = 0;
          _category = 'General';
        });
      }
    } catch (e) {
      showSnackBar(context, e.toString());
    }
    setState(() => _submitting = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration:
              const BoxDecoration(gradient: GlobalVariables.appBarGradient),
        ),
        title: const Text('Feedback',
            style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      GlobalVariables.secondaryColor.withOpacity(0.1),
                      GlobalVariables.secondaryColor.withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(
                      color: GlobalVariables.secondaryColor.withOpacity(0.2)),
                ),
                child: Column(
                  children: [
                    Icon(Icons.feedback_outlined,
                        size: 48.sp,
                        color: GlobalVariables.secondaryColor),
                    SizedBox(height: 10.h),
                    Text('Share Your Experience',
                        style: TextStyle(
                            fontSize: 18.sp, fontWeight: FontWeight.bold)),
                    SizedBox(height: 6.h),
                    Text(
                      'Your feedback helps us improve our service',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.grey[600], fontSize: 13.sp),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20.h),

              // Overall rating
              Text('Overall Rating',
                  style: TextStyle(
                      fontSize: 15.sp, fontWeight: FontWeight.bold)),
              SizedBox(height: 10.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (i) {
                  return GestureDetector(
                    onTap: () => setState(() => _rating = i + 1.0),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 6.w),
                      child: Icon(
                        i < _rating ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                        size: 40.sp,
                      ),
                    ),
                  );
                }),
              ),
              if (_rating > 0)
                Center(
                  child: Padding(
                    padding: EdgeInsets.only(top: 6.h),
                    child: Text(
                      ['', 'Poor', 'Fair', 'Good', 'Very Good', 'Excellent']
                          [_rating.toInt()],
                      style: TextStyle(
                          color: GlobalVariables.secondaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 14.sp),
                    ),
                  ),
                ),
              SizedBox(height: 20.h),

              // Category
              Text('Category',
                  style: TextStyle(
                      fontSize: 15.sp, fontWeight: FontWeight.bold)),
              SizedBox(height: 10.h),
              Wrap(
                spacing: 8.w,
                runSpacing: 8.h,
                children: _categories.map((cat) {
                  final selected = _category == cat;
                  return GestureDetector(
                    onTap: () => setState(() => _category = cat),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 14.w, vertical: 8.h),
                      decoration: BoxDecoration(
                        color: selected
                            ? GlobalVariables.secondaryColor
                            : Colors.white,
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(
                          color: selected
                              ? GlobalVariables.secondaryColor
                              : Colors.grey[300]!,
                        ),
                        boxShadow: selected
                            ? [
                                BoxShadow(
                                    color: GlobalVariables.secondaryColor
                                        .withOpacity(0.3),
                                    blurRadius: 6)
                              ]
                            : null,
                      ),
                      child: Text(cat,
                          style: TextStyle(
                              color: selected ? Colors.white : Colors.black87,
                              fontSize: 12.sp,
                              fontWeight: selected
                                  ? FontWeight.bold
                                  : FontWeight.normal)),
                    ),
                  );
                }).toList(),
              ),
              SizedBox(height: 20.h),

              // Message
              Text('Your Message',
                  style: TextStyle(
                      fontSize: 15.sp, fontWeight: FontWeight.bold)),
              SizedBox(height: 10.h),
              TextFormField(
                controller: _messageController,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText:
                      'Tell us about your experience, suggestions, or issues...',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r)),
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: (v) => v == null || v.trim().length < 10
                    ? 'Please write at least 10 characters'
                    : null,
              ),
              SizedBox(height: 24.h),

              // Submit button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.send, color: Colors.white),
                  label: Text(
                    _submitting ? 'Submitting...' : 'Submit Feedback',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 15.sp,
                        fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: GlobalVariables.secondaryColor,
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r)),
                  ),
                  onPressed: _submitting ? null : _submit,
                ),
              ),
              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }
}
