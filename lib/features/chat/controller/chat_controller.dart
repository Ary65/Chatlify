// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';

import 'package:chatlify/features/auth/controller/auth_controller.dart';
import 'package:chatlify/features/common/enums/message_enum.dart';
import 'package:chatlify/models/chat_contact.dart';
import 'package:chatlify/models/message.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chatlify/features/chat/repositories/chat_repository.dart';

final chatControllerProvider = Provider((ref) {
  final chatRepository = ref.watch(chatRepositoryProvider);
  return ChatController(
    chatRepository: chatRepository,
    ref: ref,
  );
});

class ChatController {
  final ChatRepository chatRepository;
  final ProviderRef ref;
  ChatController({
    required this.chatRepository,
    required this.ref,
  });

  Stream<List<ChatContact>> chatContacts() {
    return chatRepository.getChatContacts();
  }

  Stream<List<Message>> chatStream(String recieveUserId) {
    return chatRepository.getChatStream(recieveUserId);
  }

  void sendTextMessage(
    BuildContext context,
    String text,
    String receiverUserId,
  ) {
    ref.read(userDataAuthProvider).whenData(
          (value) => chatRepository.sendTextMessage(
            context: context,
            text: text,
            receiverUserId: receiverUserId,
            senderUser: value!,
          ),
        );
  }

  void sendFileMessage(
    BuildContext context,
    File file,
    String receiverUserId,
    MessageEnum messageEnum,
  ) {
    ref.read(userDataAuthProvider).whenData(
          (value) => chatRepository.sendFileMessage(
            context: context,
            file: file,
            receiverUserId: receiverUserId,
            senderUserData: value!,
            ref: ref,
            messageEnum: messageEnum,
          ),
        );
  }

  void sendGIFMessage(
    BuildContext context,
    String gifUrl,
    String receiverUserId,
  ) {
    int gifUrlPartIndex = gifUrl.lastIndexOf('-') + 1;
    String gifUrlPart = gifUrl.substring(gifUrlPartIndex);
    String newgifUrl = 'https://i.giphy.com/media/$gifUrlPart/200.gif';
    ref.read(userDataAuthProvider).whenData(
          (value) => chatRepository.sendGIFMessage(
            context: context,
            gifUrl: newgifUrl,
            receiverUserId: receiverUserId,
            senderUser: value!,
          ),
        );
  }
}
