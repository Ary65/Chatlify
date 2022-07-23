// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:chatlify/features/common/enums/message_enum.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MessageReplay {
  final String message;
  final bool isMe;
  final MessageEnum messageEnum;
  MessageReplay(
    this.message,
    this.isMe,
    this.messageEnum,
  );
}

final messageReplayProvider = StateProvider<MessageReplay?>((ref) => null);
