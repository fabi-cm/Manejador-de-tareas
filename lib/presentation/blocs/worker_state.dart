import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class WorkerTaskScreen extends StatefulWidget {
  final String uid; // El uid del trabajador

  WorkerTaskScreen({super.key, required this.uid});

  @override
  _WorkerTaskScreenState createState() => _WorkerTaskScreenState();
}

class _WorkerTaskScreenState extends State<WorkerTaskScreen> {
  // Obtiene las tareas del trabajador desde Firestore
  Stream<QuerySnapshot> _getTasks() {
    return FirebaseFirestore.instance
        .collection('tasks')
        .where('assignedTo', isEqualTo: widget.uid) // Filtrar por 'assignedTo'
        .snapshots(); // Obtención en tiempo real
  }

  // Función para actualizar el estado de la tarea
  Future<void> _updateTaskStatus(String taskId, String newStatus) async {
    try {
      await FirebaseFirestore.instance
          .collection('tasks')
          .doc(taskId)
          .update({'status': newStatus});
      print('Estado de tarea actualizado');
    } catch (e) {
      print('Error al actualizar el estado: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Mis Tareas"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _getTasks(), // Obtenemos las tareas en tiempo real
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error al obtener tareas"));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("No tienes tareas asignadas"));
          }

          var tasks = snapshot.data!.docs;

          return ListView.builder(
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              var task = tasks[index];
              String taskId = task.id;
              String title = task['title'];
              String description = task['description'];
              String status = task['status'];
              String priority = task['priority'].toString();

              return ListTile(
                title: Text(title),
                subtitle: Text(description),
                trailing: DropdownButton<String>(
                  value: status,
                  items: ['Pendiente', 'En progreso', 'Completado']
                      .map((statusOption) {
                    return DropdownMenuItem<String>(
                      value: statusOption,
                      child: Text(statusOption),
                    );
                  }).toList(),
                  onChanged: (newStatus) {
                    if (newStatus != null) {
                      _updateTaskStatus(taskId, newStatus);
                    }
                  },
                ),
                leading: Icon(Icons.assignment),
                isThreeLine: true,
                contentPadding: EdgeInsets.all(16),
              );
            },
          );
        },
      ),
    );
  }
}
