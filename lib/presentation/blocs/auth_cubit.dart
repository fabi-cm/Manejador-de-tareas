import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Definimos los estados
abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class Authenticated extends AuthState {
  final User user;
  final String role;
  Authenticated(this.user, this.role);
}

class Unauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
}

// AuthCubit
class AuthCubit extends Cubit<AuthState> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  AuthCubit() : super(AuthInitial());

  // Verificar usuario autenticado
  void checkAuthStatus() {
    User? user = _auth.currentUser;
    if (user != null) {
      _fetchUserRole(user);
    } else {
      emit(Unauthenticated());
    }
  }

  // Obtener rol del usuario
  Future<void> _fetchUserRole(User user) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        String role = doc['role'] ?? 'trabajador';
        emit(Authenticated(user, role));
      } else {
        emit(Unauthenticated());
      }
    } catch (e) {
      emit(AuthError("Error obteniendo rol: $e"));
    }
  }

  // Iniciar sesión
  Future<void> login(String email, String password) async {
    emit(AuthLoading());
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      _fetchUserRole(userCredential.user!);
    } catch (e) {
      emit(AuthError("Error en el login: $e"));
    }
  }

  // Cerrar sesión
  Future<void> logout() async {
    await _auth.signOut();
    emit(Unauthenticated());
  }
}