import 'package:cloud_firestore/cloud_firestore.dart';

class Group {
  final String id;
  final String name;
  final String description;
  final String? imageUrl;
  final String adminId;
  final String adminName;
  final List<String> memberIds;
  final List<String> memberNames;
  final DateTime createdAt;

  const Group({
    required this.id,
    required this.name,
    required this.description,
    this.imageUrl,
    required this.adminId,
    required this.adminName,
    required this.memberIds,
    required this.memberNames,
    required this.createdAt,
  });

  factory Group.fromJson(Map<String, dynamic> json) {
    return Group(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['imageUrl'],
      adminId: json['adminId'] ?? '',
      adminName: json['adminName'] ?? '',
      memberIds: List<String>.from(json['memberIds'] ?? []),
      memberNames: List<String>.from(json['memberNames'] ?? []),
      createdAt: json['createdAt'] != null 
          ? (json['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'adminId': adminId,
      'adminName': adminName,
      'memberIds': memberIds,
      'memberNames': memberNames,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  Group copyWith({
    String? id,
    String? name,
    String? description,
    String? imageUrl,
    String? adminId,
    String? adminName,
    List<String>? memberIds,
    List<String>? memberNames,
    DateTime? createdAt,
  }) {
    return Group(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      adminId: adminId ?? this.adminId,
      adminName: adminName ?? this.adminName,
      memberIds: memberIds ?? this.memberIds,
      memberNames: memberNames ?? this.memberNames,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}