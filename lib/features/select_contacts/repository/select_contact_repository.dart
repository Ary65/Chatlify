// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:chatlify/models/user_model.dart';
import 'package:chatlify/features/chat/screens/mobile_chat_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

//*
final selectContactsRepositoryProvider = Provider(
  (ref) => SelectContactRepository(
    firestore: FirebaseFirestore.instance,
  ),
);

//*
class SelectContactRepository {
  final FirebaseFirestore firestore;
  SelectContactRepository({
    required this.firestore,
  });

  //*
  Future<List<Contact>> getContacts() async {
    List<Contact> contacts = [];
    try {
      if (await FlutterContacts.requestPermission()) {
        contacts = await FlutterContacts.getContacts(
          withProperties: true,
        );
      }
    } catch (e) {
      debugPrint(e.toString());
    }
    return contacts;
  }

  //*
  void selectContact(Contact selectedContact, BuildContext context) async {
    try {
      var userCollection = await firestore.collection('users').get();
      bool isFound = false;
      for (var document in userCollection.docs) {
        var userData = UserModel.fromMap(document.data());
        String selectedPhoneNum =
            selectedContact.phones[0].number.replaceAll(' ', '');
        if (selectedPhoneNum == userData.phoneNumber) {
          isFound = true;
          // ignore: use_build_context_synchronously
          Navigator.pushNamed(
            context,
            MobileChatScreen.routeName,
            arguments: {
              'name': userData.name,
              'uid': userData.uid,
            },
          );
        }
      }
      if (!isFound) {
        // ignore: use_build_context_synchronously
        showTopSnackBar(
            context,
            const CustomSnackBar.info(
                message: 'This number does not exixt on this app'));
      }
    } catch (e) {
      showTopSnackBar(
        context,
        CustomSnackBar.error(message: e.toString()),
      );
    }
  }
}
