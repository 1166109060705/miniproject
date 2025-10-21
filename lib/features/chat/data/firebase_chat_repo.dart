import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:socialapp/features/chat/domain/entities/message.dart';
import 'package:socialapp/features/chat/domain/repos/chat_repo.dart';

class FirebaseChatRepo implements ChatRepo {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  @override
  Stream<List<Message>> getMessages(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Message.fromJson(doc.data()))
          .toList();
    });
  }

  @override
  Future<void> sendMessage(Message message) async {
    final chatId = getChatId(message.senderId, message.receiverId);
    
    await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .doc(message.id)
        .set(message.toJson());

    // Update recent chats for both users
    await _updateRecentChat(message.senderId, message.receiverId);
    await _updateRecentChat(message.receiverId, message.senderId);
  }

  Future<void> _updateRecentChat(String userId1, String userId2) async {
    await _firestore
        .collection('users')
        .doc(userId1)
        .collection('recent_chats')
        .doc(userId2)
        .set({
          'userId': userId2,
          'timestamp': FieldValue.serverTimestamp(),
        });
  }

  @override
  Future<String> uploadImage(String chatId, String fileName, Uint8List imageBytes) async {
    final ref = _storage.ref().child('chats/$chatId/images/$fileName');
    await ref.putData(imageBytes);
    return await ref.getDownloadURL();
  }

  @override
  Future<String> uploadVideo(String chatId, String fileName, Uint8List videoBytes) async {
    final ref = _storage.ref().child('chats/$chatId/videos/$fileName');
    await ref.putData(videoBytes);
    return await ref.getDownloadURL();
  }

  @override
  String getChatId(String userId1, String userId2) {
    // Sort IDs to ensure consistent chat ID regardless of sender/receiver order
    final sortedIds = [userId1, userId2]..sort();
    return '${sortedIds[0]}_${sortedIds[1]}';
  }

  @override
  Stream<List<String>> getRecentChatUsers(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('recent_chats')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => doc.data()['userId'] as String).toList();
    });
  }
}