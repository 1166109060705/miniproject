import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:socialapp/features/group/domain/entities/group.dart';
import 'package:socialapp/features/group/domain/entities/group_post.dart';
import 'package:socialapp/features/group/domain/repos/group_repo.dart';

class FirebaseGroupRepo implements GroupRepo {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  Future<void> createGroup(Group group) async {
    try {
      await firestore
          .collection('groups')
          .doc(group.id)
          .set(group.toJson());
      print('Group created successfully: ${group.id}');
    } catch (e) {
      print('Error creating group: $e');
      rethrow;
    }
  }

  @override
  Future<List<Group>> fetchUserGroups(String userId) async {
    try {
      print('Fetching groups for user: $userId');
      
      final querySnapshot = await firestore
          .collection('groups')
          .where('memberIds', arrayContains: userId)
          .get();
      
      print('Found ${querySnapshot.docs.length} groups');
      
      final groups = querySnapshot.docs.map((doc) {
        final data = doc.data();
        print('Group data: $data');
        return Group.fromJson(data);
      }).toList();
      
      return groups;
    } catch (e) {
      print('Error fetching user groups: $e');
      return [];
    }
  }

  @override
  Future<List<Group>> fetchAllGroups() async {
    try {
      print('Fetching all groups');
      
      final querySnapshot = await firestore
          .collection('groups')
          .get();
      
      print('Found ${querySnapshot.docs.length} total groups');
      
      final groups = querySnapshot.docs.map((doc) {
        final data = doc.data();
        return Group.fromJson(data);
      }).toList();
      
      // Sort by creation date (newest first)
      groups.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
      return groups;
    } catch (e) {
      print('Error fetching all groups: $e');
      return [];
    }
  }

  @override
  Future<void> joinGroup(String groupId, String userId, String userName) async {
    try {
      await firestore.collection('groups').doc(groupId).update({
        'memberIds': FieldValue.arrayUnion([userId]),
        'memberNames': FieldValue.arrayUnion([userName]),
      });
    } catch (e) {
      print('Error joining group: $e');
      rethrow;
    }
  }

  @override
  Future<void> leaveGroup(String groupId, String userId, String userName) async {
    try {
      await firestore.collection('groups').doc(groupId).update({
        'memberIds': FieldValue.arrayRemove([userId]),
        'memberNames': FieldValue.arrayRemove([userName]),
      });
    } catch (e) {
      print('Error leaving group: $e');
      rethrow;
    }
  }

  @override
  Future<void> updateGroup(Group group) async {
    try {
      await firestore
          .collection('groups')
          .doc(group.id)
          .update(group.toJson());
    } catch (e) {
      print('Error updating group: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteGroup(String groupId) async {
    try {
      // Delete group posts first
      final groupPosts = await firestore
          .collection('group_posts')
          .where('groupId', isEqualTo: groupId)
          .get();
      
      for (var doc in groupPosts.docs) {
        await doc.reference.delete();
      }
      
      // Then delete the group
      await firestore.collection('groups').doc(groupId).delete();
    } catch (e) {
      print('Error deleting group: $e');
      rethrow;
    }
  }

  @override
  Future<void> createGroupPost(GroupPost post) async {
    try {
      await firestore
          .collection('group_posts')
          .doc(post.id)
          .set(post.toJson());
      print('Group post created successfully: ${post.id}');
    } catch (e) {
      print('Error creating group post: $e');
      rethrow;
    }
  }

  @override
  Future<List<GroupPost>> fetchGroupPosts(String groupId) async {
    try {
      print('Fetching posts for group: $groupId');
      
      final querySnapshot = await firestore
          .collection('group_posts')
          .where('groupId', isEqualTo: groupId)
          .get();
      
      print('Found ${querySnapshot.docs.length} group posts');
      
      final posts = querySnapshot.docs.map((doc) {
        final data = doc.data();
        print('Group post data: $data');
        return GroupPost.fromJson(data);
      }).toList();
      
      // Sort by timestamp (newest first)
      posts.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      
      return posts;
    } catch (e) {
      print('Error fetching group posts: $e');
      return [];
    }
  }

  @override
  Future<void> deleteGroupPost(String postId) async {
    try {
      await firestore.collection('group_posts').doc(postId).delete();
    } catch (e) {
      print('Error deleting group post: $e');
      rethrow;
    }
  }

  @override
  Future<void> toggleLikeGroupPost(String postId, String userId) async {
    try {
      final postRef = firestore.collection('group_posts').doc(postId);
      final doc = await postRef.get();
      
      if (doc.exists) {
        final likes = List<String>.from(doc.data()?['likes'] ?? []);
        
        if (likes.contains(userId)) {
          await postRef.update({
            'likes': FieldValue.arrayRemove([userId]),
          });
        } else {
          await postRef.update({
            'likes': FieldValue.arrayUnion([userId]),
          });
        }
      }
    } catch (e) {
      print('Error toggling like on group post: $e');
      rethrow;
    }
  }

  @override
  Future<void> addCommentToGroupPost(String postId, Map<String, dynamic> comment) async {
    try {
      await firestore.collection('group_posts').doc(postId).update({
        'comments': FieldValue.arrayUnion([comment]),
      });
    } catch (e) {
      print('Error adding comment to group post: $e');
      rethrow;
    }
  }
}