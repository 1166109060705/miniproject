import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:socialapp/features/auth/domain/entities/app_user.dart';
import 'package:socialapp/features/auth/presentation/components/my_text_field.dart';
import 'package:socialapp/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:socialapp/features/post/domain/entities/post.dart';
import 'package:socialapp/features/post/presentation/cubits/post_cubit.dart';
import 'package:socialapp/features/post/presentation/cubits/post_states.dart';

class UploadPostPage extends StatefulWidget {
  const UploadPostPage({super.key});

  @override
  State<UploadPostPage> createState() => _UploadPostPageState();
}

class _UploadPostPageState extends State<UploadPostPage> {

  PlatformFile? imagePickedFile;

  Uint8List? webImage;

  final descriptionController = TextEditingController();

  AppUser? currentUser;

  @override
 void initState() {
    super.initState();

    getCurrentUser();
  }

  void getCurrentUser() async {
    final authCubit = context.read<AuthCubit>();
    currentUser = authCubit.currentUser;
  }

  Future<void> pickImage() async{
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: kIsWeb,
    );
  
    if(result != null){
      setState(() {
        imagePickedFile = result.files.first;
        if(kIsWeb){
          webImage = imagePickedFile!.bytes;
        }
      });
    }
  }

  Future<void> uploadPost() async {
    final text = descriptionController.text.trim();
    
    // Validate input
    if (imagePickedFile == null && text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please provide either an image or caption"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      // Create post entity
      final newPost = Post(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: currentUser!.uid,
        userName: currentUser!.name,
        text: text,
        imageUrl: '',
        timestamp: DateTime.now(),
        likes: [],
        dislikes: [],
        comments: [],
      );

      final postCubit = context.read<PostCubit>();

      // Upload post with image if selected
      if (imagePickedFile != null) {
        if (kIsWeb) {
          if (webImage == null) {
            throw Exception("Failed to load image");
          }
          await postCubit.createPost(newPost, imageBytes: webImage);
        } else {
          if (imagePickedFile!.path == null) {
            throw Exception("Failed to load image");
          }
          await postCubit.createPost(newPost, imagePath: imagePickedFile!.path);
        }
      } else {
        // Text-only post
        await postCubit.createPost(newPost);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to create post: ${e.toString()}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override 
  void dispose() {
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return BlocConsumer<PostCubit, PostState>(
      listener: (context, state) {
        if (state is PostsLoaded) {
          Navigator.pop(context);
        } else if (state is PostsError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        return Stack(
          children: [
            buildUploadPage(),
            if (state is PostsLoading || state is PostUploading)
              Container(
                color: Colors.black.withOpacity(0.5),
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget buildUploadPage() {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create New Post"),
        actions: [
          TextButton.icon(
            onPressed: uploadPost,
            icon: const Icon(Icons.send),
            label: const Text("Post"),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Caption TextField
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: MyTextField(
                  controller: descriptionController,
                  hintText: 'Write a caption...',
                  obscureText: false,
                  maxLines: 5,
                  keyboardType: TextInputType.multiline,
                ),
              ),
              const SizedBox(height: 16),
              
              // Image Preview
              if (imagePickedFile != null)
                Container(
                  constraints: const BoxConstraints(maxHeight: 300),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: kIsWeb 
                      ? Image.memory(
                          webImage!,
                          fit: BoxFit.cover,
                        )
                      : Image.file(
                          File(imagePickedFile!.path!),
                          fit: BoxFit.cover,
                        ),
                  ),
                ),
              
              const SizedBox(height: 16),
              
              // Image Picker Button
              Center(
                child: MaterialButton(
                  onPressed: pickImage,
                  color: Theme.of(context).colorScheme.primary,
                  textColor: Theme.of(context).colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        imagePickedFile == null 
                          ? Icons.add_photo_alternate
                          : Icons.edit,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        imagePickedFile == null
                          ? "Add Photo"
                          : "Change Photo",
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}