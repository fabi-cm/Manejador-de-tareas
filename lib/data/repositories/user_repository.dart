import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/repositories/user_repository.dart';

class UserRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Escuchar cambios en la lista de usuarios en tiempo real
  Stream<List<Map<String, dynamic>>> fetchUsersStream() {
    return _firestore.collection('users').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => {
        'uid': doc.id,
        'email': doc['email'],
        'username': doc['username'],
        'role': doc['role'],
      }).toList();
    });
  }

  // Buscar un usuario por username
  Future<List<Map<String, dynamic>>> searchUsersByUsername(String query) async {
    try {
      // Realiza una consulta para buscar por username
      final usernameQuery = await _firestore
          .collection('users')
          .where('username', isGreaterThanOrEqualTo: query)
          .where('username', isLessThan: query + 'z')
          .get();

      // Mapea los resultados a un formato de mapa
      return usernameQuery.docs.map((doc) => {
        'uid': doc.id,
        'email': doc['email'],
        'username': doc['username'],
        'role': doc['role'],
      }).toList();
    } catch (e) {
      throw Exception("Error al buscar usuarios por username: $e");
    }
  }

  Future<void> updateUserRole(String userId, String newRole) async {
    try {
      await _firestore.collection('users').doc(userId).update({'role': newRole});
    } catch (e) {
      throw Exception("Error al actualizar el rol del usuario: $e");
    }
  }

  Future<void> deleteUser(String userId) async {
    await _firestore.collection("users").doc(userId).delete();
  }
}