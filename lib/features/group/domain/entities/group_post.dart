import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:socialapp/features/post/domain/entities/comment.dart';

class GroupPost {
  final String id;
  final String userId;
  final String userName;
  final String? imageUrl;
  final String? text;
  final DateTime timestamp;
  final List<String> likes;
  final List<Comment> comments;
  final String groupId;

  const GroupPost({
    required this.id,
    required this.userId,
    required this.userName,
    this.imageUrl,
    this.text,
    required this.timestamp,
    required this.likes,
    required this.comments,
    required this.groupId,
  });

  factory GroupPost.fromJson(Map<String, dynamic> json) {
    return GroupPost(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      userName: json['userName'] ?? 'Unknown',
      imageUrl: json['imageUrl'],
      text: json['text'],
      timestamp: json['timestamp'] != null
          ? (json['timestamp'] as Timestamp).toDate()
          : DateTime.now(),
      likes: List<String>.from(json['likes'] ?? []),
      comments: (json['comments'] as List<dynamic>? ?? [])
          .map((comment) => Comment.fromJson(comment))
          .toList(),
      groupId: json['groupId'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'imageUrl': imageUrl,
      'text': text,
      'timestamp': Timestamp.fromDate(timestamp),
      'likes': likes,
      'comments': comments.map((comment) => comment.toJson()).toList(),
      'groupId': groupId,
    };
  }

  GroupPost copyWith({
    String? id,
    String? userId,
    String? userName,
    String? imageUrl,
    String? text,
    DateTime? timestamp,
    List<String>? likes,
    List<Comment>? comments,
    String? groupId,
  }) {
    return GroupPost(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      imageUrl: imageUrl ?? this.imageUrl,
      text: text ?? this.text,
      timestamp: timestamp ?? this.timestamp,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
      groupId: groupId ?? this.groupId,
    );
  }
}