import 'package:flutter/material.dart';
import 'package:measuremate/Screens/SelectionScreen/SelectionPage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Welcome/welcome_screen.dart';
import 'package:lottie/lottie.dart';
import 'package:measuremate/constants.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateBasedOnLoginStatus();
  }

  Future<void> _navigateBasedOnLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    String userName = prefs.getString('userName') ?? '';
    String userEmail = prefs.getString('userEmail') ?? '';

    await Future.delayed(const Duration(seconds: 3));

    if (isLoggedIn) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => SelectionPage(
            userName: userName,
            userEmail: userEmail,
          ),
        ),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const WelcomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimaryLightColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated Lottie Logo
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: kPrimaryColor,
                    blurRadius: 15,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Lottie.asset(
                'assets/animation/cloth.json',
                width: 200,
                height: 200,
              ),
            ),
            const SizedBox(height: 30),

            Text(
              'Welcome To',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
                color: kPrimaryColor,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'MeasureMate',
              style: TextStyle(
                fontSize: 32,  // Larger size
                fontWeight: FontWeight.w900,
                color: kPrimaryColor,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Your partner in measuring clothes precisely!',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: kPrimaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
