import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../data/repositories/user_repository.dart';
import '../blocs/admin_cubit.dart';
import '../blocs/auth_cubit.dart';
import '../widgets/register_dialog.dart';
import '../widgets/role_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/date_symbol_data_local.dart';

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
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = ""; // Almacena el término de búsqueda

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('es', null).then((_) {
      // Una vez inicializado, puedes usar DateFormat
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

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
              // Campo de búsqueda
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  labelText: 'Buscar usuario',
                  hintText: 'Ingresa un nombre de usuario',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value; // Actualiza el término de búsqueda
                  });
                },
              ),
              const SizedBox(height: 20),
              const SizedBox(height: 10),
              Expanded(
                child: BlocBuilder<AdminCubit, AdminState>(
                  builder: (context, state) {
                    if (state is AdminLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is AdminLoaded) {
                      // Filtrar usuarios según el término de búsqueda
                      final filteredUsers = state.users.where((user) {
                        final username = user['username']?.toString().toLowerCase() ?? '';
                        return username.contains(_searchQuery.toLowerCase());
                      }).toList();

                      return ListView.builder(
                        itemCount: filteredUsers.length,
                        itemBuilder: (context, index) {
                          final user = filteredUsers[index];
                          final userId = user['uid'];
                          final role = user['role'] ?? 'Sin rol';
                          final isExpanded = expandedUsers[userId] ?? false;

                          return Card(
                            margin: EdgeInsets.only(bottom: 16),
                            child: ExpansionTile(
                              leading: CircleAvatar(
                                backgroundColor: RoleUtils.getRoleColor(role).withOpacity(0.5),
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




  Widget _buildTaskList(String userId, String role) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('tasks').snapshots(),
      builder: (context, tasksSnapshot) {
        if (tasksSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (tasksSnapshot.hasError) {
          return Center(child: Text("Error: ${tasksSnapshot.error}"));
        }
        if (!tasksSnapshot.hasData || tasksSnapshot.data!.docs.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text('No hay tareas asignadas.'),
          );
        }

        // Obtener la fecha actual y la fecha de hace 30 días
        final now = DateTime.now();
        final thirtyDaysAgo = now.subtract(Duration(days: 30));

        // Obtener todas las tareas y filtrar las de los últimos 30 días
        final tasks = tasksSnapshot.data!.docs.where((task) {
          final data = task.data() as Map<String, dynamic>;
          final timestamp = data['timestamp'] as Timestamp?;
          if (timestamp == null) return false; // Ignorar tareas sin timestamp

          final taskDate = timestamp.toDate();
          return taskDate.isAfter(thirtyDaysAgo); // Filtrar tareas de los últimos 30 días
        }).toList();

        // Filtrar las tareas según el rol del usuario
        final filteredTasks = tasks.where((task) {
          final data = task.data() as Map<String, dynamic>;
          if (role == 'trabajador') {
            return data['assignedTo'] == userId;
          } else if (role == 'encargado') {
            return data['createdBy'] == userId;
          }
          return false;
        }).toList();

        if (filteredTasks.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text('No hay tareas asignadas en los últimos 30 días.'),
          );
        }

        // Contar tareas completadas en los últimos 30 días (solo para trabajadores)
        int completedTasksCount = 0;
        if (role == 'trabajador') {
          completedTasksCount = filteredTasks.where((task) {
            final data = task.data() as Map<String, dynamic>;
            return data['status'] == 'completado';
          }).length;
        }

        // Obtener todos los usuarios de una sola vez
        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('users').snapshots(),
          builder: (context, usersSnapshot) {
            if (usersSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (usersSnapshot.hasError) {
              return Center(child: Text("Error: ${usersSnapshot.error}"));
            }
            if (!usersSnapshot.hasData || usersSnapshot.data!.docs.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text('No hay usuarios disponibles.'),
              );
            }

            // Crear un mapa de usuarios para acceder rápidamente a sus nombres
            final usersMap = <String, String>{};
            for (final userDoc in usersSnapshot.data!.docs) {
              final userData = userDoc.data() as Map<String, dynamic>;
              usersMap[userDoc.id] = userData['username'] ?? 'Desconocido';
            }

            // Construir la lista de tareas
            return Column(
              children: [
                if (role == 'trabajador')
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Tareas completadas: $completedTasksCount',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ),
                ...filteredTasks.map((task) {
                  final data = task.data() as Map<String, dynamic>;
                  final createdBy = data['createdBy'];
                  final assignedTo = data['assignedTo'];
                  final timestamp = data['timestamp'] as Timestamp?;
                  final taskDate = timestamp?.toDate();

                  return Card(
                    elevation: 3, // Intensidad del sombreado
                    margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8), // Margen entre las tarjetas
                    child: ListTile(
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
                            Text("Asignado por: ${usersMap[createdBy] ?? 'Desconocido'}"),
                          if (role == 'encargado')
                            Text("Asignado a: ${usersMap[assignedTo] ?? 'Desconocido'}"),
                          if (taskDate != null)
                            Text(
                              "Fecha: ${DateFormat('EEEE d \'de\' MMMM', 'es').format(taskDate.toLocal())}",
                              style: TextStyle(color: _getStatusColor(data['status'])),
                            ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ],
            );
          },
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
        return Colors.red;
      case "en progreso":
        return Colors.blue;
      case "completado":
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

}
