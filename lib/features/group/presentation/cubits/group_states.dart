import 'package:socialapp/features/group/domain/entities/group.dart';
import 'package:socialapp/features/group/domain/entities/group_post.dart';

abstract class GroupState {}

class GroupInitial extends GroupState {}

class GroupLoading extends GroupState {}

class GroupLoaded extends GroupState {
  final List<Group> groups;
  GroupLoaded(this.groups);
}

class AllGroupsLoaded extends GroupState {
  final List<Group> groups;
  AllGroupsLoaded(this.groups);
}

class GroupPostsLoaded extends GroupState {
  final List<GroupPost> posts;
  GroupPostsLoaded(this.posts);
}

class GroupCreated extends GroupState {}

class GroupDeleted extends GroupState {}

class GroupPostCreated extends GroupState {}

class GroupError extends GroupState {
  final String message;
  GroupError(this.message);
}