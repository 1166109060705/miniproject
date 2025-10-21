import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:socialapp/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:socialapp/features/group/domain/entities/group.dart';
import 'package:socialapp/features/group/presentation/components/group_tile.dart';
import 'package:socialapp/features/group/presentation/cubits/group_cubit.dart';
import 'package:socialapp/features/group/presentation/cubits/group_states.dart';
import 'package:socialapp/features/group/presentation/pages/create_group_page.dart';
import 'package:socialapp/features/group/presentation/pages/group_detail_page.dart';

class GroupListPage extends StatefulWidget {
  const GroupListPage({super.key});

  @override
  State<GroupListPage> createState() => _GroupListPageState();
}

class _GroupListPageState extends State<GroupListPage> with SingleTickerProviderStateMixin {
  late final groupCubit = context.read<GroupCubit>();
  late final authCubit = context.read<AuthCubit>();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadInitialData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadInitialData() {
    final currentUser = authCubit.currentUser;
    if (currentUser != null) {
      groupCubit.fetchUserGroups(currentUser.uid);
    }
  }

  void goToCreateGroupPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreateGroupPage()),
    ).then((_) => _refreshCurrentTab());
  }

  void goToGroupDetailPage(Group group) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GroupDetailPage(group: group),
      ),
    );
  }

  void _refreshCurrentTab() {
    final currentUser = authCubit.currentUser;
    if (currentUser != null) {
      if (_tabController.index == 0) {
        groupCubit.fetchUserGroups(currentUser.uid);
      } else {
        groupCubit.fetchAllGroups();
      }
    }
  }

  void _onJoinGroup(Group group) async {
    final currentUser = authCubit.currentUser;
    if (currentUser != null) {
      await groupCubit.joinGroup(group.id, currentUser.uid, currentUser.name);
      _refreshCurrentTab();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Groups'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: goToCreateGroupPage,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: "My Groups"),
            Tab(text: "All Groups"),
          ],
          onTap: (index) {
            final currentUser = authCubit.currentUser;
            if (currentUser != null) {
              if (index == 0) {
                groupCubit.fetchUserGroups(currentUser.uid);
              } else {
                groupCubit.fetchAllGroups();
              }
            }
          },
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildMyGroupsTab(),
          _buildAllGroupsTab(),
        ],
      ),
    );
  }

  Widget _buildMyGroupsTab() {
    return BlocConsumer<GroupCubit, GroupState>(
      listener: (context, state) {
        if (state is GroupError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      builder: (context, state) {
        if (state is GroupLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is GroupLoaded) {
          final groups = state.groups;

          if (groups.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.group, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No groups joined yet',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Create a new group or join an existing one!',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              final currentUser = authCubit.currentUser;
              if (currentUser != null) {
                groupCubit.fetchUserGroups(currentUser.uid);
              }
            },
            child: ListView.builder(
              itemCount: groups.length,
              itemBuilder: (context, index) {
                final group = groups[index];
                return GroupTile(
                  group: group,
                  onTap: () => goToGroupDetailPage(group),
                  showJoinButton: false, 
                );
              },
            ),
          );
        }

        return const Center(child: Text('My Groups'));
      },
    );
  }

  Widget _buildAllGroupsTab() {
    return BlocConsumer<GroupCubit, GroupState>(
      listener: (context, state) {
        if (state is GroupError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      builder: (context, state) {
        if (state is GroupLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is AllGroupsLoaded) {
          final allGroups = state.groups;

          if (allGroups.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.public, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No groups yet',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Be the first to create a group!',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              groupCubit.fetchAllGroups();
            },
            child: ListView.builder(
              itemCount: allGroups.length,
              itemBuilder: (context, index) {
                final group = allGroups[index];
                final currentUser = authCubit.currentUser;
                final isAlreadyMember = currentUser != null && 
                    group.memberIds.contains(currentUser.uid);
                
                return GroupTile(
                  group: group,
                  onTap: isAlreadyMember ? () => goToGroupDetailPage(group) : null,
                  showJoinButton: !isAlreadyMember,
                  onJoin: () => _onJoinGroup(group),
                );
              },
            ),
          );
        }

        return const Center(child: Text('All Groups'));
      },
    );
  }
}