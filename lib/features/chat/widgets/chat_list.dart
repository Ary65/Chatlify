// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:chatlify/models/message.dart';
import 'package:chatlify/utils/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:chatlify/features/chat/controller/chat_controller.dart';
import 'package:chatlify/utils/info.dart';
import 'package:chatlify/features/chat/widgets/my_message_card.dart';
import 'package:chatlify/features/chat/widgets/sender_message_card.dart';
import 'package:intl/intl.dart';

class ChatList extends ConsumerStatefulWidget {
  final String receiverUserId;
  const ChatList({
    Key? key,
    required this.receiverUserId,
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

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Message>>(
      stream: ref.read(chatControllerProvider).chatStream(
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
            if (messageData.senderId ==
                FirebaseAuth.instance.currentUser!.uid) {
              return MyMessageCard(
                message: messageData.text,
                date: timeSent,
                type: messageData.type,
              );
            }
            return SenderMessageCard(
              message: messageData.text,
              date: timeSent,
              type: messageData.type,
            );
          },
        );
      },
    );
  }
}
