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

  final textController = TextEditingController();

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

  void uploadPost() {
    if(imagePickedFile == null || textController.text.isEmpty){
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please provide both image and caption")));
      return;
    }

    final newPost = Post(
      id: DateTime.now().millisecondsSinceEpoch.toString(), 
      userId: currentUser!.uid, 
      userName: currentUser!.name, 
      text: textController.text, 
      imageUrl: '', 
      timestamp: DateTime.now(),
      likes: [],
      );

    final postCubit = context.read<PostCubit>();

    if (kIsWeb) {
      postCubit.createPost(
        newPost, 
        imageBytes: imagePickedFile?.bytes
        );
    } else {
      postCubit.createPost(
        newPost, 
        imagePath: imagePickedFile?.path
        );

    }
  }

  @override 
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return BlocConsumer<PostCubit, PostState>(
      builder: (context, state){
        print(state);

        if (state is PostsLoading || state is PostUploading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

          return buildUploadPage();

      }, 
      listener: (context, state) {
        if (state is PostsLoaded){
          Navigator.pop(context);
        }


      },
      );
  }

  Widget buildUploadPage(){
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create New Post"),
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        actions: [
          IconButton(
            onPressed: uploadPost, 
            icon: const Icon(Icons.upload),)
        ],
      ),

      body:  Center(
        child: Column(
          children: [
            if (kIsWeb && webImage != null)
              Image.memory(webImage!),

            if (!kIsWeb && imagePickedFile != null)
              Image.file(File(imagePickedFile!.path!)),

            MaterialButton(
              onPressed: pickImage, 
              color: Colors.blue,
              child: const Text("Pick Image"),
              ),

            MyTextField(
              controller: textController, 
              hintText: "caption", 
              obscureText: false),


          ],
        ),
      ),
    );
  }
}