import 'package:flutter/material.dart';
import 'package:socialapp/features/auth/presentation/components/my_button.dart';
import 'package:socialapp/features/auth/presentation/components/my_text_field.dart';
import 'package:socialapp/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


class LoginPage extends StatefulWidget {
  final void Function()? togglePages;

  const LoginPage({super.key, required this.togglePages,});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  final emailController = TextEditingController();
  final pwController = TextEditingController();

  void login(){
    final String email = emailController.text;
    final String pw = pwController.text;

    final authCubit = context.read<AuthCubit>();

    if (email.isNotEmpty && pw.isNotEmpty) {
      authCubit.login(email, pw);
    } else {
        ScaffoldMessenger.of(context).showSnackBar(
         const SnackBar(
           content: Text("Please fill all the fields"),
        ),
      );
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    pwController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: SafeArea(
        child: Center(
          child:Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
              Icon(
                Icons.lock_open_rounded,
                size: 80,
                color: Theme.of(context).colorScheme.primary,
              ),
            
              const SizedBox(height: 45),
            
              Text(
                "Login Page",
                style: TextStyle(
                  fontSize: 20,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            
              const SizedBox(height: 25),
            
              MyTextField(
                controller: emailController,
                hintText: "Email",
                obscureText: false,
              ),
            
              const SizedBox(height: 10),

              MyTextField(
                controller: pwController,
                hintText: "Password",
                obscureText: true,
              ),
            
              const SizedBox(height: 25),

              MyButton(onTap: login,
               text: "Login"),

               const SizedBox(height: 50),

               Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                 children: [
                   Text("Not a member? "
                    , style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                    )
                   ,),
                   GestureDetector(
                    onTap: widget.togglePages,
                     child: Text("Register now"
                      , style: TextStyle(
                        color: Theme.of(context).colorScheme.inversePrimary,
                        fontWeight: FontWeight.bold
                      )
                     ,),
                   ),
                 ],
               )
            
            
            
            
            
            
            
            
            ],
          ),
        ),
      ),
    ),
  );
  }
}
