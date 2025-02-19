import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

enum Role { administrador, encargado, trabajador }

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Registro con Email, Contraseña, Nombre de usuario y Rol
  Future<User?> register(String email, String password, String username,
      [Role role = Role.trabajador]) async {
    try {
      UserCredential userCredential =
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Convertir el enum Role en un String para guardarlo en Firestore
      String roleString = role.toString().split('.').last;

      //Guardar en firestore el nombre de usuario y el rol
      await _firestore.collection("users").doc(userCredential.user!.uid).set({
        "uid": userCredential.user!.uid,
        "email": email,
        "username": username,
        "role": roleString,
      });

      return userCredential.user;
    } catch (e) {
      print("Error en el registro: $e");
      return null;
    }
  }

  // Login con Email y Contraseña
  Future<User?> login(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } catch (e) {
      print("Error en el login: $e");
      return null;
    }
  }

  // Logout
  Future<void> logout() async {
    await _auth.signOut();
  }
}
