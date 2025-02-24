import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/user_repository.dart';
import '../blocs/admin_cubit.dart';
import '../blocs/auth_cubit.dart';
import '../widgets/register_dialog.dart';
import '../widgets/role_dialog.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthCubit>().state;

    if (authState is! Authenticated || authState.role != "administrador") {
      return Scaffold(
        body:  Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(" . No tienes permisos para acceder a esta página."),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => context.read<AuthCubit>().logout(context),
                child: const Text("Cerrar sesión"),
              ),
            ],
          ),
        )
      );
    }

    return BlocProvider(
      create: (context) {
        final cubit = AdminCubit(UserRepository());
        cubit.listenToUsers(); // Se activa la escucha en tiempo real
        return cubit;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
              "Panel de Administrador - ${authState.username}",
            style: TextStyle(
              fontSize: 16,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () => context.read<AuthCubit>().logout(context),
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, // Centra el contenido verticalmente
            children: [
              Text(
                "Lista de",
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              Text(
                "Usuarios",
                style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, fontFamily: 'italiano', color: Colors.orange),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Expanded(
                child: BlocBuilder<AdminCubit, AdminState>(
                  builder: (context, state) {
                    if (state is AdminLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is AdminLoaded) {
                      return ListView.builder(
                        itemCount: state.users.length,
                        itemBuilder: (context, index) {
                          String role = state.users[index]['role'] ?? 'Sin rol';
                          return Card(
                            child: ListTile(
                              title: Text(state.users[index]['username'] ?? 'Sin nombre'),
                              subtitle: Row(
                                mainAxisAlignment: MainAxisAlignment.start, // 🔥 Pegado a la izquierda
                                children: [
                                  _getRoleIcon(state.users[index]['role'] ?? 'Sin rol'),
                                ],
                              ),
                              leading: const Icon(Icons.person),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Mostrar ícono según el rol
                                  IconButton(
                                    icon: const Icon(Icons.edit),
                                    onPressed: () {
                                      _showRoleDialog(context, state.users[index]['uid']);
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () {
                                      _deleteUser(context, state.users[index]['uid']);
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    } else if (state is AdminError) {
                      return Center(child: Text(state.message));
                    } else {
                      return const Center(child: Text("No hay datos"));
                    }
                  },
                ),
              ),
            ],
          ),
        ),
          floatingActionButton: FloatingActionButton(
          onPressed: () {
            showRegisterDialog(context);    },
      child: const Icon(Icons.add),
    ),
      ),
    );
  }

  void _showRoleDialog(BuildContext context, String userId) {
    final adminCubit = context.read<AdminCubit>(); // Obtenemos el AdminCubit

    showDialog(
      context: context,
      builder: (context) {
        return RoleDialog(
          userId: userId,
          adminCubit: adminCubit, // Pasamos el AdminCubit al diálogo
        );
      },
    );
  }

  void _deleteUser(BuildContext context, String userId) {
    final adminCubit = context.read<AdminCubit>();

    // Mostrar un diálogo de confirmación antes de eliminar
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Eliminar Usuario"),
          content: const Text("¿Estás seguro de que deseas eliminar este usuario?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Cerrar el diálogo
              },
              child: const Text("Cancelar"),
            ),
            TextButton(
              onPressed: () {
                adminCubit.deleteUser(userId); // Eliminar el usuario
                Navigator.pop(context); // Cerrar el diálogo
              },
              child: const Text("Eliminar", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  Widget _getRoleIcon(String role) {
    switch (role) {
      case 'administrador':
        return const Icon(Icons.admin_panel_settings_outlined, color: Colors.blue);
      case 'encargado':
        return const Icon(Icons.groups, color: Colors.green);
      case 'trabajador':
        return const Icon(Icons.build_sharp, color: Colors.orange);
      default:
        return const Icon(Icons.person, color: Colors.grey); // Ícono por defecto
    }
  }

}


