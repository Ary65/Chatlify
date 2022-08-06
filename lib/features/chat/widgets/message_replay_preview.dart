import 'package:chatlify/features/chat/widgets/display_text_image_gif.dart';
import 'package:chatlify/features/common/providers/message_replay_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MessageReplayPreview extends ConsumerWidget {
  const MessageReplayPreview({Key? key}) : super(key: key);

  void cancelReplay(WidgetRef ref) {
    ref.read(messageReplyProvider.state).update((state) => null);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messageReplay = ref.watch(messageReplyProvider);
    return Container(
      width: 350,
      padding: const EdgeInsets.all(8),
      decoration: const BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  messageReplay!.isMe ? 'Me' : 'Opposite',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => cancelReplay(ref),
                child: const Icon(
                  Icons.close,
                  size: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 200,
            child: DisplayTextImageGIF(
              message: messageReplay.message,
              type: messageReplay.messageEnum,
            ),
          ),
        ],
      ),
    );
  }
}
