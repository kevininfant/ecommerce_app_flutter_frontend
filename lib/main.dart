import 'package:ecomerce_app/Providers/auth.dart';
import 'package:ecomerce_app/Providers/user_provider.dart';
import 'package:ecomerce_app/Screens/adminScreen/admin_screen.dart';
import 'package:ecomerce_app/Screens/authScreen/authScreen.dart';
import 'package:ecomerce_app/Screens/homeScreen/home_screen.dart';
import 'package:ecomerce_app/router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _authProvider = AuthProvider();
  bool _isLoading = true;
  Widget _home = const AuthScreen();

  @override
  void initState() {
    super.initState();
    _checkLogin();
  }

  Future<void> _checkLogin() async {
    await _authProvider.getUserData(context);
    if (mounted) {
      final user = Provider.of<UserProvider>(context, listen: false).user;
      setState(() {
        if (user.token.isNotEmpty) {
          _home = user.type == 'admin'
              ? const AdminScreen()
              : const HomeScreen();
        } else {
          _home = const AuthScreen();
        }
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            primarySwatch: Colors.cyan,
            scaffoldBackgroundColor: const Color(0xFFF5F5F5),
            textTheme:
                Typography.englishLike2018.apply(fontSizeFactor: 1.sp),
          ),
          onGenerateRoute: genarateRoute,
          initialRoute: AuthScreen.routeName,
          home: _isLoading
              ? const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                )
              : _home,
        );
      },
    );
  }
}
