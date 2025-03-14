import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../data/repositories/user_repository.dart';

part 'admin_state.dart';

class AdminCubit extends Cubit<AdminState> {
  final UserRepository userRepository;
  AdminCubit(this.userRepository) : super(AdminInitial());

  void listenToUsers() {
    emit(AdminLoading());
    userRepository.fetchUsersStream().listen(
          (users) {
        emit(AdminLoaded(users));
      },
      onError: (error) {
        emit(AdminError("Error al obtener la lista de usuarios: $error"));
      },
    );
  }

  Future<void> updateUserRole(String userId, String newRole) async {
    try {
      await userRepository.updateUserRole(userId, newRole);
    } catch (e) {
      emit(AdminError("Error al actualizar el rol del usuario: $e"));
    }
  }
  Future<void> deleteUser(String userId) async {
    try {
      await userRepository.deleteUser(userId); // Eliminar el usuario
      // No es necesario emitir un estado aquí, ya que el Stream se actualizará automáticamente
    } catch (e) {
      if (!isClosed) {
        emit(AdminError("Error al eliminar el usuario: $e"));
      }
    }
  }
}
