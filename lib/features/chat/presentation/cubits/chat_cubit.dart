import 'dart:typed_data';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:socialapp/features/chat/domain/entities/message.dart';
import 'package:socialapp/features/chat/domain/repos/chat_repo.dart';
import 'package:socialapp/features/chat/presentation/cubits/chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  final ChatRepo chatRepo;

  ChatCubit({required this.chatRepo}) : super(ChatInitial());

  void startChat(String userId1, String userId2) {
    final chatId = chatRepo.getChatId(userId1, userId2);
    chatRepo.getMessages(chatId).listen(
      (messages) {
        emit(ChatMessagesLoaded(messages));
      },
      onError: (error) {
        emit(ChatError(error.toString()));
      },
    );
  }

  Future<void> sendTextMessage(
    String senderId,
    String receiverId,
    String text,
  ) async {
    try {
      emit(MessageSending());
      
      final message = Message(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        senderId: senderId,
        receiverId: receiverId,
        content: text,
        type: MessageType.text,
        timestamp: DateTime.now(),
      );

      await chatRepo.sendMessage(message);
      emit(MessageSent());
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }

  Future<void> sendImage(
    String senderId,
    String receiverId,
    String fileName,
    Uint8List imageBytes,
  ) async {
    try {
      emit(MessageSending());
      
      final chatId = chatRepo.getChatId(senderId, receiverId);
      final imageUrl = await chatRepo.uploadImage(chatId, fileName, imageBytes);

      final message = Message(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        senderId: senderId,
        receiverId: receiverId,
        content: imageUrl,
        type: MessageType.image,
        timestamp: DateTime.now(),
      );

      await chatRepo.sendMessage(message);
      emit(MessageSent());
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }

  Future<void> sendVideo(
    String senderId,
    String receiverId,
    String fileName,
    Uint8List videoBytes,
  ) async {
    try {
      emit(MessageSending());
      
      final chatId = chatRepo.getChatId(senderId, receiverId);
      final videoUrl = await chatRepo.uploadVideo(chatId, fileName, videoBytes);

      final message = Message(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        senderId: senderId,
        receiverId: receiverId,
        content: videoUrl,
        type: MessageType.video,
        timestamp: DateTime.now(),
      );

      await chatRepo.sendMessage(message);
      emit(MessageSent());
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }

  Stream<List<String>> getRecentChatUsers(String userId) {
    return chatRepo.getRecentChatUsers(userId);
  }
}