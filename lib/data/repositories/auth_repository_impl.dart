import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:task_manager/domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  @override
  Future<UserEntity?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential = await _auth.signInWithCredential(credential);
      User? user = userCredential.user;

      if (user != null) {
        final userRef = _db.collection('users').doc(user.uid);
        final userSnapshot = await userRef.get();

        if (!userSnapshot.exists) {
          await userRef.set({
            'name': user.displayName ?? 'Sin Nombre',
            'email': user.email,
            'role': 'trabajador',
            'assigned_tasks': [],
          });
        }

        return UserEntity(
          uid: user.uid,
          name: user.displayName ?? 'Sin Nombre',
          email: user.email!,
          role: 'trabajador',
          assignedTasks: [],
        );
      }
      return null;
    } catch (e) {
      print("Error en Google Sign-In: $e");
      return null;
    }
  }

  @override
  Future<void> signOut() async {
    await GoogleSignIn().signOut();
    await _auth.signOut();
  }
}
