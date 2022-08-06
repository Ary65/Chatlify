// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';

import 'package:chatlify/features/chat/controller/chat_controller.dart';
import 'package:chatlify/features/chat/widgets/message_replay_preview.dart';
import 'package:chatlify/features/common/enums/message_enum.dart';
import 'package:chatlify/features/common/providers/message_replay_provider.dart';
import 'package:chatlify/utils/utils.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:chatlify/utils/colors.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class BottomChatField extends ConsumerStatefulWidget {
  final String receiverUserId;
  final bool isGroupChat;

  const BottomChatField({
    Key? key,
    required this.receiverUserId,
    required this.isGroupChat,
  }) : super(key: key);

  @override
  ConsumerState<BottomChatField> createState() => _BottomChatFieldState();
}

class _BottomChatFieldState extends ConsumerState<BottomChatField> {
  bool _isShowSendButton = false;
  bool _isShowEmojiContainer = false;
  final _messageController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  FlutterSoundRecorder? _soundRecorder;
  bool isRecorderInit = false;
  bool isRecording = false;

  @override
  void initState() {
    super.initState();
    _soundRecorder = FlutterSoundRecorder();
    openAudio();
  }

  void openAudio() async {
    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      throw RecordingPermissionException('Microphone permission not granted');
    }
    await _soundRecorder!.openRecorder();
    isRecorderInit = true;
  }

  void sendTextMessage() async {
    if (_isShowSendButton) {
      ref.read(chatControllerProvider).sendTextMessage(
            context,
            _messageController.text.trim(),
            widget.receiverUserId,
            widget.isGroupChat,
          );
      setState(
        () {
          _messageController.text = '';
        },
      );
    } else {
      var tempDir = await getTemporaryDirectory();
      var path = '${tempDir.path}/flutter_sound.aac';
      if (!isRecorderInit) {
        return;
      }
      if (isRecording) {
        await _soundRecorder!.stopRecorder();
        sendFileMessage(File(path), MessageEnum.audio);
      } else {
        await _soundRecorder!.startRecorder(toFile: path);
      }
      setState(() {
        isRecording = !isRecording;
      });
    }
  }

  void sendFileMessage(
    File file,
    MessageEnum messageEnum,
  ) {
    ref.read(chatControllerProvider).sendFileMessage(
          context,
          file,
          widget.receiverUserId,
          messageEnum,
          widget.isGroupChat,
        );
  }

  void selectImage() async {
    File? image = await pickImageFromGallery(context);
    if (image != null) {
      sendFileMessage(image, MessageEnum.image);
    }
  }

  void selectVideo() async {
    File? video = await pickVideoFromGallery(context);
    if (video != null) {
      sendFileMessage(video, MessageEnum.video);
    }
  }

  void hideEmojiContainer() {
    setState(() {
      _isShowEmojiContainer = false;
    });
  }

  void showEmojiContainer() {
    setState(() {
      _isShowEmojiContainer = true;
    });
  }

  void showKweyboard() => _focusNode.requestFocus();
  void hideKeyboard() => _focusNode.unfocus();

  void toggleEmojiKeyboardContainer() {
    if (_isShowEmojiContainer) {
      showKweyboard();
      hideEmojiContainer();
    } else {
      hideKeyboard();
      showEmojiContainer();
    }
  }

  void selectGIF() async {
    final gif = await pickGIF(context);
    if (gif != null) {
      // ignore: use_build_context_synchronously
      ref.read(chatControllerProvider).sendGIFMessage(
            context,
            gif.url,
            widget.receiverUserId,
            widget.isGroupChat,
          );
    }
  }

  @override
  void dispose() {
    super.dispose();
    _messageController.dispose();
    _soundRecorder!.closeRecorder();
    isRecorderInit = false;
  }

  @override
  Widget build(BuildContext context) {
    final messageReplay = ref.watch(messageReplyProvider);
    final isShowMessageReplay = messageReplay != null;
    final w = MediaQuery.of(context).size.width;
    return Column(
      children: [
        isShowMessageReplay ? const MessageReplayPreview() : const SizedBox(),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                focusNode: _focusNode,
                controller: _messageController,
                textCapitalization: TextCapitalization.sentences,
                onChanged: (value) {
                  if (value.isNotEmpty) {
                    setState(() {
                      _isShowSendButton = true;
                    });
                  } else {
                    setState(() {
                      _isShowSendButton = false;
                    });
                  }
                },
                decoration: _isShowSendButton
                    ? InputDecoration(
                        filled: true,
                        fillColor: mobileChatBoxColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20.0),
                          borderSide: const BorderSide(
                            width: 0,
                            style: BorderStyle.none,
                          ),
                        ),
                        contentPadding: const EdgeInsets.all(10.0),
                        prefixIcon: Container(
                          padding: const EdgeInsets.all(8),
                          child: InkWell(
                            onTap: toggleEmojiKeyboardContainer,
                            child: const Icon(
                              Icons.emoji_emotions,
                              color: Colors.grey,
                            ),
                          ),
                        ))
                    : InputDecoration(
                        filled: true,
                        fillColor: mobileChatBoxColor,
                        prefixIcon: Container(
                          padding: const EdgeInsets.all(8),
                          width: w / 5.6,
                          child: Row(
                            children: [
                              InkWell(
                                onTap: toggleEmojiKeyboardContainer,
                                child: const Icon(
                                  Icons.emoji_emotions,
                                  color: Colors.grey,
                                ),
                              ),
                              InkWell(
                                onTap: selectGIF,
                                child: const Icon(
                                  Icons.gif,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                        suffixIcon: Container(
                          padding: const EdgeInsets.all(5),
                          width: w / 5.6,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              InkWell(
                                onTap: selectImage,
                                child: const Icon(
                                  Icons.camera_alt,
                                  color: Colors.grey,
                                ),
                              ),
                              InkWell(
                                onTap: selectVideo,
                                child: const Icon(
                                  Icons.attach_file,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                        hintText: 'Type a message',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20.0),
                          borderSide: const BorderSide(
                            width: 0,
                            style: BorderStyle.none,
                          ),
                        ),
                        contentPadding: const EdgeInsets.all(10.0),
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 1, right: 2, left: 4),
              child: CircleAvatar(
                backgroundColor: const Color(0xFF128C7E),
                radius: 23,
                child: GestureDetector(
                  onTap: sendTextMessage,
                  child: Icon(
                    _isShowSendButton
                        ? Icons.send
                        : isRecording
                            ? Icons.close
                            : Icons.mic,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
        _isShowEmojiContainer
            ? SizedBox(
                height: 310,
                child: EmojiPicker(
                  config: const Config(bgColor: backgroundColor),
                  onEmojiSelected: (category, emoji) {
                    setState(
                      () {
                        _messageController.text += emoji.emoji;
                        _isShowSendButton = true;
                      },
                    );
                  },
                ),
              )
            : const SizedBox(),
      ],
    );
  }
}
