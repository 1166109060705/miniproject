import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:socialapp/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:socialapp/features/group/domain/entities/group.dart';
import 'package:socialapp/features/group/presentation/cubits/group_cubit.dart';
import 'package:socialapp/features/group/presentation/cubits/group_states.dart';

class EditGroupPage extends StatefulWidget {
  final Group group;

  const EditGroupPage({super.key, required this.group});

  @override
  State<EditGroupPage> createState() => _EditGroupPageState();
}

class _EditGroupPageState extends State<EditGroupPage> {
  late TextEditingController nameController;
  late TextEditingController descriptionController;
  PlatformFile? selectedImage;
  bool hasImageChanged = false;

  late final groupCubit = context.read<GroupCubit>();
  late final authCubit = context.read<AuthCubit>();

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.group.name);
    descriptionController = TextEditingController(text: widget.group.description);
  }

  void pickImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        selectedImage = result.files.single;
        hasImageChanged = true;
      });
    }
  }

  void updateGroup() {
    final name = nameController.text.trim();
    final description = descriptionController.text.trim();
    final currentUser = authCubit.currentUser;

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Group Name is required')),
      );
      return;
    }

    if (currentUser != null) {
      final updatedGroup = widget.group.copyWith(
        name: name,
        description: description,
      );

      groupCubit.updateGroup(
        updatedGroup,
        newImagePath: hasImageChanged ? selectedImage?.path : null,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Group'),
        actions: [
          TextButton.icon(
            onPressed: updateGroup,
            icon: const Icon(Icons.save),
            label: const Text('Save'),
          ),
        ],
      ),
      body: BlocListener<GroupCubit, GroupState>(
        listener: (context, state) {
          if (state is GroupLoaded) {
            Navigator.pop(context, true); // ส่งค่า true กลับเพื่อบอกว่าอัพเดตสำเร็จ
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('complete Update group!')),
            );
          } else if (state is GroupError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Group Image
              Center(
                child: GestureDetector(
                  onTap: pickImage,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey[200],
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Stack(
                      children: [
                        // แสดงรูปที่เลือกใหม่หรือรูปเดิม
                        if (selectedImage != null && selectedImage!.path != null)
                          ClipOval(
                            child: Image.file(
                              File(selectedImage!.path!),
                              width: 120,
                              height: 120,
                              fit: BoxFit.cover,
                            ),
                          )
                        else if (widget.group.imageUrl != null)
                          ClipOval(
                            child: Image.network(
                              widget.group.imageUrl!,
                              width: 120,
                              height: 120,
                              fit: BoxFit.cover,
                            ),
                          )
                        else
                          Icon(
                            Icons.camera_alt,
                            size: 40,
                            color: Colors.grey[600],
                          ),
                        
                        // Overlay สำหรับแสดงไอคอนแก้ไข
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.blue,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.edit,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Center(
                child: Text(
                  'Select Group Picture',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ),

              const SizedBox(height: 32),

              // Group Name
              const Text(
                'Group Name *',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  hintText: 'Enter group name',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 24),

              // Group Description
              const Text(
                'Group Description',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Description (optional)',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 32),

              // Update Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: updateGroup,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  child: BlocBuilder<GroupCubit, GroupState>(
                    builder: (context, state) {
                      if (state is GroupLoading) {
                        return const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        );
                      }
                      return const Text(
                        'Save Changes',
                        style: TextStyle(fontSize: 16),
                      );
                    },
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
    nameController.dispose();
    descriptionController.dispose();
    super.dispose();
  }
}