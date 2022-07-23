import 'dart:io';

import 'package:enough_giphy_flutter/enough_giphy_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

String globalPhotoUrl =
    'https://cdn-icons-png.flaticon.com/512/957/957284.png?w=826&t=st=1657954174~exp=1657954774~hmac=22d4d46e58bac5a72c89354a9c939cbba926d36d97aec3caa62039576977eb2f';

Future<File?> pickImageFromGallery(BuildContext context) async {
  File? image;
  try {
    final pickedImage =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      image = File(pickedImage.path);
    }
  } catch (e) {
    showTopSnackBar(context, CustomSnackBar.error(message: e.toString()));
  }
  return image;
}

Future<File?> pickVideoFromGallery(BuildContext context) async {
  File? video;
  try {
    final pickedVideo =
        await ImagePicker().pickVideo(source: ImageSource.gallery);
    if (pickedVideo != null) {
      video = File(pickedVideo.path);
    }
  } catch (e) {
    showTopSnackBar(context, CustomSnackBar.error(message: e.toString()));
  }
  return video;
}

Future<GiphyGif?> pickGIF(BuildContext context) async {
  GiphyGif? gif;
  try {
    gif = await Giphy.getGif(
      
      context: context,
      apiKey: 'vmXrtN1RwQYgL2ezUGAyl1znU3mnr2kf',
    );
  } catch (e) {
    showTopSnackBar(
      context,
      CustomSnackBar.error(message: e.toString()),
    );
  }
  return gif; 
}

class Loader extends StatelessWidget {
  const Loader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Lottie.asset('assets/97952-loading-animation-blue.json'),
    );
  }
}
