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

class UserRoles {
  static const String admin = "administrador";
  static const String manager = "encargado";
  static const String worker = "trabajador";
}

class RoleUtils {
  static Color getRoleColor(String role) {
    switch (role) {
      case UserRoles.admin:
        return Colors.orange;
      case UserRoles.manager:
        return Colors.blue;
      case UserRoles.worker:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  static Icon getRoleIcon(String role) {
    switch (role) {
      case UserRoles.admin:
        return Icon(Icons.person, color: Colors.orange);
      case UserRoles.manager:
        return Icon(Icons.groups, color: Colors.blue);
      case UserRoles.worker:
        return Icon(Icons.work, color: Colors.green);
      default:
        return Icon(Icons.person);
    }
  }
}

class _AdminScreenState extends State<AdminScreen> {
  Map<String, bool> expandedUsers = {};

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthCubit>().state;
    String? username;
    if (authState is Authenticated) {
      username = authState.username;
    }

    if (authState is! Authenticated || authState.role != UserRoles.admin) {
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
          title: Row(
            children: [
              Icon(Icons.person),
              SizedBox(width: 10),
              Text('$username', style: TextStyle(fontStyle: FontStyle.italic, fontWeight: FontWeight.w500)),
            ],
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
            children: [
              const Text(
                "Lista de usuarios",
                style: TextStyle(
                  fontSize: 40,
                  fontFamily: 'italiano',
                  color: Colors.orange,
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.underline,
                  decorationColor: Colors.orange,
                  decorationThickness: 2,
                ),
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
                            margin: EdgeInsets.only(bottom: 16),
                            child: ExpansionTile(
                              leading: CircleAvatar(
                                backgroundColor: RoleUtils.getRoleColor(role).withOpacity(0.2),
                                child: Icon(Icons.person, color: RoleUtils.getRoleColor(role)),
                              ),
                              title: Text(
                                user['username'] ?? 'Sin nombre',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              subtitle: Align(
                                alignment: Alignment.centerLeft,
                                child: RoleUtils.getRoleIcon(role),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit, color: Colors.blue),
                                    onPressed: () {
                                      _showRoleDialog(context, userId);
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () {
                                      _deleteUser(context, userId);
                                    },
                                  ),
                                ],
                              ),
                              onExpansionChanged: (isExpanded) {
                                setState(() {
                                  expandedUsers[userId] = isExpanded;
                                });
                              },
                              children: [
                                if (expandedUsers[userId] ?? false) _buildTaskList(userId, role),
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

// Resto del código...



  Widget _buildTaskList(String userId, String role) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('tasks')
          .where(role == 'trabajador' ? 'assignedTo' : 'createdBy', isEqualTo: userId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text('No hay tareas asignadas.'),
          );
        }

        final tasks = snapshot.data!.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final createdBy = data['createdBy'];
          final assignedTo = data['assignedTo'];

          // Obtener el nombre del creador y del asignado
          return FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance
                .collection('users')
                .doc(createdBy)
                .get(),
            builder: (context, createdBySnapshot) {
              if (createdBySnapshot.connectionState == ConnectionState.waiting) {
                return ListTile(
                  title: Text("Cargando..."),
                );
              }
              if (createdBySnapshot.hasError || !createdBySnapshot.hasData || !createdBySnapshot.data!.exists) {
                return ListTile(
                  title: Text("Error al cargar datos del creador"),
                );
              }

              final createdByName = createdBySnapshot.data!.get('username') ?? 'Desconocido';

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('users')
                    .doc(assignedTo)
                    .get(),
                builder: (context, assignedToSnapshot) {
                  if (assignedToSnapshot.connectionState == ConnectionState.waiting) {
                    return ListTile(
                      title: Text("Cargando..."),
                    );
                  }
                  if (assignedToSnapshot.hasError || !assignedToSnapshot.hasData || !assignedToSnapshot.data!.exists) {
                    return ListTile(
                      title: Text("Error al cargar datos del asignado"),
                    );
                  }

                  final assignedToName = assignedToSnapshot.data!.get('username') ?? 'Desconocido';

                  return ListTile(
                    title: Text(data['title'] ?? 'Sin título'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(data['description'] ?? 'Sin descripción'),
                        SizedBox(height: 4),
                        Text(
                          "Estado: ${data['status']}",
                          style: TextStyle(color: _getStatusColor(data['status'])),
                        ),
                        if (role == 'trabajador')
                          Text("Asignado por: $createdByName"),
                        if (role == 'encargado')
                          Text("Asignado a: $assignedToName"),
                      ],
                    ),
                  );
                },
              );
            },
          );
        }).toList();

        return Column(
          children: tasks,
        );
      },
    );
  }


  void _showRoleDialog(BuildContext context, String userId) {
    final adminCubit = context.read<AdminCubit>();
    showDialog(
      context: context,
      builder: (_) => RoleDialog(userId: userId, adminCubit: adminCubit),
    );
  }

  void _deleteUser(BuildContext context, String userId) {
    final adminCubit = context.read<AdminCubit>();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Eliminar Usuario"),
        content: const Text("¿Estás seguro de que deseas eliminar este usuario?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
          TextButton(
            onPressed: () {
              adminCubit.deleteUser(userId);
              Navigator.pop(context);
            },
            child: const Text("Eliminar", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }




  Color _getStatusColor(String status) {
    switch (status) {
      case "pendiente":
        return Colors.orange;
      case "en progreso":
        return Colors.blue;
      case "completado":
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

}
