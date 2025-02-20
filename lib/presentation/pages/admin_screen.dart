import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/user_repository.dart';
import '../blocs/admin_cubit.dart';
import '../blocs/auth_cubit.dart';
import '../widgets/role_dialog.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthCubit>().state;

    if (authState is! Authenticated || authState.role != "administrador") {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("No tienes permisos para acceder a esta página."),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => context.read<AuthCubit>().logout(context),
                child: const Text("Cerrar sesión"),
              ),
            ],
          ),
        ),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Usuarios Registrados", style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
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
                              subtitle: Text(state.users[index]['email'] ?? 'Sin email'),
                              leading: const Icon(Icons.person),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(role),
                                  IconButton(
                                    icon: const Icon(Icons.edit),
                                    onPressed: () {
                                      _showRoleDialog(context, state.users[index]['uid']);
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
}