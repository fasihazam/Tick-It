import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:firstapp/database/sqlite.dart';
import 'package:firstapp/screens/MainMenu.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:page_transition/page_transition.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'screens/LoginScreen.dart';

Future<void> main() async {
  ErrorWidget.builder = (FlutterErrorDetails details) => Container();
  WidgetsFlutterBinding.ensureInitialized();
  Stripe.publishableKey = "pk_test_51N4fYDGg4kRxFZtJ0E6LeLAKnyME3altJTUrkTvxNFMHIwi1SNLJ5MPJoAF7DAJwzQnB86BfMRaMgKdPWkcWu5Dg002w6Ngd67";
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
      builder: EasyLoading.init(),
    );
  }
}
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  List<Map<String, dynamic>> userData = [];

  @override
  void initState() {
    super.initState();
    getUserData();
  }

  void getUserData() async {
    var users = await DatabaseHelper.instance.users();
    setState(() {
      userData = users;
    });
  }
  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen(
      splash: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Align(
          alignment: Alignment.center,
          child: Image.asset(
            "assets/images/logo.png",
            height: 300,
            width: 300,
          ),
        ),
      ]),
      backgroundColor: Colors.white,
      splashIconSize: 1000,
      duration: 1000,
      pageTransitionType: PageTransitionType.topToBottom,
      splashTransition: SplashTransition.scaleTransition,

      nextScreen: userData.length == 0
      ? LoginScreen()
      : MainMenu(loginCheck: true)
    );
  }
}
