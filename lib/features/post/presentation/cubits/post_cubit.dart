import 'dart:typed_data';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:socialapp/features/post/domain/entities/comment.dart';
import 'package:socialapp/features/post/domain/entities/post.dart';
import 'package:socialapp/features/post/domain/entities/report.dart';
import 'package:socialapp/features/post/domain/repos/post_repo.dart';
import 'package:socialapp/features/post/presentation/cubits/post_states.dart';
import 'package:socialapp/features/storage/domain/storage_repo.dart';

class PostCubit extends Cubit<PostState>{
  final PostRepo postRepo;
  final StorageRepo storageRepo;

  PostCubit({
    required this.postRepo, 
    required this.storageRepo,
  }) : super(PostsInitial());

  Future<void> createPost(Post post,
      {String? imagePath, Uint8List? imageBytes}) async {
    String? imageUrl;

    try{
      if(imagePath != null) {
      emit(PostUploading());
      imageUrl = 
          await storageRepo.uploadPostImageMobile(imagePath, post.id);
    }

    else if (imageBytes != null) {
      emit(PostUploading());
      imageUrl = await storageRepo.uploadPostImageWeb(imageBytes, post.id);
    }

    final newPost = post.copyWith(imageUrl: imageUrl);

    postRepo.createPost(newPost);

    fetchAllPosts();
    }catch(e) {
      emit(PostsError("Failed to create posts: $e"));
    } 
  }

  Future<void> fetchAllPosts() async {
    try {
      emit(PostsLoading());
      final posts = await postRepo.fetchAllPosts();
      emit(PostsLoaded(posts));
    } catch (e) {
      emit(PostsError("Failed to fetch posts: $e"));
    }
  }

  Future<void> deletePost(String postId) async {
    try {
      await postRepo.deletePost(postId);
    } catch (e) {}
  }

  Future<void> toggleLikePost(String postId, String userId) async {
    try{

      await postRepo.toggleLikePost(postId, userId);
    } catch(e) {
      emit(PostsError("failed to toggle likes: $e"));
    }

  }

  Future<void> addcomment(String postId, Comment comment) async {
    try{
      await postRepo.addComment(postId, comment);

      await  fetchAllPosts();
    }catch (e){
      emit(PostsError("Failed to add comment: $e"));
    }
  }

  Future<void> deleteComment(String postId, String commentId) async {
    try{
      await postRepo.deleteComment(postId, commentId);
      await fetchAllPosts();
    } catch(e) {
      emit(PostsError("Failed to delete comment: $e"));
    }
  }

  Future<void> toggleDislikePost(String postId, String userId) async {
    try {
      await postRepo.toggleDislikePost(postId, userId);
    } catch(e) {
      emit(PostsError("Failed to toggle dislike: $e"));
    }
  }

  Future<void> reportPost(String postId, String reporterId, String reporterName, String reason, String? details) async {
    try {
      final report = Report(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        postId: postId,
        reporterId: reporterId,
        reporterName: reporterName,
        reason: reason,
        details: details,
        timestamp: DateTime.now(),
      );

      await postRepo.reportPost(report);
    } catch (e) {
      emit(PostsError("Failed to submit report: $e"));
      throw e;
    }
  }
}