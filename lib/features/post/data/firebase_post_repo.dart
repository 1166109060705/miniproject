import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:socialapp/features/post/domain/entities/comment.dart';
import 'package:socialapp/features/post/domain/entities/post.dart';
import 'package:socialapp/features/post/domain/entities/report.dart';
import 'package:socialapp/features/post/domain/repos/post_repo.dart';

class FirebasePostRepo implements PostRepo{
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  final CollectionReference postsCollection = 
    FirebaseFirestore.instance.collection('posts');
  
  final CollectionReference reportsCollection = 
    FirebaseFirestore.instance.collection('reports');

  @override
  Future<void> createPost(Post post) async{
    try {

      await postsCollection.doc(post.id).set(post.toJson());
    }catch (e) {
      throw Exception('Error creating post: $e');
    }
  }

  @override
  Future<void> deletePost(String postId) async{
    await postsCollection.doc(postId).delete(); 
  }

  @override
  Future<List<Post>> fetchAllPosts() async{
    try{

      final postsSnapshot = 
        await postsCollection.orderBy('timestamp', descending: true).get();

      final List<Post> allPosts = postsSnapshot.docs
        .map((doc) => Post.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
      
      return allPosts;
    }catch(e){
      throw Exception('Error fetching posts: $e');

    }
    }

  @override
  Future<List<Post>> fetchPostsByUserId(String userId) async{
    try{

      final postsSnapshot = 
            await postsCollection.where('userId', isEqualTo: userId).get();
       
      final userPosts = postsSnapshot.docs
        .map((doc) => Post.fromJson(doc.data() as Map<String, dynamic>))
        .toList();

      return userPosts;
    }catch(e){
      throw Exception('Error fetching user posts: $e');
    }
  }

  @override
  Future<void> toggleLikePost(String postId, String userId) async{
    try {
      final postDoc = await postsCollection.doc(postId).get();
      if (postDoc.exists){
        final post = Post.fromJson(postDoc.data() as Map<String, dynamic>);

        final hasLiked = post.likes.contains(userId);

        if (hasLiked) {
          post.likes.remove(userId);
        } else {
          post.likes.add(userId);
          post.dislikes.remove(userId); // Remove dislike if exists
        }

        await postsCollection.doc(postId).update({
          'likes': post.likes,
          'dislikes': post.dislikes,
          });
        } else {
          throw Exception("Post not found");
        }
    } catch (e) {
      throw Exception("Error toggling like: $e");
    }
  }

  @override
  Future<void> toggleDislikePost(String postId, String userId) async {
    try {
      final postDoc = await postsCollection.doc(postId).get();

      if (postDoc.exists) {
        final post = Post.fromJson(postDoc.data() as Map<String, dynamic>);

        final hasDisliked = post.dislikes.contains(userId);

        if (hasDisliked) {
          post.dislikes.remove(userId);
        } else {
          post.dislikes.add(userId);
          post.likes.remove(userId); // Remove like if exists
        }

        await postsCollection.doc(postId).update({
          'likes': post.likes,
          'dislikes': post.dislikes,
        });
      } else {
        throw Exception("Post not found");
      }
    } catch (e) {
      throw Exception("Error toggling dislike: $e");
    }
  }

  @override
  Future<void> addComment(String postId, Comment comment) async{
    try{

      final postDoc = await postsCollection.doc(postId).get();

      if (postDoc.exists) {

        final post = Post.fromJson(postDoc.data() as Map<String, dynamic>);

        post.comments.add(comment);

        await postsCollection.doc(postId).update({
          'comments': post.comments.map((comment) => comment.toJson()).toList()
        });
      }else {
        throw Exception("Post mot found");
      }
    } catch(e){
      throw Exception("Error adding comment: $e");
    }
  }

  @override
  Future<void> deleteComment(String postId, String commentId) async{
   try{

      final postDoc = await postsCollection.doc(postId).get();

      if (postDoc.exists) {

        final post = Post.fromJson(postDoc.data() as Map<String, dynamic>);

        post.comments.removeWhere((comment) => comment.id == commentId);

        await postsCollection.doc(postId).update({
          'comments': post.comments.map((comment) => comment.toJson()).toList()
        });
      }else {
        throw Exception("Post mot found");
      }
    } catch(e){
      throw Exception("Error deleting comment: $e");
    }
  }

  @override
  Future<void> reportPost(Report report) async {
    try {
      await reportsCollection.doc(report.id).set(report.toJson());
    } catch (e) {
      throw Exception('Error reporting post: $e');
    }
  }
}