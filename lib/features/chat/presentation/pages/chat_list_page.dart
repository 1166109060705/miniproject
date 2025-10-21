import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:socialapp/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:socialapp/features/chat/presentation/cubits/chat_cubit.dart';
import 'package:socialapp/features/chat/presentation/pages/chat_page.dart';
import 'package:socialapp/features/profile/presentation/cubits/profile_cubit.dart';

class ChatListPage extends StatefulWidget {
  const ChatListPage({super.key});

  @override
  State<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  late final String currentUserId;
  late final ChatCubit chatCubit;
  late final ProfileCubit profileCubit;

  @override
  void initState() {
    super.initState();
    currentUserId = context.read<AuthCubit>().currentUser!.uid;
    chatCubit = context.read<ChatCubit>();
    profileCubit = context.read<ProfileCubit>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chats'),
      ),
      body: StreamBuilder<List<String>>(
        stream: chatCubit.getRecentChatUsers(currentUserId),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final userIds = snapshot.data!;
          if (userIds.isEmpty) {
            return const Center(child: Text('No chats yet'));
          }

          return ListView.builder(
            itemCount: userIds.length,
            itemBuilder: (context, index) {
              final userId = userIds[index];
              return FutureBuilder(
                future: profileCubit.getUserProfile(userId),
                builder: (context, userSnapshot) {
                  if (!userSnapshot.hasData) {
                    return const SizedBox();
                  }

                  final user = userSnapshot.data!;
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(user.profileImageUrl),
                    ),
                    title: Text(user.name),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatPage(receiver: user),
                        ),
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}