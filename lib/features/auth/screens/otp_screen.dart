import 'package:chatlify/features/auth/controller/auth_controller.dart';
import 'package:chatlify/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OTPScreen extends ConsumerWidget {
  static const routeName = '/otp';
  final String verificationId;
  const OTPScreen({Key? key, required this.verificationId}) : super(key: key);

  void verifyOTP(WidgetRef ref, BuildContext context, String userOTP) {
    ref
        .read(authControllerProvider)
        .verifyOTP(context, verificationId, userOTP);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final w = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Enter your OTP'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: backgroundColor,
      ),
      body: Center(
        child: Column(
          children: [
            const SizedBox(height: 20),
            const Text(
              'We have sent a SMS with a code',
            ),
            SizedBox(
              width: w * 0.6,
              child: TextField(
                textAlign: TextAlign.center,
                decoration: const InputDecoration(
                    hintText: '- - - - - -',
                    hintStyle: TextStyle(fontSize: 30)),
                keyboardType: TextInputType.number,
                onChanged: (val) {
                  if (val.length == 6) {
                    verifyOTP(ref, context, val.trim());
                  }
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
