import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:socialapp/features/auth/data/firebase_auth_repo.dart';
import 'package:socialapp/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:socialapp/features/auth/presentation/cubits/auth_state.dart';
import 'package:socialapp/features/auth/presentation/pages/auth_page.dart';
import 'package:socialapp/features/home/presentation/pages/home_page.dart';
import 'package:socialapp/features/post/data/firebase_post_repo.dart';
import 'package:socialapp/features/post/presentation/cubits/post_cubit.dart';
import 'package:socialapp/features/profile/data/firebase_profile_repo.dart';
import 'package:socialapp/features/profile/presentation/cubits/profile_cubit.dart';
import 'package:socialapp/features/search/data/firebase_search_repo.dart';
import 'package:socialapp/features/search/presentation/cubits/search_cubit.dart';
import 'package:socialapp/features/storage/data/firebase_storage_repo.dart';
import 'package:socialapp/themes/theme_cubit.dart';
import 'package:socialapp/features/chat/data/firebase_chat_repo.dart';
import 'package:socialapp/features/chat/presentation/cubits/chat_cubit.dart';
import 'package:socialapp/features/group/data/firebase_group_repo.dart';
import 'package:socialapp/features/group/presentation/cubits/group_cubit.dart';



class MyApp extends StatelessWidget {
 
  final firebaseAuthRepo = FirebaseAuthRepo();

  final firebaseProfileRepo = FirebaseProfileRepo();

  final firebaseStorageRepo = FirebaseStorageRepo();

  final firebasePostRepo = FirebasePostRepo();

  final firebaseSearchRepo = FirebaseSearchRepo();

  final firebaseChatRepo = FirebaseChatRepo();

  final firebaseGroupRepo = FirebaseGroupRepo();

  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [

        BlocProvider<AuthCubit>(
          create: (context) => 
          AuthCubit(authRepo: firebaseAuthRepo)..checkAuth(),
        ),
 
        BlocProvider<ProfileCubit>(
          create: (context) => ProfileCubit(
            profileRepo: firebaseProfileRepo,
            storageRepo: firebaseStorageRepo,
            ),
          ),

        BlocProvider<PostCubit>(
          create: (context) => PostCubit(
            postRepo: firebasePostRepo,
            storageRepo: firebaseStorageRepo,
            ),
          ),

          BlocProvider<SearchCubit>(
            create: (context) => SearchCubit(searchRepo: firebaseSearchRepo),
          ),

          BlocProvider<ThemeCubit>(create: (context) => ThemeCubit()),

          BlocProvider<ChatCubit>(
            create: (context) => ChatCubit(chatRepo: firebaseChatRepo),
          ),

          BlocProvider<GroupCubit>(
            create: (context) => GroupCubit(
              groupRepo: firebaseGroupRepo,
              storageRepo: firebaseStorageRepo,
            ),
          ),
      ],

      child: BlocBuilder<ThemeCubit,ThemeData>(
        builder: (context, currentTheme) => MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: currentTheme,


        home: BlocConsumer<AuthCubit, AuthState>(
          builder: (context, authState) {
            print(authState);

            if (authState is Unauthenticated) {
              return const AuthPage();
            }

            if (authState is Authenticated) {
              return const HomePage();
            }
            //loading...
            else {
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }
          },
          listener: (context, state) {
            if (state is AuthError) {
              ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(state.message)));
            }
          },
        ),
      ),
        ));
  }
}