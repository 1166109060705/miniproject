
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:socialapp/features/auth/domain/entities/app_user.dart';
import 'package:socialapp/features/auth/domain/repos/auth_repo.dart';
import 'package:socialapp/features/auth/presentation/cubits/auth_state.dart';


class AuthCubit extends Cubit<AuthState> {
  final AuthRepo authRepo;
  AppUser? _currentUser;

  AuthCubit({required this.authRepo}) : super(AuthInitial());

  void checkAuth() async {
    final AppUser? user = await authRepo.getCurrentUser();

  if (user != null) {
    _currentUser = user;
    emit(Authenticated(user));
  } else {
    emit(Unauthenticated());
  }
} 

  AppUser? get currentUser => _currentUser;

  Future<void> login(String email, String pw) async {
    try{
      emit(AuthLoading());
      final user = await authRepo.loginwithEmailPassword(email, pw);

      if (user != null) {
        _currentUser = user;
        emit(Authenticated(user));
      } else {
        emit(Unauthenticated());
      }
    } catch(e){
      emit(AuthError(e.toString()));
      emit(Unauthenticated());
    }

  }

  Future<void> register(String name,String email, String pw) async {
    try{
      emit(AuthLoading());
      final user = await authRepo.registerwithEmailPassword(name,email, pw);

      if (user != null) {
        _currentUser = user;
        emit(Authenticated(user));
      } else { 
        emit(Unauthenticated());
      }
    } catch(e){
      emit(AuthError(e.toString()));
      emit(Unauthenticated());
    }

  }

  Future<void> logout() async {
   authRepo.logout();
    emit(Unauthenticated());
  }

}