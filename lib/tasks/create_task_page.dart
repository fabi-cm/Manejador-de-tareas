import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CreateTaskPage extends StatefulWidget {
  final String id; // El uid del encargado (recibido desde la navegación)

  CreateTaskPage({super.key, required this.id});

  @override
  _CreateTaskPageState createState() => _CreateTaskPageState();
}

class _CreateTaskPageState extends State<CreateTaskPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  List<Map<String, dynamic>> workersList = []; // Lista de trabajadores

  @override
  void initState() {
    super.initState();
    _fetchWorkers(); // Obtener lista de trabajadores
  }

  // Método para obtener la lista de trabajadores desde Firestore
  Future<void> _fetchWorkers() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'trabajador')
          .get();
      setState(() {
        workersList = snapshot.docs
            .map((doc) => {
          'uid': doc['uid'],
          'username': doc['username'],
        })
            .toList();
      });
    } catch (e) {
      print("Error al obtener la lista de trabajadores: $e");
    }
  }

  // Método para crear una nueva tarea
  Future<void> _createTask() async {
    String title = _titleController.text;
    String description = _descriptionController.text;
    String assignedTo =
    workersList[0]['uid']; // Asignar al primer trabajador de la lista

    try {
      await _firestore.collection('tasks').add({
        'title': title,
        'description': description,
        'status': 'pendiente',
        'assignedTo': assignedTo,
        'createdBy': widget.id, // ID del encargado
      });

      // Limpiar los campos
      _titleController.clear();
      _descriptionController.clear();
      print("Tarea creada con éxito");
    } catch (e) {
      print("Error al crear la tarea: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Crear Tarea"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Título de la tarea'),
            ),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(labelText: 'Descripción de la tarea'),
            ),
            DropdownButton<String>(
              value: workersList.isNotEmpty ? workersList[0]['uid'] : null,
              hint: Text('Asignar trabajador'),
              onChanged: (String? newValue) {
                setState(() {
                  // Seleccionamos al trabajador
                });
              },
              items: workersList.map<DropdownMenuItem<String>>((worker) {
                return DropdownMenuItem<String>(
                  value: worker['uid'],
                  child: Text(worker['username']),
                );
              }).toList(),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _createTask,
              child: Text('Crear Tarea'),
            ),
          ],
        ),
      ),
    );
  }
}
