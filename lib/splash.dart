import 'package:app/core/providers/user_provider.dart';
import 'package:app/core/routing/vibranium_route.dart';
import 'package:app/screens/auth/login_screen.dart';
import 'package:app/screens/home/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:webview_flutter/webview_flutter.dart';

String heroTag = "logo";

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late VideoPlayerController _controller;
  @override
  void initState() {
    _controller = VideoPlayerController.asset(
      'assets/branding/vibranium_splash.mp4',
    );
    _controller.initialize().then((_) {
      setState(() {
        _controller.play();
      });
    });
    final userProvider = context.read<UserProvider>();
    userProvider.controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..enableZoom(false);
    //TODO : change to not debug
    userProvider.checkIfloggedIn(true);

    Future.delayed(const Duration(seconds: 4), () {
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
      body: _controller.value.isInitialized
          ? Center(
              child: Hero(
                tag: heroTag,
                child: SizedBox(
                  width: 400,
                  height: 400,
                  child: VideoPlayer(_controller),
                ),
              ),
            )
          : const CircularProgressIndicator(),
    );
  }
}
