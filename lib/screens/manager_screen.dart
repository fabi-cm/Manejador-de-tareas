import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_manager/presentation/blocs/task_cubit.dart';
import 'package:task_manager/presentation/blocs/auth_cubit.dart';
import '../domain/entities/task_entity.dart';
import '../presentation/widgets/SearchAndFilterWidget.dart';

class ManagerScreen extends StatefulWidget {
  const ManagerScreen({super.key});

  @override
  _ManagerScreenState createState() => _ManagerScreenState();
}

class _ManagerScreenState extends State<ManagerScreen> {
  int _selectedIndex = 0; // Índice de la barra de navegación
  String? currentUserId; // ID del usuario autenticado
  String? username = 'invitado';
  String searchQuery = '';
  String? selectedFilter;

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
        username = authState.username;
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
        title: Row(
          children: [
            Icon(Icons.person),
            SizedBox(
              width: 10,
            ),
            Text(
              '$username',
              style: TextStyle(
                  fontStyle: FontStyle.italic, fontWeight: FontWeight.w500),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => context.read<AuthCubit>().logout(context),
          ),
        ],
      ),
      body: _selectedIndex == 0
          ? _buildCreateTaskScreen()
          : _buildWorkerListScreen(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.task), label: "Crear Tarea"),
          BottomNavigationBarItem(
              icon: Icon(Icons.people), label: "Trabajadores"),
        ],
      ),
    );
  }

  /// **Pantalla para Crear Tarea**
  Widget _buildCreateTaskScreen() {
    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              child: Column(
                children: [
                  Text(
                    "Crear Nueva Tarea",
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
                  SizedBox(height: 16),
                  TextField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      labelText: "Título de la tarea *",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      hintText: "Ej: Mantenimiento de Motor",
                    ),
                    onChanged: (_) => _checkForm(),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: _descriptionController,
                    decoration: InputDecoration(
                      labelText: "Descripción",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      hintText: "Ej: Mantenimiento Preventivo de Motor",
                    ),
                    maxLines: 3,
                    onChanged: (_) => _checkForm(),
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Text(
                        "Asignar a *",
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            fontStyle: FontStyle.italic),
                      ),
                      SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () async {
                          final selectedUser =
                              await _showUserSelectionDialog(context);
                          if (selectedUser != null) {
                            setState(() {
                              assignedUserId = selectedUser['uid'];
                              assignedUserName = selectedUser['username'];
                              _checkForm();
                            });
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          assignedUserName ?? "Seleccionar usuario",
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              child: ElevatedButton(
                onPressed: isButtonEnabled
                    ? () async {
                        try {
                          final newTask = TaskEntity(
                            id: DateTime.now()
                                .millisecondsSinceEpoch
                                .toString(),
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
                              SnackBar(
                                content: Text("Tarea creada con éxito"),
                                backgroundColor: Colors.green,
                              ),
                            );

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
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Error al crear la tarea")),
                          );
                        }
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: isButtonEnabled ? Colors.blue : Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  "Crear Tarea",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// **Pantalla para ver Trabajadores**
  Widget _buildWorkerListScreen() {
    final String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Lista de Trabajadores",
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
      ),
      body: Column(
        children: [
          // Agregar el SearchAndFilterWidget
          SearchAndFilterWidget(
            onSearchChanged: (query) {
              setState(() {
                searchQuery =
                    query.toLowerCase(); // Actualizar la consulta de búsqueda
              });
            },
            onFilterChanged: (filter) {
              setState(() {
                selectedFilter = filter; // Actualizar el filtro seleccionado
              });
            },
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
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

                List<QueryDocumentSnapshot> workers = snapshot.data!.docs;

                // Filtrar trabajadores basados en la búsqueda y el filtro
                List<QueryDocumentSnapshot> filteredWorkers =
                    workers.where((doc) {
                  final String username = doc['username']?.toLowerCase() ?? '';
                  final bool matchesSearch = username.contains(searchQuery);

                  // Obtener el estado del trabajador
                  final String workerStatus =
                      _getWorkerStatus(doc.id) as String;

                  final bool matchesFilter =
                      selectedFilter == null || selectedFilter == workerStatus;

                  return matchesSearch && matchesFilter;
                }).toList();

                return ListView(
                  padding: EdgeInsets.all(16),
                  children: filteredWorkers.map((doc) {
                    String workerId = doc.id;

                    return StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('tasks')
                          .where('assignedTo', isEqualTo: workerId)
                          .snapshots(),
                      builder: (context, taskSnapshot) {
                        if (!taskSnapshot.hasData) {
                          return Card(
                            child: ListTile(
                              title: Text("Cargando tareas..."),
                            ),
                          );
                        }

                        // Obtener las tareas
                        final tasks = taskSnapshot.data!.docs;

                        // Filtrar tareas asignadas por el encargado actual
                        List<QueryDocumentSnapshot> assignedByCurrentUser =
                            tasks
                                .where((task) =>
                                    task['createdBy'] == currentUserId)
                                .toList();
                        List<QueryDocumentSnapshot> otherTasks = tasks
                            .where((task) => task['createdBy'] != currentUserId)
                            .toList();

                        // Usar un FutureBuilder para obtener el estado del trabajador
                        return FutureBuilder<String>(
                          future: _getWorkerStatus(
                              workerId), // Llamada a la función asíncrona
                          builder: (context, statusSnapshot) {
                            if (!statusSnapshot.hasData) {
                              return Card(
                                child: ListTile(
                                  title: Text("Cargando estado..."),
                                ),
                              );
                            }

                            // Estado del trabajador
                            final workerStatus = statusSnapshot.data!;
                            final statusColor = _getStatusColor(workerStatus);

                            return Card(
                              margin: EdgeInsets.only(bottom: 16),
                              child: ExpansionTile(
                                leading: CircleAvatar(
                                  backgroundColor: statusColor.withOpacity(0.2),
                                  child: Icon(Icons.person, color: statusColor),
                                ),
                                title: Text(
                                  doc['username'] ?? 'Sin nombre',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text(
                                  "Estado: $workerStatus",
                                  style: TextStyle(color: statusColor),
                                ),
                                children: [
                                  if (tasks.isEmpty)
                                    ListTile(
                                      title: Text("No tiene tareas asignadas"),
                                    ),
                                  ...assignedByCurrentUser.map((taskDoc) =>
                                      _buildTaskTile(taskDoc, currentUserId)),
                                  ...otherTasks.map((taskDoc) =>
                                      _buildTaskTile(taskDoc, currentUserId)),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Complementos adicionales para el filtro y buscador
  Future<String> _getWorkerStatus(String workerId) async {
    try {
      // Obtener las tareas asignadas al trabajador
      final taskSnapshot = await FirebaseFirestore.instance
          .collection('tasks')
          .where('assignedTo', isEqualTo: workerId)
          .get();

      final tasks = taskSnapshot.docs;

      // Determinar el estado del trabajador
      if (tasks.any((task) => task['status'] == "en progreso")) {
        return "Trabajando";
      } else if (tasks.any((task) => task['status'] == "pendiente")) {
        return "Tareas por Trabajar";
      } else if (tasks.isEmpty) {
        return "Sin Tareas";
      } else {
        return "Libre";
      }
    } catch (e) {
      print("Error al obtener el estado del trabajador: $e");
      return "Error";
    }
  }

  /// **Widget para mostrar una tarea**
  Widget _buildTaskTile(QueryDocumentSnapshot taskDoc, String currentUserId) {
    bool canEditOrDelete = taskDoc['createdBy'] == currentUserId;
    return Card(
      margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: ListTile(
        title: Text(
          taskDoc['title'],
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(taskDoc['description']),
            SizedBox(height: 4),
            Text(
              "Estado: ${taskDoc['status']}",
              style: TextStyle(color: _getStatusColor(taskDoc['status'])),
            ),
          ],
        ),
        trailing: canEditOrDelete
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.edit, color: Colors.blue),
                    onPressed: () => _editTask(context, taskDoc),
                  ),
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _confirmDeleteTask(context, taskDoc),
                  ),
                ],
              )
            : null,
      ),
    );
  }

  /// **Función para obtener el color del estado**
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

  /// Función para editar una tarea
  void _editTask(BuildContext context, QueryDocumentSnapshot taskDoc) {
    TextEditingController titleController =
        TextEditingController(text: taskDoc['title']);
    TextEditingController descriptionController =
        TextEditingController(text: taskDoc['description']);

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
                // Usar taskDoc.id para obtener el ID de la tarea
                String taskId = taskDoc.id;

                // Crear una copia con los valores actualizados
                FirebaseFirestore.instance
                    .collection('tasks')
                    .doc(taskId)
                    .update({
                  'title': titleController.text,
                  'description': descriptionController.text,
                });

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
  void _confirmDeleteTask(BuildContext context, QueryDocumentSnapshot taskDoc) {
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
                // Usar taskDoc.id para obtener el ID de la tarea
                String taskId = taskDoc.id;
                FirebaseFirestore.instance
                    .collection('tasks')
                    .doc(taskId)
                    .delete();
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
  Future<Map<String, String>?> _showUserSelectionDialog(
      BuildContext context) async {
    List<Map<String, String>> workersList = [];
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: 'trabajador')
        .get();
    workersList = snapshot.docs
        .map((doc) => {'uid': doc.id, 'username': doc['username'] as String})
        .toList();
    return showDialog<Map<String, String>?>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Seleccionar Trabajador"),
          content: workersList.isEmpty
              ? Text(
                  "No hay trabajadores disponibles",
                )
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: workersList.map((worker) {
                    return ListTile(
                        title: Text(worker['username']!),
                        onTap: () => Navigator.pop(context, worker));
                  }).toList()),
        );
      },
    );
  }
}
