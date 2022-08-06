import 'package:agora_uikit/agora_uikit.dart';
import 'package:chatlify/config/agora_config.dart';
import 'package:chatlify/features/call/controller/call_controller.dart';
import 'package:chatlify/models/call.dart';
import 'package:chatlify/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CallScreen extends ConsumerStatefulWidget {
  final String channelId;
  final Call call;
  final bool isGroupChat;
  const CallScreen({
    Key? key,
    required this.channelId,
    required this.call,
    required this.isGroupChat,
  }) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _CallScreenState();
}

class _CallScreenState extends ConsumerState<CallScreen> {
  AgoraClient? client;
  String baseUrl = 'https://chatlify-ary.herokuapp.com/';

  @override
  void initState() {
    super.initState();
    client = AgoraClient(
      agoraConnectionData: AgoraConnectionData(
        appId: AgoraConfig.appId,
        channelName: widget.channelId,
        tokenUrl: baseUrl,
      ),
    );
    initAgora();
  }

  void initAgora() async {
    await client!.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: client == null
          ? const Loader()
          : SafeArea(
              child: Stack(
                children: [
                  AgoraVideoViewer(
                    layoutType: Layout.floating,
                    client: client!,
                  ),
                  AgoraVideoButtons(
                    client: client!,
                    disableVideoButtonChild: IconButton(
                      onPressed: () async {
                        await client!.engine.leaveChannel();
                        // ignore: use_build_context_synchronously
                        ref.read(callControllerProvider).endCall(
                            widget.call.callerId,
                            widget.call.receiverId,
                            context);
                        // ignore: use_build_context_synchronously
                        Navigator.pop(context);
                      },
                      icon: const Icon(
                        Icons.call_end,
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
