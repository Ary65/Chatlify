import 'dart:io';

import 'package:chatlify/features/auth/controller/auth_controller.dart';
import 'package:chatlify/utils/colors.dart';
import 'package:chatlify/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

class UserInformationScreen extends ConsumerStatefulWidget {
  static const routeName = '/user_information';
  const UserInformationScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<UserInformationScreen> createState() =>
      _UserInformationScreenState();
}

class _UserInformationScreenState extends ConsumerState<UserInformationScreen> {
  final nameController = TextEditingController();
  File? image;
  bool _isLoading = false;
  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  void selectImage() async {
    image = await pickImageFromGallery(context);
    setState(() {});
  }

  void storeUserData() async {
    setState(() {
      _isLoading = false;
    });
    String name = nameController.text.trim();

    if (name.isNotEmpty) {
      ref
          .read(authControllerProvider)
          .saveUserDataToFirebase(context, name, image);
      setState(() {
        _isLoading = true;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
      showTopSnackBar(
        context,
        const CustomSnackBar.error(
          backgroundColor: tabColor,
          message: 'Please provide your name',
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    return Scaffold(
      body: _isLoading
          ? const Loader()
          : SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Center(
                    child: Column(
                      children: [
                        Stack(
                          children: [
                            image == null
                                ? CircleAvatar(
                                    radius: 64,
                                    backgroundImage: NetworkImage(
                                      globalPhotoUrl,
                                    ),
                                    // child: Lottie.asset(
                                    //   'assets/lf30_editor_y8pr2v8b.json',
                                    //   height: double.infinity,
                                    //   width: double.infinity,
                                    // ),
                                  )
                                : CircleAvatar(
                                    radius: 64,
                                    backgroundImage: FileImage(image!),
                                  ),
                            Positioned(
                              bottom: -10,
                              left: 80,
                              child: IconButton(
                                onPressed: selectImage,
                                icon: const Icon(Icons.add_a_photo),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Container(
                              width: w * 0.85,
                              padding: const EdgeInsets.all(20),
                              child: TextField(
                                controller: nameController,
                                decoration: const InputDecoration(
                                  hintText: 'Enter your name',
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 30),
                              child: IconButton(
                                onPressed: storeUserData,
                                icon: const Icon(Icons.done),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
