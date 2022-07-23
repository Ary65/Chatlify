// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:audioplayers/audioplayers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatlify/features/chat/widgets/video_player_item.dart';
import 'package:flutter/material.dart';

import 'package:chatlify/features/common/enums/message_enum.dart';
import 'package:flutter_sound/flutter_sound.dart';

class DisplayTextImageGIF extends StatelessWidget {
  final String message;
  final MessageEnum type;

  const DisplayTextImageGIF({
    Key? key,
    required this.message,
    required this.type,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool _isPlaying = false;
    final AudioPlayer _audioPlayer = AudioPlayer();
    return type == MessageEnum.text
        ? Text(
            message,
            style: const TextStyle(fontSize: 16),
          )
        : type == MessageEnum.audio
            ? StatefulBuilder(builder: (context, setState) {
                return IconButton(
                  onPressed: () async {
                    if (_isPlaying) {
                      await _audioPlayer.pause();
                      setState(() {
                        _isPlaying = false;
                      });
                    } else {
                      await _audioPlayer.play(UrlSource(message));
                      setState(() {
                        _isPlaying = true;
                      });
                    }
                  },
                  icon: Icon(
                    _isPlaying ? Icons.pause_circle : Icons.play_circle,
                  ),
                );
              })
            : type == MessageEnum.video
                ? VideoPlayerItem(
                    videoUrl: message,
                  )
                : type == MessageEnum.gif
                    ? CachedNetworkImage(
                        imageUrl: message,
                      )
                    : CachedNetworkImage(
                        imageUrl: message,
                      );
  }
}
