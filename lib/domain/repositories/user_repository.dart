abstract class UserRepository {
  Future<List<Map<String, dynamic>>> fetchUsers();
  Future<void> updateUserRole(String userId, String newRole);
  Future<List<Map<String, dynamic>>> searchUsers(String query);
}