// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:chatlify/features/common/enums/message_enum.dart';
import 'package:chatlify/features/common/providers/message_replay_provider.dart';
import 'package:chatlify/models/message.dart';
import 'package:chatlify/utils/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:chatlify/features/chat/controller/chat_controller.dart'; 
import 'package:chatlify/features/chat/widgets/my_message_card.dart';
import 'package:chatlify/features/chat/widgets/sender_message_card.dart';
import 'package:intl/intl.dart';

class ChatList extends ConsumerStatefulWidget {
  final String receiverUserId;
  final bool isGroupChat;
  const ChatList({
    Key? key,
    required this.receiverUserId,
    required this.isGroupChat,
  }) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ChatListState();
}

class _ChatListState extends ConsumerState<ChatList> {
  final ScrollController messageController = ScrollController();

  @override
  void dispose() {
    super.dispose();
    messageController.dispose();
  }

  void onMessageSwipe(
    String message,
    bool isMe,
    MessageEnum messageEnum,
  ) {
    ref.read(messageReplyProvider.state).update(
          (state) => MessageReply(
            message,
            isMe,
            messageEnum,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Message>>(
      stream: widget.isGroupChat
          ? ref
              .read(chatControllerProvider)
              .groupChatStream(widget.receiverUserId)
          : ref.read(chatControllerProvider).chatStream(
                widget.receiverUserId,
              ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Loader();
        }
        SchedulerBinding.instance.addPostFrameCallback((_) {
          messageController.animateTo(
              messageController.position.maxScrollExtent * 3,
              duration: const Duration(milliseconds: 300),
              curve: Curves.fastOutSlowIn);
        });
        // SchedulerBinding.instance.addPostFrameCallback((_) {
        //   messageController.jumpTo(
        //     messageController.position.maxScrollExtent * 1.55,

        //   );
        // });
        return ListView.builder(
          controller: messageController,
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            final messageData = snapshot.data![index];
            var timeSent = DateFormat.Hm().format(messageData.timeSent);

            if (!messageData.isSeen &&
                messageData.receiverId ==
                    FirebaseAuth.instance.currentUser!.uid) {
              ref.read(chatControllerProvider).setChatMessageSeen(
                    context,
                    widget.receiverUserId,
                    messageData.messageId,
                  );
            }
            if (messageData.senderId ==
                FirebaseAuth.instance.currentUser!.uid) {
              return MyMessageCard(
                message: messageData.text,
                date: timeSent,
                type: messageData.type,
                repliedText: messageData.repliedMessage,
                username: messageData.repliedTo,
                repliedMessageType: messageData.repliedMessageType,
                onLeftSwipe: () => onMessageSwipe(
                  messageData.text,
                  true,
                  messageData.type,
                ),
                isSeen: messageData.isSeen,
              );
            }
            return SenderMessageCard(
              message: messageData.text,
              date: timeSent,
              type: messageData.type,
              repliedText: messageData.repliedMessage,
              username: messageData.repliedTo,
              repliedMessageType: messageData.repliedMessageType,
              onRightSwipe: () => onMessageSwipe(
                messageData.text,
                false,
                messageData.type,
              ),
            );
          },
        );
      },
    );
  }
}
