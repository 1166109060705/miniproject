<<<<<<< HEAD
=======
import 'dart:typed_data';
>>>>>>> cbeeeaee41c1ab1bacd462e8a36c8af2e08be77a
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:socialapp/features/auth/presentation/cubits/auth_cubit.dart';
<<<<<<< HEAD
=======
import 'package:socialapp/features/chat/domain/entities/message.dart';
>>>>>>> cbeeeaee41c1ab1bacd462e8a36c8af2e08be77a
import 'package:socialapp/features/chat/presentation/components/message_bubble.dart';
import 'package:socialapp/features/chat/presentation/cubits/chat_cubit.dart';
import 'package:socialapp/features/chat/presentation/cubits/chat_state.dart';
import 'package:socialapp/features/profile/domain/entities/profile_user.dart';

class ChatPage extends StatefulWidget {
  final ProfileUser receiver;

  const ChatPage({
    super.key,
    required this.receiver,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  late final ChatCubit _chatCubit;
  late final String _currentUserId;

  @override
  void initState() {
    super.initState();
    _chatCubit = context.read<ChatCubit>();
    _currentUserId = context.read<AuthCubit>().currentUser!.uid;
    _chatCubit.startChat(_currentUserId, widget.receiver.uid);
  }

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    // Clear the input field immediately for better UX
    _messageController.clear();

    try {
      await _chatCubit.sendTextMessage(
        _currentUserId,
        widget.receiver.uid,
        message,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send message: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _pickImage() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        if (file.bytes == null) {
          throw Exception('Could not read the image file');
        }

        await _chatCubit.sendImage(
          _currentUserId,
          widget.receiver.uid,
          file.name,
          file.bytes!,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send image: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _pickVideo() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.video,
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        if (file.bytes == null) {
          throw Exception('Could not read the video file');
        }

        if (file.size > 100 * 1024 * 1024) { // 100MB limit
          throw Exception('Video size is too large. Please choose a video under 100MB.');
        }

        await _chatCubit.sendVideo(
          _currentUserId,
          widget.receiver.uid,
          file.name,
          file.bytes!,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send video: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(widget.receiver.profileImageUrl),
              radius: 16,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                widget.receiver.name,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: BlocConsumer<ChatCubit, ChatState>(
              listener: (context, state) {
                if (state is ChatError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(state.message)),
                  );
                }
              },
              buildWhen: (previous, current) => 
                current is ChatMessagesLoaded || current is ChatInitial,
              builder: (context, state) {
                if (state is ChatMessagesLoaded) {
                  return Stack(
                    children: [
                      ListView.builder(
                        padding: const EdgeInsets.all(8),
                        reverse: true,
                        itemCount: state.messages.length,
                        itemBuilder: (context, index) {
                          final message = state.messages[index];
                      return MessageBubble(
                        message: message,
                        isMe: message.senderId == _currentUserId,
                      );
                    },
                  ),
                  if (state is MessageSending)
                    const Positioned.fill(
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                    ],
                  );
                }
                return const Center(child: CircularProgressIndicator());
              },
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.image),
              onPressed: _pickImage,
              tooltip: 'Send Image',
            ),
            IconButton(
              icon: const Icon(Icons.video_library),
              onPressed: _pickVideo,
              tooltip: 'Send Video',
            ),
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        maxLines: null,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: const InputDecoration(
                          hintText: 'Type a message...',
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          border: InputBorder.none,
                        ),
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.send),
                      onPressed: _sendMessage,
                      color: Theme.of(context).colorScheme.primary,
                      tooltip: 'Send Message',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }
}