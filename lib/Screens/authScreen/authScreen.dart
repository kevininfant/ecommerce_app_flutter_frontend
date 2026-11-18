import 'package:ecomerce_app/Componets/widgets/custom_button.dart';
import 'package:ecomerce_app/Componets/widgets/custom_textFeld.dart';
import 'package:ecomerce_app/Providers/auth.dart';
import 'package:ecomerce_app/constants/globel_variable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

enum Auth { signup, signin }

class AuthScreen extends StatefulWidget {
  static const String routeName = '/auth-screen';
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  Auth _auth = Auth.signin;
  bool _isLoading = false;
  final _signUpFormKey = GlobalKey<FormState>();
  final _signInFormKey = GlobalKey<FormState>();
  final _authProvider = AuthProvider();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _nameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _signUp() async {
    if (!_signUpFormKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    await Future.delayed(Duration.zero);
    _authProvider.signUpUser(
      context: context,
      email: _emailController.text.trim(),
      name: _nameController.text.trim(),
      password: _passwordController.text.trim(),
    );
    setState(() => _isLoading = false);
  }

  void _signIn() async {
    if (!_signInFormKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    await Future.delayed(Duration.zero);
    _authProvider.signInUser(
      context: context,
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    );
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GlobalVariables.backgroundColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header with logo
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(gradient: GlobalVariables.appBarGradient),
              padding: EdgeInsets.symmetric(vertical: 40.h, horizontal: 20.w),
              child: Column(
                children: [
                  SizedBox(height: 20.h),
                  Container(
                    width: 80.w,
                    height: 80.w,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    child: Icon(Icons.shopping_bag_rounded,
                        size: 48.sp, color: GlobalVariables.secondaryColor),
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    'ShopEasy',
                    style: TextStyle(
                      fontSize: 28.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.2,
                    ),
                  ),
                  Text(
                    'Your one-stop shop',
                    style: TextStyle(fontSize: 13.sp, color: Colors.white70),
                  ),
                ],
              ),
            ),

            Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 10.h),
                  Text('Welcome!',
                      style: TextStyle(
                          fontSize: 22.sp, fontWeight: FontWeight.bold)),
                  SizedBox(height: 4.h),
                  Text('Sign in or create an account to continue',
                      style: TextStyle(
                          fontSize: 13.sp, color: Colors.grey[600])),
                  SizedBox(height: 20.h),

                  // Sign Up tile
                  _buildAuthTile(
                    title: 'Create Account',
                    value: Auth.signup,
                    form: Form(
                      key: _signUpFormKey,
                      child: Column(children: [
                        CustomTextField(
                            controller: _nameController, hintText: 'Full Name'),
                        SizedBox(height: 10.h),
                        CustomTextField(
                            controller: _emailController,
                            hintText: 'Email Address'),
                        SizedBox(height: 10.h),
                        CustomTextField(
                            controller: _passwordController,
                            hintText: 'Password',
                            isPassword: true),
                        SizedBox(height: 14.h),
                        _isLoading
                            ? const CircularProgressIndicator()
                            : CustomButton(text: 'Sign Up', onTap: _signUp),
                      ]),
                    ),
                  ),

                  SizedBox(height: 10.h),

                  // Sign In tile
                  _buildAuthTile(
                    title: 'Sign In',
                    value: Auth.signin,
                    form: Form(
                      key: _signInFormKey,
                      child: Column(children: [
                        CustomTextField(
                            controller: _emailController,
                            hintText: 'Email Address'),
                        SizedBox(height: 10.h),
                        CustomTextField(
                            controller: _passwordController,
                            hintText: 'Password',
                            isPassword: true),
                        SizedBox(height: 14.h),
                        _isLoading
                            ? const CircularProgressIndicator()
                            : CustomButton(text: 'Sign In', onTap: _signIn),
                      ]),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAuthTile(
      {required String title,
      required Auth value,
      required Widget form}) {
    final isSelected = _auth == value;
    return Container(
      decoration: BoxDecoration(
        color: isSelected ? Colors.white : GlobalVariables.greyBackgroundCOlor,
        borderRadius: BorderRadius.circular(12.r),
        border: isSelected
            ? Border.all(color: GlobalVariables.secondaryColor, width: 1.5)
            : null,
        boxShadow: isSelected
            ? [BoxShadow(color: Colors.black12, blurRadius: 6)]
            : null,
      ),
      child: Column(
        children: [
          ListTile(
            title: Text(title,
                style: TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 15.sp)),
            leading: Radio<Auth>(
              activeColor: GlobalVariables.secondaryColor,
              value: value,
              groupValue: _auth,
              onChanged: (v) => setState(() => _auth = v!),
            ),
          ),
          if (isSelected)
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
              child: form,
            ),
        ],
      ),
    );
  }
}
