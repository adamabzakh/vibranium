import 'package:app/core/providers/user_provider.dart';
import 'package:app/core/routing/vibranium_route.dart';
import 'package:app/screens/auth/login_screen.dart';
import 'package:app/screens/home/home_screen.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

String heroTag = "logo";

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    final userProvider = context.read<UserProvider>();
    userProvider.checkIfloggedIn(true);
    Future.delayed(const Duration(milliseconds: 1000), () {
      Navigator.of(context).pushReplacement(
        vibraniumPageRoute(
          (userProvider.user != null) ? HomeScreen() : const LoginScreen(),
        ),
      );
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Hero(
          tag: heroTag,
          child: SizedBox(
            width: 200,
            height: 200,
            child: Image.asset(
              'assets/branding/vibranium_logo.png',
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}
