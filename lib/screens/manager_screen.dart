import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_manager/presentation/blocs/task_cubit.dart';
import 'package:task_manager/presentation/blocs/auth_cubit.dart';
import '../domain/entities/task_entity.dart';

class ManagerScreen extends StatefulWidget {
  const ManagerScreen({super.key});

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
            String workerId = doc.id;
            return ExpansionTile(
              leading: Icon(Icons.person),
              title: Text(doc['username'] ?? 'Sin nombre'),
              children: [
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('tasks')
                      .where('assignedTo', isEqualTo: workerId)
                      .snapshots(),
                  builder: (context, taskSnapshot) {
                    if (!taskSnapshot.hasData || taskSnapshot.data!.docs.isEmpty) {
                      return ListTile(title: Text("No tiene tareas asignadas"));
                    }
                    return Column(
                      children: taskSnapshot.data!.docs.map((taskDoc) {
                        TaskEntity task = TaskEntity(
                          id: taskDoc.id,
                          title: taskDoc['title'],
                          description: taskDoc['description'],
                          assignedTo: taskDoc['assignedTo'],
                          status: taskDoc['status'],
                          priority: taskDoc['priority'],
                          createdBy: taskDoc['createdBy'],
                          timestamp: taskDoc['timestamp'] is Timestamp
                              ? (taskDoc['timestamp'] as Timestamp).toDate()
                              : DateTime.fromMillisecondsSinceEpoch(taskDoc['timestamp']),
                        );

                        return ListTile(
                          title: Text(task.title),
                          subtitle: Text(task.description),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit, color: Colors.blue),
                                onPressed: () => _editTask(context, task),
                              ),
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _confirmDeleteTask(context, task.id),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
              ],
            );
          }).toList(),
        );
      },
    );
  }


  /// Función para editar una tarea
  void _editTask(BuildContext context, TaskEntity task) {
    TextEditingController titleController = TextEditingController(text: task.title);
    TextEditingController descriptionController = TextEditingController(text: task.description);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Editar Tarea"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(labelText: "Título"),
              ),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(labelText: "Descripción"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancelar"),
            ),
            TextButton(
              onPressed: () {
                TaskEntity updatedTask = task.copyWith(
                  title: titleController.text,
                  description: descriptionController.text,
                );

                context.read<TaskCubit>().modifyTask(updatedTask);
                Navigator.pop(context);
              },
              child: Text("Guardar"),
            ),
          ],
        );
      },
    );
  }

  /// Función para confirmar la eliminación de una tarea
  void _confirmDeleteTask(BuildContext context, String taskId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Eliminar Tarea"),
          content: Text("¿Estás seguro de que deseas eliminar esta tarea?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancelar"),
            ),
            TextButton(
              onPressed: () {
                context.read<TaskCubit>().removeTask(taskId);
                Navigator.pop(context);
              },
              child: Text("Eliminar", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  /// **Función para seleccionar un trabajador**
  Future<Map<String, String>?> _showUserSelectionDialog(BuildContext context) async {
    List<Map<String, String>> workersList = [];
    final snapshot = await FirebaseFirestore.instance.collection('users').where('role', isEqualTo: 'trabajador').get();
    workersList = snapshot.docs.map((doc) => {'uid': doc.id, 'username': doc['username'] as String}).toList();
    return showDialog<Map<String, String>?>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Seleccionar Trabajador"),
          content: workersList.isEmpty
              ? Text("No hay trabajadores disponibles")
              : Column(mainAxisSize: MainAxisSize.min, children: workersList.map((worker) {
            return ListTile(title: Text(worker['username']!), onTap: () => Navigator.pop(context, worker));
          }).toList()),
        );
      },
    );
  }
}
