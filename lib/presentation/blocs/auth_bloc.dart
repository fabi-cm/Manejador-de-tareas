import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/sign_in_with_google.dart';

class AuthState {
  final UserEntity? user;
  final bool isLoading;
  final String? error;

  AuthState({this.user, this.isLoading = false, this.error});
}

class AuthCubit extends Cubit<AuthState> {
  final SignInWithGoogle signInWithGoogle;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  AuthCubit(this.signInWithGoogle) : super(AuthState());

  Future<void> login() async {
    emit(AuthState(isLoading: true));
    try {
      final user = await signInWithGoogle();
      emit(AuthState(user: user));
      if (user != null) {
        // Obtener datos del usuario desde Firestore
        final userDoc = await _db.collection('users').doc(user.uid).get();
        if (userDoc.exists) {
          final userData = userDoc.data();
          final updatedUser = UserEntity(
            uid: user.uid,
            name: user.name,
            email: user.email,
            role: userData?['role'] ?? 'trabajador', // Asignar rol
            assignedTasks: List<String>.from(userData?['assigned_tasks'] ?? []),
          );
          emit(AuthState(user: updatedUser));
        }
      }
    } catch (e) {
      emit(AuthState(error: "Error al iniciar sesión"));
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    emit(AuthState()); // Limpiar el estado después de cerrar sesión
  }
}