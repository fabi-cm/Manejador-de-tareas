import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../main.dart';
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

// Definimos los roles
enum Role {
  trabajador,
  administrador,
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
      saveFCMToken(user.uid);
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
        await saveFCMToken(user.uid);
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

      await saveFCMToken(userCredential.user!.uid);
    } catch (e) {
      emit(AuthError("Error en el login: $e"));
    }
  }

  Future<void> registerUserAsAdmin(String email, String password, String username) async {
    try {
      // Crear usuario en Firebase Auth (sin cambiar sesión)
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Guardar usuario en Firestore con su rol
      await _firestore.collection("users").doc(userCredential.user!.uid).set({
        "uid": userCredential.user!.uid,
        "email": email,
        "username": username,
        "role": "trabajador", // Cambiar si es necesario
      });

      // ✅ Mostrar mensaje sin afectar sesión del admin
      ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
        SnackBar(
          content: Text("$username registrado exitosamente"),
          backgroundColor: Colors.green,
        ),
      );

      // ✅ Cerrar el diálogo sin cerrar sesión
      Navigator.pop(navigatorKey.currentContext!);
    } catch (e) {
      emit(AuthError("Error en el registro: ${e.toString()}"));
    }
  }

  Future<void> saveFCMToken(String userId) async {
    try {
      String? token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        print("FCM Token: $token"); // Verifica que el token se obtenga correctamente
        await FirebaseFirestore.instance.collection('users').doc(userId).update({
          'fcmToken': token,
        });

        FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
          print("New FCM Token: $newToken"); // Verifica que el token se actualice correctamente
          FirebaseFirestore.instance.collection('users').doc(userId).update({
            'fcmToken': newToken,
          });
        });
      }
    } catch (e) {
      print("Error guardando FCM Token: $e");
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