import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_manager/presentation/blocs/task_cubit.dart';
import 'package:task_manager/presentation/blocs/auth_cubit.dart';
import '../domain/entities/task_entity.dart';

class ManagerScreen extends StatefulWidget {
  @override
  _ManagerScreenState createState() => _ManagerScreenState();
}

class _ManagerScreenState extends State<ManagerScreen> {
  int _selectedIndex = 0; // Índice de la barra de navegación
  String? currentUserId; // ID del usuario autenticado

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String? assignedUserId;
  String? assignedUserName;
  bool isButtonEnabled = false;

  @override
  void initState() {
    super.initState();
    _getCurrentUserId();
  }

  void _getCurrentUserId() {
    final authState = context.read<AuthCubit>().state;
    if (authState is Authenticated) {
      setState(() {
        currentUserId = authState.user.uid;
      });
    }
  }

  void _checkForm() {
    setState(() {
      isButtonEnabled = _titleController.text.isNotEmpty &&
          _descriptionController.text.isNotEmpty &&
          assignedUserId != null;
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Panel de Encargado"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => context.read<AuthCubit>().logout(context),
          ),
        ],
      ),
      body: _selectedIndex == 0 ? _buildCreateTaskScreen() : _buildWorkerListScreen(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.task), label: "Crear Tarea"),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: "Trabajadores"),
        ],
      ),
    );
  }

  /// **Pantalla para Crear Tarea**
  Widget _buildCreateTaskScreen() {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            controller: _titleController,
            decoration: InputDecoration(labelText: "Título"),
            onChanged: (_) => _checkForm(),
          ),
          TextField(
            controller: _descriptionController,
            decoration: InputDecoration(labelText: "Descripción"),
            onChanged: (_) => _checkForm(),
          ),
          SizedBox(height: 20),
          Row(
            children: [
              Text("Asignar a: "),
              ElevatedButton(
                onPressed: () async {
                  final selectedUser = await _showUserSelectionDialog(context);
                  if (selectedUser != null) {
                    setState(() {
                      assignedUserId = selectedUser['uid'];
                      assignedUserName = selectedUser['username'];
                      _checkForm();
                    });
                  }
                },
                child: Text(assignedUserName ?? "Seleccionar"),
              ),
            ],
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: isButtonEnabled
                ? () async {
              try {
                final newTask = TaskEntity(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  title: _titleController.text,
                  description: _descriptionController.text,
                  assignedTo: assignedUserId!,
                  status: "pendiente",
                  priority: 1,
                  createdBy: currentUserId ?? "ID_DESCONOCIDO",
                  timestamp: DateTime.now(),
                );

                await context.read<TaskCubit>().createTask(newTask);

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Tarea creada con éxito")),
                  );
                  // Limpiar los campos después de la creación
                  setState(() {
                    _titleController.clear();
                    _descriptionController.clear();
                    assignedUserId = null;
                    assignedUserName = null;
                    isButtonEnabled = false;
                  });
                }
              } catch (e) {
                print("Error al crear la tarea: $e");
              }
            }
                : null,
            child: Text("Crear Tarea"),
          ),
        ],
      ),
    );
  }

  /// **Pantalla para ver Trabajadores**
  Widget _buildWorkerListScreen() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'trabajador')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text("No hay trabajadores disponibles"));
        }

        return ListView(
          children: snapshot.data!.docs.map((doc) {
            return ListTile(
              leading: Icon(Icons.person),
              title: Text(doc['username'] ?? 'Sin nombre'),
            );
          }).toList(),
        );
      },
    );
  }

  /// **Función para seleccionar un trabajador**
  Future<Map<String, String>?> _showUserSelectionDialog(BuildContext context) async {
    List<Map<String, String>> workersList = [];

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'trabajador')
          .get();

      workersList = snapshot.docs
          .map((doc) => {
        'uid': doc.id, // ID del documento en Firebase
        'username': doc['username'] as String,
      })
          .toList();
    } catch (e) {
      print("Error al obtener la lista de trabajadores: $e");
      return null;
    }

    return showDialog<Map<String, String>?>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Seleccionar Trabajador"),
          content: workersList.isEmpty
              ? Text("No hay trabajadores disponibles")
              : Column(
            mainAxisSize: MainAxisSize.min,
            children: workersList.map((worker) {
              return ListTile(
                title: Text(worker['username']!),
                onTap: () => Navigator.pop(context, worker),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}
