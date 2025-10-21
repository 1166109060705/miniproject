import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:socialapp/features/auth/presentation/components/my_text_field.dart';
import 'package:socialapp/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:socialapp/features/auth/domain/entities/app_user.dart';
import 'package:socialapp/features/group/presentation/cubits/group_cubit.dart';
import 'package:socialapp/features/group/presentation/cubits/group_states.dart';

class UploadGroupPostPage extends StatefulWidget {
  final String groupId;

  const UploadGroupPostPage({super.key, required this.groupId});

  @override
  State<UploadGroupPostPage> createState() => _UploadGroupPostPageState();
}

class _UploadGroupPostPageState extends State<UploadGroupPostPage> {
  PlatformFile? imagePickedFile;
  Uint8List? webImage;
  final descriptionController = TextEditingController();
  AppUser? currentUser;

  late final groupCubit = context.read<GroupCubit>();
  late final authCubit = context.read<AuthCubit>();

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  void getCurrentUser() async {
    final authCubit = context.read<AuthCubit>();
    currentUser = authCubit.currentUser;
  }

  Future<void> pickImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: kIsWeb,
    );

    if (result != null) {
      setState(() {
        imagePickedFile = result.files.first;
        if (kIsWeb) {
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

    if (currentUser != null) {
      try {
        // Upload post with image if selected
        if (imagePickedFile != null) {
          if (kIsWeb) {
            if (webImage == null) {
              throw Exception("Failed to load image");
            }
            // For web, we'll need to handle bytes differently or convert to temp file
            groupCubit.createGroupPost(
              groupId: widget.groupId,
              userId: currentUser!.uid,
              userName: currentUser!.name,
              text: text.isEmpty ? null : text,
              imagePath: imagePickedFile!.path,
            );
          } else {
            if (imagePickedFile!.path == null) {
              throw Exception("Failed to load image");
            }
            groupCubit.createGroupPost(
              groupId: widget.groupId,
              userId: currentUser!.uid,
              userName: currentUser!.name,
              text: text.isEmpty ? null : text,
              imagePath: imagePickedFile!.path,
            );
          }
        } else {
          // Text-only post
          groupCubit.createGroupPost(
            groupId: widget.groupId,
            userId: currentUser!.uid,
            userName: currentUser!.name,
            text: text,
            imagePath: null,
          );
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
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<GroupCubit, GroupState>(
      listener: (context, state) {
        if (state is GroupPostCreated) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Complete Create Post!')),
          );
        } else if (state is GroupError) {
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
            if (state is GroupLoading)
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
        title: const Text("Create Group Post"),
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
                  hintText: 'What\'s on your mind?',
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

  @override
  void dispose() {
    descriptionController.dispose();
    super.dispose();
  }
}