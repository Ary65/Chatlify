import 'package:chatlify/features/auth/screens/login_screen.dart';
import 'package:chatlify/features/common/widgets/custom_button.dart';
import 'package:chatlify/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({Key? key}) : super(key: key);

  void navigateToLogin(BuildContext context) {
    Navigator.pushNamed(context, LoginScreen.routeName);
  }

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;
    return Scaffold(
      body: SafeArea(
          child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          // cross worls like row
          // main works like column
          children: [
            const SizedBox(height: 50),
            const Text(
              'Welcome to Chatlify',
              style: TextStyle(
                fontSize: 33,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: h / 9),
            SizedBox(
                height: 340,
                width: 340,
                child: Lottie.asset('assets/94789-chat-animation.json')),
            // Image.asset(
            //   'assets/bg.png',
            //   height: 340,
            //   width: 340,
            //   color: tabColor,
            // ),
            SizedBox(height: h / 9),
            const Padding(
              padding: EdgeInsets.all(15.0),
              child: Text(
                'Read our Privacy Policy. Tap "Agree and continue" to accept the Terms of Service.',
                style: TextStyle(color: greyColor),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: w * 0.9,
              child: CustomButton(
                text: 'AGREE AND CONTINUE',
                onPressed: () => navigateToLogin(context),
              ),
            ),
          ],
        ),
      )),
    );
  }
}
