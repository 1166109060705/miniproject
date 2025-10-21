import 'dart:typed_data';
import 'package:socialapp/features/chat/domain/entities/message.dart';

abstract class ChatRepo {
  Stream<List<Message>> getMessages(String chatId);
  Future<void> sendMessage(Message message);
  Future<String> uploadImage(String chatId, String fileName, Uint8List imageBytes);
  Future<String> uploadVideo(String chatId, String fileName, Uint8List videoBytes);
  String getChatId(String userId1, String userId2);
  Stream<List<String>> getRecentChatUsers(String userId);
}