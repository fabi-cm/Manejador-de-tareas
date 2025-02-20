import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../presentation/blocs/auth_cubit.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  _AdminScreenState createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> usersList = []; // Lista de usuarios

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  // Obtener la lista de usuarios desde Firestore
  Future<void> _fetchUsers() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('users').get();
      setState(() {
        usersList = snapshot.docs
            .map((doc) => {
          'uid': doc.id,
          'email': doc['email'],
          'username': doc['username'],
          'role': doc['role'],
        })
            .toList();
      });
    } catch (e) {
      print("Error al obtener la lista de usuarios: $e");
    }
  }

  // Actualizar el rol de un usuario
  Future<void> _updateUserRole(String userId, String newRole) async {
    try {
      await _firestore.collection('users').doc(userId).update({'role': newRole});
      _fetchUsers(); // Recargar la lista
    } catch (e) {
      print("Error al actualizar el rol del usuario: $e");
    }
  }

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

    return Scaffold(
      appBar: AppBar(
        title: Text("Panel de Administrador - ${authState.username}"),
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
            const Text("Usuarios Registrados", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Expanded(
              child: usersList.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                itemCount: usersList.length,
                itemBuilder: (context, index) {
                  String role = usersList[index]['role'] ?? 'Sin rol';
                  return Card(
                    child: ListTile(
                      title: Text(usersList[index]['username'] ?? 'Sin nombre'),
                      subtitle: Text(usersList[index]['email'] ?? 'Sin email'),
                      leading: const Icon(Icons.person),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(role),
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () {
                              _showRoleDialog(usersList[index]['uid']);
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Mostrar un diálogo para cambiar el rol
  void _showRoleDialog(String userId) {
    String newRole = 'trabajador'; // Valor predeterminado
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Cambiar Rol'),
          content: DropdownButton<String>(
            value: newRole,
            onChanged: (String? newValue) {
              setState(() {
                newRole = newValue!;
              });
            },
            items: ['trabajador', 'encargado', 'administrador']
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () {
                _updateUserRole(userId, newRole);
                Navigator.of(context).pop();
              },
              child: const Text('Actualizar'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
          ],
        );
      },
    );
  }
}
