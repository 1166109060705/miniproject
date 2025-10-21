import 'package:socialapp/features/group/domain/entities/group.dart';
import 'package:socialapp/features/group/domain/entities/group_post.dart';

abstract class GroupRepo {
  Future<void> createGroup(Group group);
  Future<List<Group>> fetchUserGroups(String userId);
  Future<List<Group>> fetchAllGroups(); // เพิ่ม method ใหม่
  Future<void> joinGroup(String groupId, String userId, String userName);
  Future<void> leaveGroup(String groupId, String userId, String userName);
  Future<void> updateGroup(Group group);
  Future<void> deleteGroup(String groupId);
  
  // Group posts
  Future<void> createGroupPost(GroupPost post);
  Future<List<GroupPost>> fetchGroupPosts(String groupId);
  Future<void> deleteGroupPost(String postId);
  Future<void> toggleLikeGroupPost(String postId, String userId);
  Future<void> addCommentToGroupPost(String postId, Map<String, dynamic> comment);
}