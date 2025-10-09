import 'package:socialapp/features/auth/domain/entities/app_user.dart';

abstract class AuthRepo {
  Future<AppUser?> loginwithEmailPassword(String email, String password);
  Future<AppUser?> registerwithEmailPassword(String name,String email, String password);
  Future<void> logout();
  Future<AppUser?> getCurrentUser();
}