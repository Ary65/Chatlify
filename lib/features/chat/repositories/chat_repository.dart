import 'dart:io';
import 'package:chatlify/features/common/enums/message_enum.dart';
import 'package:chatlify/features/common/repositories/firebase_storage.dart';
import 'package:chatlify/models/chat_contact.dart';
import 'package:chatlify/models/message.dart';
import 'package:chatlify/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import 'package:uuid/uuid.dart';

final chatRepositoryProvider = Provider(
  (ref) => ChatRepository(
    firestore: FirebaseFirestore.instance,
    auth: FirebaseAuth.instance,
  ),
);

class ChatRepository {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;
  ChatRepository({
    required this.firestore,
    required this.auth,
  });

  Stream<List<ChatContact>> getChatContacts() {
    return firestore
        .collection('users')
        .doc(auth.currentUser!.uid)
        .collection('chats')
        .snapshots()
        .asyncMap(
      (event) async {
        List<ChatContact> contacts = [];
        for (var document in event.docs) {
          var chatContact = ChatContact.fromMap(document.data());
          var userData = await firestore
              .collection('users')
              .doc(chatContact.contactId)
              .get();
          var user = UserModel.fromMap(userData.data()!);

          contacts.add(
            ChatContact(
              name: user.name,
              profilePic: user.profilePic,
              contactId: chatContact.contactId,
              timeSent: chatContact.timeSent,
              lastMessage: chatContact.lastMessage,
            ),
          );
        }
        return contacts;
      },
    );
  }

  Stream<List<Message>> getChatStream(String recieverUserId) {
    return firestore
        .collection('users')
        .doc(auth.currentUser!.uid)
        .collection('chats')
        .doc(recieverUserId)
        .collection('messages')
        .orderBy('timeSent')
        .snapshots()
        .map(
      (event) {
        List<Message> messages = [];
        for (var documenr in event.docs) {
          messages.add(Message.fromMap(documenr.data()));
        }
        return messages;
      },
    );
  }

  void _saveDataToContactsSubCollection(
    UserModel senderUserData,
    UserModel receiverUserData,
    String text,
    DateTime timeSent,
    String recieverUserId,
  ) async {
    // to show reciever message
    //* users => reciever user id => chats => current user id => set data
    var recieverChatContact = ChatContact(
      name: senderUserData.name,
      profilePic: senderUserData.profilePic,
      contactId: senderUserData.uid,
      timeSent: timeSent,
      lastMessage: text,
    );
    await firestore
        .collection('users')
        .doc(recieverUserId)
        .collection('chats')
        .doc(auth.currentUser!.uid)
        .set(recieverChatContact.toMap());
    // to show sender message
    //* users => current user id => chats => reciever user id  => set data
    var senderChatContact = ChatContact(
      name: receiverUserData.name,
      profilePic: receiverUserData.profilePic,
      contactId: receiverUserData.uid,
      timeSent: timeSent,
      lastMessage: text,
    );
    await firestore
        .collection('users')
        .doc(auth.currentUser!.uid)
        .collection('chats')
        .doc(recieverUserId)
        .set(senderChatContact.toMap());
  }

  void _saveMessageToMessageSubcollection({
    required String revieverUserId,
    required String text,
    required DateTime timeSent,
    required String messageId,
    required String username,
    required recieverUsername,
    required MessageEnum messageType,
  }) async {
    final message = Message(
      senderId: auth.currentUser!.uid,
      receiverId: revieverUserId,
      text: text,
      type: messageType,
      timeSent: timeSent,
      messageId: messageId,
      isSeen: false,
    );
    //* users => sender id => reciever id => messages = message id => set data
    await firestore
        .collection('users')
        .doc(auth.currentUser!.uid)
        .collection('chats')
        .doc(revieverUserId)
        .collection('messages')
        .doc(messageId)
        .set(message.toMap());
    //* users => reciever id => sender id => messages = message id => set data
    await firestore
        .collection('users')
        .doc(revieverUserId)
        .collection('chats')
        .doc(auth.currentUser!.uid)
        .collection('messages')
        .doc(messageId)
        .set(message.toMap());
  }

  void sendTextMessage({
    required BuildContext context,
    required String text,
    required String receiverUserId,
    required UserModel senderUser,
  }) async {
    //* users => sender id => reciever id => messages => message id => store message

    try {
      var timeSent = DateTime.now();
      UserModel recieverUserData;

      var userDataMap =
          await firestore.collection('users').doc(receiverUserId).get();

      recieverUserData = UserModel.fromMap(userDataMap.data()!);
      var messageId = const Uuid().v1();
      _saveDataToContactsSubCollection(
        senderUser,
        recieverUserData,
        text,
        timeSent,
        receiverUserId,
      );
      _saveMessageToMessageSubcollection(
        revieverUserId: receiverUserId,
        text: text,
        timeSent: timeSent,
        messageId: messageId,
        username: senderUser.name,
        recieverUsername: recieverUserData.name,
        messageType: MessageEnum.text,
      );
    } catch (e) {
      showTopSnackBar(
        context,
        CustomSnackBar.error(message: e.toString()),
      );
    }
  }

  void sendFileMessage({
    required BuildContext context,
    required File file,
    required String receiverUserId,
    required UserModel senderUserData,
    required ProviderRef ref,
    required MessageEnum messageEnum,
  }) async {
    try {
      var timeSent = DateTime.now();
      var messageId = const Uuid().v1();

      String imageUrl = await ref
          .read(commonFirebaseStorageRepositoryProvider)
          .storeFileToFirebase(
            'chat/${messageEnum.type}/${senderUserData.uid}/$receiverUserId/$messageId',
            file,
          );

      UserModel receiverUserData;
      var userDataMap =
          await firestore.collection('users').doc(receiverUserId).get();
      receiverUserData = UserModel.fromMap(userDataMap.data()!);

      String contactMsg;

      switch (messageEnum) {
        case MessageEnum.image:
          contactMsg = '📷 Photo';
          break;
        case MessageEnum.video:
          contactMsg = '📸 Video';
          break;
        case MessageEnum.audio:
          contactMsg = '🎵 Audio';
          break;
        case MessageEnum.gif:
          contactMsg = 'GIF';
          break;
        default:
          contactMsg = 'GIF';
      }

      _saveDataToContactsSubCollection(
        senderUserData,
        receiverUserData,
        contactMsg,
        timeSent,
        receiverUserId,
      );

      _saveMessageToMessageSubcollection(
        revieverUserId: receiverUserId,
        text: imageUrl,
        timeSent: timeSent,
        messageId: messageId,
        username: senderUserData.name,
        recieverUsername: receiverUserData.name,
        messageType: messageEnum,
      );
    } catch (e) {
      showTopSnackBar(
        context,
        CustomSnackBar.error(message: e.toString()),
      );
    }
  }

  void sendGIFMessage({
    required BuildContext context,
    required String gifUrl,
    required String receiverUserId,
    required UserModel senderUser,
  }) async {
    //* users => sender id => reciever id => messages => message id => store message

    try {
      var timeSent = DateTime.now();
      UserModel recieverUserData;

      var userDataMap =
          await firestore.collection('users').doc(receiverUserId).get();

      recieverUserData = UserModel.fromMap(userDataMap.data()!);
      var messageId = const Uuid().v1();
      _saveDataToContactsSubCollection(
        senderUser,
        recieverUserData,
        'GIF',
        timeSent,
        receiverUserId,
      );
      _saveMessageToMessageSubcollection(
        revieverUserId: receiverUserId,
        text: gifUrl,
        timeSent: timeSent,
        messageId: messageId,
        username: senderUser.name,
        recieverUsername: recieverUserData.name,
        messageType: MessageEnum.gif,
      );
    } catch (e) {
      showTopSnackBar(
        context,
        CustomSnackBar.error(message: e.toString()),
      );
    }
  }
}
