import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../screens/login_screen.dart';

// Definimos los estados
abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class Authenticated extends AuthState {
  final User user;
  final String role;
  final String username;
  Authenticated(this.user, this.role, this.username);
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
  //final FirebaseAuth _auth;

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
        String username = doc['username'] ?? 'Otro';
        emit(Authenticated(user, role, username));
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
  Future<void> logout(BuildContext context) async {
    try {
      await _auth.signOut();
      emit(Unauthenticated()); // Emite el estado "No autenticado"

      // Redirigir a LoginScreen después de cerrar sesión
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => LoginScreen()),
      );
    } catch (e) {
      emit(AuthError("Error al cerrar sesión: $e")); // Emite un estado de error

      // Mostrar un mensaje de error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al cerrar sesión: $e")),
      );
    }
  }
}
