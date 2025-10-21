import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:socialapp/features/group/domain/entities/group.dart';
import 'package:socialapp/features/group/domain/entities/group_post.dart';
import 'package:socialapp/features/group/domain/repos/group_repo.dart';
import 'package:socialapp/features/group/presentation/cubits/group_states.dart';
import 'package:socialapp/features/storage/domain/storage_repo.dart';

class GroupCubit extends Cubit<GroupState> {
  final GroupRepo groupRepo;
  final StorageRepo storageRepo;

  GroupCubit({
    required this.groupRepo,
    required this.storageRepo,
  }) : super(GroupInitial());

  // Create group
  Future<void> createGroup({
    required String name,
    required String description,
    required String adminId,
    required String adminName,
    String? imagePath,
  }) async {
    try {
      emit(GroupLoading());

      // Upload image if provided
      String? imageUrl;
      if (imagePath != null) {
        imageUrl = await storageRepo.uploadPostImageMobile(imagePath, name);
      }

      // Create group
      final group = Group(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        description: description,
        imageUrl: imageUrl,
        adminId: adminId,
        adminName: adminName,
        memberIds: [adminId],
        memberNames: [adminName],
        createdAt: DateTime.now(),
      );

      await groupRepo.createGroup(group);
      emit(GroupCreated());
    } catch (e) {
      emit(GroupError('Error creating group: $e'));
    }
  }

  // Fetch user groups
  Future<void> fetchUserGroups(String userId) async {
    try {
      emit(GroupLoading());
      final groups = await groupRepo.fetchUserGroups(userId);
      emit(GroupLoaded(groups));
    } catch (e) {
      emit(GroupError('Error fetching groups: $e'));
    }
  }

  // Fetch all groups
  Future<void> fetchAllGroups() async {
    try {
      emit(GroupLoading());
      final groups = await groupRepo.fetchAllGroups();
      emit(AllGroupsLoaded(groups));
    } catch (e) {
      emit(GroupError('Error fetching all groups: $e'));
    }
  }

  // Join group
  Future<void> joinGroup(String groupId, String userId, String userName) async {
    try {
      await groupRepo.joinGroup(groupId, userId, userName);
      fetchUserGroups(userId); // Refresh groups
    } catch (e) {
      emit(GroupError('Error joining group: $e'));
    }
  }

  // Leave group
  Future<void> leaveGroup(String groupId, String userId, String userName) async {
    try {
      await groupRepo.leaveGroup(groupId, userId, userName);
      fetchUserGroups(userId); // Refresh groups
    } catch (e) {
      emit(GroupError('Error leaving group: $e'));
    }
  }

  // Update group
  Future<void> updateGroup(Group group, {String? newImagePath}) async {
    try {
      emit(GroupLoading());

      // Upload new image if provided
      String? imageUrl = group.imageUrl;
      if (newImagePath != null) {
        imageUrl = await storageRepo.uploadPostImageMobile(newImagePath, group.name);
      }

      final updatedGroup = group.copyWith(imageUrl: imageUrl);
      await groupRepo.updateGroup(updatedGroup);
      
      // Refresh groups
      fetchUserGroups(group.adminId);
    } catch (e) {
      emit(GroupError('Error updating group: $e'));
    }
  }

  // Delete group
  Future<void> deleteGroup(String groupId, String userId) async {
    try {
      emit(GroupLoading());
      await groupRepo.deleteGroup(groupId);
      emit(GroupDeleted());
      fetchUserGroups(userId); // Refresh groups
    } catch (e) {
      emit(GroupError('Error deleting group: $e'));
    }
  }

  // Create group post
  Future<void> createGroupPost({
    required String groupId,
    required String userId,
    required String userName,
    String? text,
    String? imagePath,
  }) async {
    try {
      emit(GroupLoading());

      // Upload image if provided
      String? imageUrl;
      if (imagePath != null) {
        imageUrl = await storageRepo.uploadPostImageMobile(imagePath, userId);
      }

      // Create post
      final post = GroupPost(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: userId,
        userName: userName,
        imageUrl: imageUrl,
        text: text,
        timestamp: DateTime.now(),
        likes: [],
        comments: [],
        groupId: groupId,
      );

      await groupRepo.createGroupPost(post);
      emit(GroupPostCreated());
    } catch (e) {
      emit(GroupError('Error creating group post: $e'));
    }
  }

  // Fetch group posts
  Future<void> fetchGroupPosts(String groupId) async {
    try {
      emit(GroupLoading());
      final posts = await groupRepo.fetchGroupPosts(groupId);
      emit(GroupPostsLoaded(posts));
    } catch (e) {
      emit(GroupError('Error fetching group posts: $e'));
    }
  }

  // Delete group post
  Future<void> deleteGroupPost(String postId, String groupId) async {
    try {
      await groupRepo.deleteGroupPost(postId);
      fetchGroupPosts(groupId); // Refresh posts
    } catch (e) {
      emit(GroupError('Error deleting group post: $e'));
    }
  }

  // Toggle like on group post
  Future<void> toggleLikeGroupPost(String postId, String userId, String groupId) async {
    try {
      await groupRepo.toggleLikeGroupPost(postId, userId);
      fetchGroupPosts(groupId); // Refresh posts
    } catch (e) {
      emit(GroupError('Error toggling like: $e'));
    }
  }

  // Add comment to group post
  Future<void> addCommentToGroupPost(String postId, String groupId, Map<String, dynamic> comment) async {
    try {
      await groupRepo.addCommentToGroupPost(postId, comment);
      fetchGroupPosts(groupId); // Refresh posts
    } catch (e) {
      emit(GroupError('Error adding comment: $e'));
    }
  }
}