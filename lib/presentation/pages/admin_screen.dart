import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/user_repository.dart';
import '../blocs/admin_cubit.dart';
import '../blocs/auth_cubit.dart';
import '../widgets/register_dialog.dart';
import '../widgets/role_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  _AdminScreenState createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  Map<String, bool> expandedUsers = {}; // Controla qué usuario está expandido

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
        cubit.listenToUsers();
        return cubit;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "Panel de Administrador - ${authState.username}",
            style: const TextStyle(fontSize: 16),
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
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Lista de",
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const Text(
                "Usuarios",
                style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'italiano',
                    color: Colors.orange),
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
                          final user = state.users[index];
                          final userId = user['uid'];
                          final role = user['role'] ?? 'Sin rol';
                          final isExpanded = expandedUsers[userId] ?? false;

                          return Card(
                            child: Column(
                              children: [
                                ListTile(
                                  title: Text(user['username'] ?? 'Sin nombre'),
                                  subtitle: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      _getRoleIcon(role),
                                    ],
                                  ),
                                  leading: const Icon(Icons.person),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit,
                                            color: Colors.blue),
                                        onPressed: () {
                                          _showRoleDialog(context, userId);
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete,
                                            color: Colors.red),
                                        onPressed: () {
                                          _deleteUser(context, userId);
                                        },
                                      ),
                                    ],
                                  ),
                                  onTap: () {
                                    setState(() {
                                      expandedUsers[userId] =
                                      !(expandedUsers[userId] ?? false);
                                    });
                                  },
                                ),
                                if (isExpanded) _buildTaskList(userId, role),
                              ],
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
            showRegisterDialog(context);
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _buildTaskList(String userId, String role) {
    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance.collection('tasks').get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final tasks = snapshot.data!.docs
            .where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          if (role == 'trabajador') {
            return data['assignedTo'] == userId;
          } else if (role == 'encargado') {
            return data['createdBy'] == userId;
          }
          return false;
        })
            .map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance
                .collection('users')
                .doc(data['createdBy'])
                .get(),
            builder: (context, userSnapshot) {
              String assignedByName = 'Desconocido';
              if (userSnapshot.hasData && userSnapshot.data!.exists) {
                assignedByName =
                    userSnapshot.data!.get('username') ?? 'Desconocido';
              }

              return ListTile(
                title: Text(data['title'] ?? 'Sin título',),
                subtitle: Text(
                    '${data['description']}\n'
                        'Estado: ${data['status']}\n'
                        '${role == 'trabajador' ? 'Asignado por' : 'Asignado a'}: $assignedByName'),
              );
            },
          );
        })
            .toList();

        return Column(
          children: tasks.isNotEmpty
              ? tasks
              : [const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text('No hay tareas asignadas.'),
          )],
        );
      },
    );
  }



  void _showRoleDialog(BuildContext context, String userId) {
    final adminCubit = context.read<AdminCubit>();

    showDialog(
      context: context,
      builder: (context) {
        return RoleDialog(
          userId: userId,
          adminCubit: adminCubit,
        );
      },
    );
  }

  void _deleteUser(BuildContext context, String userId) {
    final adminCubit = context.read<AdminCubit>();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Eliminar Usuario"),
          content: const Text("¿Estás seguro de que deseas eliminar este usuario?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Cancelar"),
            ),
            TextButton(
              onPressed: () {
                adminCubit.deleteUser(userId);
                Navigator.pop(context);
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
        return const Icon(Icons.person, color: Colors.grey);
    }
  }
}
