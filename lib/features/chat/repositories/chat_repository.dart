import 'dart:io';
import 'package:chatlify/features/common/enums/message_enum.dart';
import 'package:chatlify/features/common/providers/message_replay_provider.dart';
import 'package:chatlify/features/common/repositories/firebase_storage.dart';
import 'package:chatlify/models/chat_contact.dart';
import 'package:chatlify/models/group.dart';
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

  Stream<List<Group>> getChatGroups() {
    return firestore.collection('groups').snapshots().map(
      (event) {
        List<Group> groups = [];
        for (var document in event.docs) {
          var group = Group.fromMap(document.data());
          if (group.membersUid.contains(auth.currentUser!.uid)) {
            groups.add(group);
          }
        }
        return groups;
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
        for (var document in event.docs) {
          messages.add(Message.fromMap(document.data()));
        }
        return messages;
      },
    );
  }

  Stream<List<Message>> getGroupChatStream(String groupId) {
    return firestore
        .collection('groups')
        .doc(groupId)
        .collection('chats')
        .orderBy('timeSent')
        .snapshots()
        .map(
      (event) {
        List<Message> messages = [];
        for (var document in event.docs) {
          messages.add(Message.fromMap(document.data()));
        }
        return messages;
      },
    );
  }

  void _saveDataToContactsSubCollection(
    UserModel senderUserData,
    UserModel? receiverUserData,
    String text,
    DateTime timeSent,
    String recieverUserId,
    bool isGroupChat,
  ) async {
    // to show reciever message
    //* users => reciever user id => chats => current user id => set data
    if (isGroupChat) {
      await firestore.collection('groups').doc(recieverUserId).update({
        'lastMessage': text,
        'timeSent': DateTime.now().millisecondsSinceEpoch,
      });
    } else {
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
        name: receiverUserData!.name,
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
  }

  void _saveMessageToMessageSubcollection({
    required String recieverUserId,
    required String text,
    required DateTime timeSent,
    required String messageId,
    required String username,
    required MessageEnum messageType,
    required MessageReply? messageReply,
    required String senderUsername,
    required String? receiverusername,
    required bool isGroupChat,
  }) async {
    final message = Message(
      senderId: auth.currentUser!.uid,
      receiverId: recieverUserId,
      text: text,
      type: messageType,
      timeSent: timeSent,
      messageId: messageId,
      isSeen: false,
      repliedMessage: messageReply == null ? '' : messageReply.message,
      repliedTo: messageReply == null
          ? ''
          : messageReply.isMe
              ? senderUsername
              : receiverusername ?? '',
      repliedMessageType:
          messageReply == null ? MessageEnum.text : messageReply.messageEnum,
    );
    //* users => sender id => reciever id => messages = message id => set data
    if (isGroupChat) {
      await firestore
          .collection('groups')
          .doc(recieverUserId)
          .collection('chats')
          .doc(messageId)
          .set(message.toMap());
    } else {
      await firestore
          .collection('users')
          .doc(auth.currentUser!.uid)
          .collection('chats')
          .doc(recieverUserId)
          .collection('messages')
          .doc(messageId)
          .set(message.toMap());
      //* users => reciever id => sender id => messages = message id => set data
      await firestore
          .collection('users')
          .doc(recieverUserId)
          .collection('chats')
          .doc(auth.currentUser!.uid)
          .collection('messages')
          .doc(messageId)
          .set(message.toMap());
    }
  }

  void sendTextMessage({
    required BuildContext context,
    required String text,
    required String receiverUserId,
    required UserModel senderUser,
    required MessageReply? messageReply,
    required bool isGroupChat,
  }) async {
    //* users => sender id => reciever id => messages => message id => store message

    try {
      var timeSent = DateTime.now();
      UserModel? recieverUserData;

      if (!isGroupChat) {
        var userDataMap =
            await firestore.collection('users').doc(receiverUserId).get();

        recieverUserData = UserModel.fromMap(userDataMap.data()!);
      }
      var messageId = const Uuid().v1();
      _saveDataToContactsSubCollection(
        senderUser,
        recieverUserData,
        text,
        timeSent,
        receiverUserId,
        isGroupChat,
      );
      _saveMessageToMessageSubcollection(
        recieverUserId: receiverUserId,
        text: text,
        timeSent: timeSent,
        messageId: messageId,
        username: senderUser.name,
        messageType: MessageEnum.text,
        messageReply: messageReply,
        senderUsername: senderUser.name,
        receiverusername: recieverUserData?.name,
        isGroupChat: isGroupChat,
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
    required MessageReply? messageReply,
    required bool isGroupChat,
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

      UserModel? receiverUserData;
      if (!isGroupChat) {
        var userDataMap =
            await firestore.collection('users').doc(receiverUserId).get();
        receiverUserData = UserModel.fromMap(userDataMap.data()!);
      }

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
        isGroupChat,
      );

      _saveMessageToMessageSubcollection(
        recieverUserId: receiverUserId,
        text: imageUrl,
        timeSent: timeSent,
        messageId: messageId,
        username: senderUserData.name,
        receiverusername: receiverUserData?.name,
        messageType: messageEnum,
        messageReply: messageReply,
        senderUsername: senderUserData.name,
        isGroupChat: isGroupChat,
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
    required MessageReply? messageReply,
    required bool isGroupChat,
  }) async {
    //* users => sender id => reciever id => messages => message id => store message

    try {
      var timeSent = DateTime.now();
      UserModel ?recieverUserData;

  if(!isGroupChat) {
        var userDataMap =
          await firestore.collection('users').doc(receiverUserId).get();

      recieverUserData = UserModel.fromMap(userDataMap.data()!);
  }
      var messageId = const Uuid().v1();
      _saveDataToContactsSubCollection(
        senderUser,
        recieverUserData,
        'GIF',
        timeSent,
        receiverUserId,
        isGroupChat,
      );
      _saveMessageToMessageSubcollection(
        recieverUserId: receiverUserId,
        text: gifUrl,
        timeSent: timeSent,
        messageId: messageId,
        username: senderUser.name,
        receiverusername: recieverUserData?.name,
        messageType: MessageEnum.gif,
        messageReply: messageReply,
        senderUsername: senderUser.name,
        isGroupChat: isGroupChat,
      );
    } catch (e) {
      showTopSnackBar(
        context,
        CustomSnackBar.error(message: e.toString()),
      );
    }
  }

  void setChatMessageSeen(
    BuildContext context,
    String recieverUserId,
    String messageId,
  ) async {
    try {
      await firestore
          .collection('users')
          .doc(auth.currentUser!.uid)
          .collection('chats')
          .doc(recieverUserId)
          .collection('messages')
          .doc(messageId)
          .update(
        {
          'isSeen': true,
        },
      );

      await firestore
          .collection('users')
          .doc(recieverUserId)
          .collection('chats')
          .doc(auth.currentUser!.uid)
          .collection('messages')
          .doc(messageId)
          .update(
        {
          'isSeen': true,
        },
      );
    } catch (e) {
      showTopSnackBar(
        context,
        CustomSnackBar.error(
          message: e.toString(),
        ),
      );
    }
  }
}
