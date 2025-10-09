import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:socialapp/features/auth/domain/entities/app_user.dart';
import 'package:socialapp/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:socialapp/features/profile/presentation/components/bio_box.dart';
import 'package:socialapp/features/profile/presentation/cubits/profile_cubit.dart';
import 'package:socialapp/features/profile/presentation/cubits/profile_state.dart';
import 'package:socialapp/features/profile/presentation/pages/edit_profile_page.dart';

class ProfilePage extends StatefulWidget {
  final String uid;

  const ProfilePage({super.key, required this.uid});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  
  late final authCubit = context.read<AuthCubit>();
  late final profileCubit = context.read<ProfileCubit>();
  
  late AppUser? currentUser = authCubit.currentUser;

  @override
  void initState() {
    super.initState();
  
    profileCubit.fetchUserProfile(widget.uid);
  }



  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state){

        if (state is ProfileLoaded){
          final user = state.profileUser;


          return Scaffold(
          
           appBar: AppBar(
            title: Text(user.name),
            foregroundColor: Theme.of(context).colorScheme.primary,
            actions: [

              IconButton(
                onPressed:() => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditProfilePage(user: user,),
                    )),
                icon: const Icon(Icons.settings),
                )
            ],
          ),

            body: Column(
              children: [
              Text(
                user.email,
                style:
                 TextStyle(color: Theme.of(context).colorScheme.primary),
              ),
            
              const SizedBox(height: 25,),
            
              CachedNetworkImage(
              imageUrl: user.profileImageUrl,
              placeholder: (context, url) => 
              const CircularProgressIndicator(),

              errorWidget: (context, url, error) => Icon(
                Icons.person,
                size: 72,
                color: Theme.of(context).colorScheme.primary,
              ),

              imageBuilder: (context, imageProvider) =>Container(
                height: 120,
                width: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: imageProvider,
                    fit: BoxFit.cover,
                    ),
                ),
              ),
              ),
            
              const SizedBox(height: 25,),
            
              Padding(
                padding: const EdgeInsets.only(left: 25.0),
                child: Row(
                  children: [
                    Text(
                      "Bio",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary),
                    ),
                  ],
                ),
              ),
                        
              const SizedBox(height: 10),

              BioBox(text: user.bio),
                      
              Padding(
                padding: const EdgeInsets.only(left: 25.0, top: 25),
                child: Row(
                  children: [
                    Text(
                      "Posts",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary),
                    ),
                  ],
                ),
              ),
                    
              
            
            
            
            
            ],
            ),        

          );
        }

        else if (state is ProfileLoading){
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else {
          return const Center(child: Text("Not Profile Found.."),);

        }
      });
  }
}
