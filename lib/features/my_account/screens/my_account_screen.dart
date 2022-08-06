import 'package:chatlify/features/auth/controller/auth_controller.dart';
import 'package:chatlify/features/landing/screens/landing_screen.dart';
import 'package:chatlify/utils/colors.dart';
import 'package:chatlify/utils/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MyAccountScreen extends StatelessWidget {
  static const routeName = 'my-account';
  const MyAccountScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              const SizedBox(height: 50),
              CircleAvatar(
                backgroundImage: NetworkImage(globalPhotoUrl),
                radius: 64,
              ),
              const SizedBox(height: 50),
              const Divider(
                color: dividerColor,
                // indent: 85,
                height: 1,
              ),
              InkWell(
                onTap: () async {
                  await FirebaseAuth.instance.signOut();
                  // ignore: use_build_context_synchronously
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LandingScreen(),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    alignment: Alignment.center,
                    child: const Align(
                        alignment: Alignment.topLeft, child: Text('Log Out')),
                  ),
                ),
              ),
              const Divider(
                color: dividerColor,
                // indent: 85,
                height: 1,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  alignment: Alignment.center,
                  child: const Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      'Edit Profile',
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
