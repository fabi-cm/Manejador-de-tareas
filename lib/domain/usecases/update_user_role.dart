import '../../data/repositories/user_repository.dart';

class UpdateUserRole {
  final UserRepository repository;

  UpdateUserRole(this.repository);

  Future<void> call(String userId, String newRole) async {
    return await repository.updateUserRole(userId, newRole);
  }
}