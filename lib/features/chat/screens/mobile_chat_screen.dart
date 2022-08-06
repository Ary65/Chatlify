// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:chatlify/features/auth/controller/auth_controller.dart';
import 'package:chatlify/features/call/controller/call_controller.dart';
import 'package:chatlify/features/call/screens/call_pickup_screen.dart';
import 'package:chatlify/features/chat/widgets/bottom_chat_field.dart';
import 'package:chatlify/models/user_model.dart';
import 'package:chatlify/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:chatlify/utils/colors.dart';
import 'package:chatlify/features/chat/widgets/chat_list.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MobileChatScreen extends ConsumerWidget {
  static const routeName = '/mobile_chat_screen';
  final String name;
  final String uid;
  final bool isGroupChat;
  final String profilePic;
  const MobileChatScreen({
    Key? key,
    required this.name,
    required this.uid,
    required this.isGroupChat,
    required this.profilePic,
  }) : super(key: key);
  void makeCall(WidgetRef ref, BuildContext context) {
    ref.read(callControllerProvider).makeCall(
          context,
          name,
          uid,
          profilePic,
          isGroupChat,
        );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CallPickupScreen(
      scaffold: Scaffold(
        appBar: AppBar(
          backgroundColor: appBarColor,
          title: isGroupChat
              ? Text(name)
              : StreamBuilder<UserModel>(
                  stream: ref.read(authControllerProvider).userDataById(uid),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Loader();
                    }
                    return Row(
                      children: [
                        Text(name),
                        // Text(
                        //   snapshot.data!.isOnline ? 'online' : 'offline',
                        //   style: const TextStyle(
                        //     fontSize: 13,
                        //     fontWeight: FontWeight.normal,
                        //   ),
                        // ),
                        snapshot.data!.isOnline
                            ? const Padding(
                                padding: EdgeInsets.only(left: 4, top: 3),
                                child: Icon(
                                  Icons.check_circle,
                                  color: Colors.greenAccent,
                                  size: 17,
                                ),
                              )
                            : const Padding(
                                padding: EdgeInsets.all(4.0),
                                child: Text(
                                  'offline',
                                  style: TextStyle(fontSize: 13),
                                ),
                              ),
                        // snapshot.data!.isOnline
                        //     ? const SizedBox()
                        //     : Text(
                        //         'last seen ${Utils.timeAgo(snapshot.data!.lastSeen)}',
                        //         style: const TextStyle(
                        //           fontSize: 13,
                        //           fontWeight: FontWeight.normal,
                        //         ),
                        //       ),
                      ],
                    );
                  }),
          centerTitle: false,
          actions: [
            IconButton(
                onPressed: () => makeCall(ref, context),
                icon: const Icon(Icons.video_call)),
            IconButton(onPressed: () {}, icon: const Icon(Icons.call)),
            IconButton(onPressed: () {}, icon: const Icon(Icons.more_vert)),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: ChatList(
                receiverUserId: uid,
                isGroupChat: isGroupChat,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: BottomChatField(
                receiverUserId: uid,
                isGroupChat: isGroupChat,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
