import 'dart:io';

import 'package:chatlify/features/auth/screens/login_screen.dart';
import 'package:chatlify/features/auth/screens/otp_screen.dart';
import 'package:chatlify/features/auth/screens/user_information_screen.dart';
import 'package:chatlify/features/common/widgets/error.dart';
import 'package:chatlify/features/group/screens/create_group_screen.dart';
import 'package:chatlify/features/my_account/screens/my_account_screen.dart';
import 'package:chatlify/features/select_contacts/screens/select_contact_screen.dart';
import 'package:chatlify/features/chat/screens/mobile_chat_screen.dart';
import 'package:chatlify/features/status/screens/confirm_status_screen.dart';
import 'package:chatlify/features/status/screens/status_screen.dart';
import 'package:chatlify/models/status.dart';
import 'package:flutter/material.dart';

Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case LoginScreen.routeName:
      return MaterialPageRoute(
        builder: (context) => const LoginScreen(),
      );
    case OTPScreen.routeName:
      final verificationId = settings.arguments as String;
      return MaterialPageRoute(
        builder: (context) => OTPScreen(
          verificationId: verificationId,
        ),
      );
    case UserInformationScreen.routeName:
      return MaterialPageRoute(
        builder: (context) => const UserInformationScreen(),
      );
    case SelectContactScreen.routeName:
      return MaterialPageRoute(
        builder: (context) => const SelectContactScreen(),
      );
    case MobileChatScreen.routeName:
      final arguments = settings.arguments as Map<String, dynamic>;
      final name = arguments['name'];
      final uid = arguments['uid'];
      final isGroupChat = arguments['isGroupChat'];
      final profilePic = arguments['profilePic'];
      return MaterialPageRoute(
        builder: (context) => MobileChatScreen(
          name: name,
          uid: uid,
          isGroupChat: isGroupChat,
          profilePic: profilePic,
        ),
      );
    case ConfirmStatusScreen.routeName:
      final flle = settings.arguments as File;
      return MaterialPageRoute(
        builder: (context) => ConfirmStatusScreen(
          file: flle,
        ),
      );
    case StatusScreen.routeName:
      final status = settings.arguments as Status;
      return MaterialPageRoute(
        builder: (context) => StatusScreen(
          status: status,
        ),
      );
    case CreateGroupScreen.routeName:
      return MaterialPageRoute(
        builder: (context) => const CreateGroupScreen(),
      );
          case MyAccountScreen.routeName:
      return MaterialPageRoute(
        builder: (context) => const MyAccountScreen(),
      );

    default:
      return MaterialPageRoute(
        builder: (context) => const Scaffold(
          body: ErrorScreen(error: 'This page doesn\'t exist'),
        ),
      );
  }
}
