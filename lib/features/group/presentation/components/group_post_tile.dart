import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:socialapp/features/group/domain/entities/group_post.dart';
import 'package:socialapp/features/auth/presentation/components/my_text_field.dart';
import 'package:socialapp/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:socialapp/features/group/presentation/cubits/group_cubit.dart';
import 'package:socialapp/features/profile/presentation/pages/profile_page.dart';
import 'package:cached_network_image/cached_network_image.dart';

class GroupPostTile extends StatefulWidget {
  final GroupPost post;
  final VoidCallback? onDelete;
  final String groupId;

  const GroupPostTile({
    super.key,
    required this.post,
    this.onDelete,
    required this.groupId,
  });

  @override
  State<GroupPostTile> createState() => _GroupPostTileState();
}

class _GroupPostTileState extends State<GroupPostTile> {
  late final groupCubit = context.read<GroupCubit>();
  late final authCubit = context.read<AuthCubit>();
  final commentTextController = TextEditingController();

  bool get isOwnPost => widget.post.userId == authCubit.currentUser?.uid;
  bool get isLiked => widget.post.likes.contains(authCubit.currentUser?.uid);

  void toggleLike() {
    final userId = authCubit.currentUser?.uid;
    if (userId != null) {
      groupCubit.toggleLikeGroupPost(widget.post.id, userId, widget.groupId);
    }
  }

  void openCommentDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("เพิ่มความคิดเห็น"),
        content: MyTextField(
          controller: commentTextController,
          hintText: "พิมพ์ความคิดเห็น",
          obscureText: false,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("ยกเลิก"),
          ),
          TextButton(
            onPressed: () {
              addComment();
              Navigator.of(context).pop();
            },
            child: const Text("บันทึก"),
          ),
        ],
      ),
    );
  }

  void addComment() {
    if (commentTextController.text.isNotEmpty) {
      final currentUser = authCubit.currentUser;
      if (currentUser != null) {
        final newComment = {
          'id': DateTime.now().millisecondsSinceEpoch.toString(),
          'postId': widget.post.id,
          'userId': currentUser.uid,
          'userName': currentUser.email,
          'text': commentTextController.text,
          'timestamp': DateTime.now().toIso8601String(),
        };

        groupCubit.addCommentToGroupPost(
          widget.post.id,
          widget.groupId,
          newComment,
        );
        commentTextController.clear();
      }
    }
  }

  void showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("delete post"),
        content: const Text("Are you sure you want to delete this post?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("ยกเลิก"),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              if (widget.onDelete != null) {
                widget.onDelete!();
              }
            },
            child: const Text("delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.secondary,
      child: Column(
        children: [
          // Header
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProfilePage(
                  uid: widget.post.userId,
                ),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  // Profile Image
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.grey[300],
                    child: Text(
                      widget.post.userName.isNotEmpty 
                          ? widget.post.userName[0].toUpperCase()
                          : 'U',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // User name and timestamp
                  Text(
                    widget.post.userName,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.inversePrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _formatTimestamp(widget.post.timestamp),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 12,
                    ),
                  ),
                  const Spacer(),
                  // Options menu
                  if (isOwnPost || widget.onDelete != null)
                    PopupMenuButton<String>(
                      icon: Icon(
                        Icons.more_vert,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      onSelected: (value) {
                        if (value == 'delete') {
                          showDeleteDialog();
                        }
                      },
                      itemBuilder: (BuildContext context) => [
                        if (isOwnPost || widget.onDelete != null)
                          const PopupMenuItem<String>(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete, color: Colors.red),
                                SizedBox(width: 8),
                                Text('delete'),
                              ],
                            ),
                          ),
                      ],
                    ),
                ],
              ),
            ),
          ),          // Image content
          if (widget.post.imageUrl != null && widget.post.imageUrl!.isNotEmpty)
            CachedNetworkImage(
              imageUrl: widget.post.imageUrl!,
              height: 430,
              width: double.infinity,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                height: 430,
                color: Colors.grey[200],
                child: const Center(child: CircularProgressIndicator()),
              ),
              errorWidget: (context, url, error) => Container(
                height: 430,
                color: Colors.grey[200],
                child: const Center(child: Icon(Icons.error)),
              ),
            ),

          // Text content
          if (widget.post.text != null && widget.post.text!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  widget.post.text!,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.inversePrimary,
                  ),
                ),
              ),
            ),

          // Actions (Like, Comment)
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                // Like button
                SizedBox(
                  width: 60,
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: toggleLike,
                        child: Icon(
                          isLiked ? Icons.favorite : Icons.favorite_border,
                          color: isLiked 
                              ? Colors.red 
                              : Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        '${widget.post.likes.length}',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                // Comment button
                GestureDetector(
                  onTap: openCommentDialog,
                  child: Icon(
                    Icons.comment,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 5),
                Text(
                  '${widget.post.comments.length}',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          // Comments section
          if (widget.post.comments.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: widget.post.comments.take(3).map((comment) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: RichText(
                      text: TextSpan(
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.inversePrimary,
                        ),
                        children: [
                          TextSpan(
                            text: '${comment.userName}: ',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          TextSpan(text: comment.text),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    commentTextController.dispose();
    super.dispose();
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'now';
    }
  }
}