import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:socialapp/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:socialapp/features/group/domain/entities/group.dart';
import 'package:socialapp/features/group/presentation/components/group_post_tile.dart';
import 'package:socialapp/features/group/presentation/cubits/group_cubit.dart';
import 'package:socialapp/features/group/presentation/cubits/group_states.dart';
import 'package:socialapp/features/group/presentation/pages/upload_group_post_page.dart';
import 'package:socialapp/features/group/presentation/pages/group_list_page.dart';
import 'package:socialapp/features/group/presentation/pages/edit_group_page.dart';
import 'package:socialapp/features/profile/presentation/cubits/profile_cubit.dart';
import 'package:socialapp/features/profile/domain/entities/profile_user.dart';

class GroupDetailPage extends StatefulWidget {
  final Group group;

  const GroupDetailPage({super.key, required this.group});

  @override
  State<GroupDetailPage> createState() => _GroupDetailPageState();
}

class _GroupDetailPageState extends State<GroupDetailPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late final groupCubit = context.read<GroupCubit>();
  late final authCubit = context.read<AuthCubit>();
  late final profileCubit = context.read<ProfileCubit>();
  late Group currentGroup;
  Map<String, ProfileUser> memberProfiles = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    currentGroup = widget.group;
    fetchGroupPosts();
    fetchMemberProfiles();
  }

  Future<void> fetchMemberProfiles() async {
    final profiles = <String, ProfileUser>{};
    
    for (String memberId in currentGroup.memberIds) {
      try {
        final profile = await profileCubit.getUserProfile(memberId);
        if (profile != null) {
          profiles[memberId] = profile;
        }
      } catch (e) {
        print('Error fetching profile for $memberId: $e');
      }
    }
    
    if (mounted) {
      setState(() {
        memberProfiles = profiles;
      });
    }
  }

  void fetchGroupPosts() {
    groupCubit.fetchGroupPosts(currentGroup.id);
  }

  void goToUploadPostPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UploadGroupPostPage(groupId: currentGroup.id),
      ),
    ).then((_) => fetchGroupPosts());
  }

  bool get isCurrentUserMember {
    final currentUser = authCubit.currentUser;
    if (currentUser == null) return false;
    return currentGroup.memberIds.contains(currentUser.uid);
  }

  bool get isCurrentUserAdmin {
    final currentUser = authCubit.currentUser;
    if (currentUser == null) return false;
    return currentGroup.adminId == currentUser.uid;
  }

  void joinGroup() {
    final currentUser = authCubit.currentUser;
    if (currentUser != null) {
      groupCubit.joinGroup(currentGroup.id, currentUser.uid, currentUser.name);
      // รีเฟรชข้อมูล profile หลังเข้าร่วมกลุ่ม
      Future.delayed(const Duration(milliseconds: 500), () {
        fetchMemberProfiles();
      });
    }
  }

  void leaveGroup() {
    final currentUser = authCubit.currentUser;
    if (currentUser != null) {
      groupCubit.leaveGroup(currentGroup.id, currentUser.uid, currentUser.name);
      // รีเฟรชข้อมูล profile หลังออกจากกลุ่ม
      Future.delayed(const Duration(milliseconds: 500), () {
        fetchMemberProfiles();
      });
    }
  }

  void _showDeleteGroupDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Delete Group',
            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Are you sure you want to delete "${currentGroup.name}"?'),
              const SizedBox(height: 12),
              const Text(
                'This action cannot be undone. All posts and member data will be permanently deleted.',
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteGroup();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _deleteGroup() {
    final currentUser = authCubit.currentUser;
    if (currentUser != null) {
      groupCubit.deleteGroup(currentGroup.id, currentUser.uid);
    }
  }

  void _showEditGroupDialog() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditGroupPage(group: currentGroup),
      ),
    ).then((isUpdated) {
      if (isUpdated == true) {
        // รีเฟรชข้อมูลกลุ่มเมื่อแก้ไขสำเร็จ
        final currentUser = authCubit.currentUser;
        if (currentUser != null) {
          groupCubit.fetchUserGroups(currentUser.uid);
        }
        // รีเฟรชข้อมูล profile ของสมาชิก
        fetchMemberProfiles();
        setState(() {
          // รีเฟรชหน้า - ข้อมูลจะถูกอัปเดตผ่าน BlocListener
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<GroupCubit, GroupState>(
      listener: (context, state) {
        if (state is GroupLoaded) {
          setState(() {
            currentGroup = widget.group;
          });
        }
      },
      child: Scaffold(
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 200,
              pinned: true,
              actions: isCurrentUserAdmin ? [
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') {
                      _showEditGroupDialog();
                    } else if (value == 'delete') {
                      _showDeleteGroupDialog();
                    }
                  },
                  itemBuilder: (BuildContext context) => [
                    const PopupMenuItem<String>(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, color: Colors.blue),
                          SizedBox(width: 8),
                          Text('Edit Group'),
                        ],
                      ),
                    ),
                    const PopupMenuItem<String>(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: Colors.red),
                          SizedBox(width: 8),
                          Text(
                            'Delete Group',
                            style: TextStyle(color: Colors.red),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ] : null,
              flexibleSpace: FlexibleSpaceBar(
                title: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        currentGroup.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(
                              offset: Offset(1, 1),
                              blurRadius: 3,
                              color: Colors.black45,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                background: Container(
                  decoration: BoxDecoration(
                    image: currentGroup.imageUrl != null
                        ? DecorationImage(
                            image: NetworkImage(currentGroup.imageUrl!),
                            fit: BoxFit.cover,
                          )
                        : null,
                    gradient: currentGroup.imageUrl == null
                        ? LinearGradient(
                            colors: [Colors.blue.shade400, Colors.blue.shade600],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : null,
                  ),
                ),
              ),
            ),
          ];
        },
        body: Column(
          children: [
            // Group Info
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (currentGroup.description.isNotEmpty)
                    Text(
                      currentGroup.description,
                      style: const TextStyle(fontSize: 16),
                    ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.people, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        '${currentGroup.memberIds.length} members',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      const Spacer(),
                      if (!isCurrentUserMember)
                        ElevatedButton(
                          onPressed: joinGroup,
                          child: const Text('join Group'),
                        )
                      else if (!isCurrentUserAdmin)
                        OutlinedButton(
                          onPressed: leaveGroup,
                          child: const Text('Leave Group'),
                        ),
                    ],
                  ),
                ],
              ),
            ),

            // Tabs
            TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'Posts'),
                Tab(text: 'Members'),
              ],
            ),

            // Tab Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Posts Tab
                  BlocConsumer<GroupCubit, GroupState>(
                    listener: (context, state) {
                      if (state is GroupDeleted) {
                        // นำทางไปหน้า GroupListPage โดยลบ history stack ทั้งหมด
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                            builder: (context) => const GroupListPage(),
                          ),
                          (route) => false,
                        );
                        // แสดงข้อความหลังจากไปถึงหน้าใหม่แล้ว
                        Future.delayed(const Duration(milliseconds: 500), () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Group deleted successfully'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        });
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
                      if (state is GroupLoading) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (state is GroupPostsLoaded) {
                        final posts = state.posts;

                        if (posts.isEmpty) {
                          return const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.post_add, size: 64, color: Colors.grey),
                                SizedBox(height: 16),
                                Text(
                                  'No posts yet',
                                  style: TextStyle(fontSize: 18, color: Colors.grey),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Be the first to post in this group!',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          );
                        }

                        return RefreshIndicator(
                          onRefresh: () async {
                            fetchGroupPosts();
                          },
                          child: ListView.builder(
                            itemCount: posts.length,
                            itemBuilder: (context, index) {
                              final post = posts[index];
                              return GroupPostTile(
                                post: post,
                                groupId: widget.group.id,
                                onDelete: isCurrentUserAdmin ||
                                        post.userId == authCubit.currentUser?.uid
                                    ? () => groupCubit.deleteGroupPost(
                                        post.id, widget.group.id)
                                    : null,
                              );
                            },
                          ),
                        );
                      }

                      return const Center(child: Text('Something went wrong'));
                    },
                  ),

                  // Members Tab
                  Container(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Text(
                          'Members (${currentGroup.memberNames.length})',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: ListView.builder(
                            itemCount: currentGroup.memberNames.length,
                            itemBuilder: (context, index) {
                              // สร้าง list ที่รวม index, memberId, และ memberName
                              final memberData = List.generate(currentGroup.memberNames.length, (i) {
                                return {
                                  'index': i,
                                  'id': currentGroup.memberIds[i],
                                  'name': currentGroup.memberNames[i],
                                };
                              });
                              
                              // จัดเรียงให้ Admin อยู่ด้านบน
                              memberData.sort((a, b) {
                                if (a['id'] == currentGroup.adminId) return -1;
                                if (b['id'] == currentGroup.adminId) return 1;
                                return 0;
                              });
                              
                              final memberInfo = memberData[index];
                              final memberId = memberInfo['id'] as String;
                              final memberName = memberInfo['name'] as String;
                              final isAdmin = memberId == currentGroup.adminId;

                              // ใช้ข้อมูลจาก profile ถ้ามี ถ้าไม่มีใช้ชื่อจาก memberNames
                              final profile = memberProfiles[memberId];
                              final displayName = profile?.name ?? (memberName.isNotEmpty ? memberName : 'Unknown User');
                              final profileImageUrl = profile?.profileImageUrl;
                              
                              return ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: isAdmin ? Colors.orange : Colors.blue,
                                  backgroundImage: profileImageUrl != null && profileImageUrl.isNotEmpty
                                      ? NetworkImage(profileImageUrl)
                                      : null,
                                  child: profileImageUrl == null || profileImageUrl.isEmpty
                                      ? Text(
                                          displayName.isNotEmpty 
                                              ? displayName.substring(0, 1).toUpperCase()
                                              : 'U',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        )
                                      : null,
                                ),
                                title: Text(
                                  displayName,
                                  style: TextStyle(
                                    fontWeight: isAdmin ? FontWeight.bold : FontWeight.normal,
                                  ),
                                ),
                                subtitle: isAdmin ? const Text(
                                  'Group Admin',
                                  style: TextStyle(
                                    color: Colors.orange,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ) : Text(
                                  'Member',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                                trailing: isAdmin
                                    ? Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.orange,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: const Text(
                                          'Admin',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      )
                                    : const Icon(
                                        Icons.person,
                                        color: Colors.grey,
                                        size: 20,
                                      ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: isCurrentUserMember
          ? BlocBuilder<GroupCubit, GroupState>(
              builder: (context, state) {
                // ซ่อน FAB ถ้ากำลังลบกลุ่ม
                if (state is GroupLoading) {
                  return const SizedBox.shrink();
                }
                return FloatingActionButton(
                  onPressed: goToUploadPostPage,
                  child: const Icon(Icons.add),
                );
              },
            )
          : null,
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}