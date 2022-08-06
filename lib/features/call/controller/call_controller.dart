import 'package:chatlify/features/auth/controller/auth_controller.dart';
import 'package:chatlify/features/call/repository/call_repository.dart';
import 'package:chatlify/models/call.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

final callControllerProvider = Provider(
  (ref) {
    final callRepository = ref.read(callRepositoryProvider);
    return CallController(
      callRepository: callRepository,
      auth: FirebaseAuth.instance,
      ref: ref,
    );
  },
);

class CallController {
  final CallRepository callRepository;
  final ProviderRef ref;
  final FirebaseAuth auth;

  CallController({
    required this.callRepository,
    required this.ref,
    required this.auth,
  });

  Stream<DocumentSnapshot> get callStream => callRepository.callStream;

  void makeCall(BuildContext context, String receiverName, String receiverUid,
      String receiverProfilePic, bool isGroupChat) {
    ref.read(userDataAuthProvider).whenData(
      (value) {
        String callId = const Uuid().v1();
        Call senderCallData = Call(
          callerId: auth.currentUser!.uid,
          callerName: value!.name,
          callerPic: value.profilePic,
          receiverId: receiverUid,
          receiverName: receiverName,
          receiverPic: receiverProfilePic,
          callId: callId,
          hasDialled: true,
        );
        Call receiverCallData = Call(
          callerId: auth.currentUser!.uid,
          callerName: value.name,
          callerPic: value.profilePic,
          receiverId: receiverUid,
          receiverName: receiverName,
          receiverPic: receiverProfilePic,
          callId: callId,
          hasDialled: false,
        );
        if (isGroupChat) {
          callRepository.makeGroupCall(
              senderCallData, context, receiverCallData);
        } else {
          callRepository.makeCall(senderCallData, context, receiverCallData);
        }
      },
    );
  }

  void endCall(
    String callerId,
    String receiverId,
    BuildContext context,
  ) {
    callRepository.endCall(callerId, receiverId, context);
  }
}