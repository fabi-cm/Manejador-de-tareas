import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeScreen extends StatefulWidget {
  final String id; // El uid recibido desde la navegación

  const HomeScreen({super.key, required this.id});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String username = 'Cargando...'; // Valor inicial para el username
  List<Map<String, dynamic>> usersList = []; // Lista de usuarios

  @override
  void initState() {
    super.initState();
    _fetchUsername();
    _fetchUsers(); // Obtener lista de usuarios
  }

  // Método para obtener el username a partir del uid
  Future<void> _fetchUsername() async {
    try {
      DocumentSnapshot snapshot =
      await _firestore.collection('users').doc(widget.id).get();

      if (snapshot.exists) {
        setState(() {
          username = snapshot['username'] ?? 'Usuario no encontrado';
        });
      } else {
        setState(() {
          username = 'Usuario no encontrado';
        });
      }
    } catch (e) {
      print("Error al obtener el username: $e");
      setState(() {
        username = 'Error al cargar el usuario';
      });
    }
  }

  // Método para obtener la lista de usuarios desde Firestore
  Future<void> _fetchUsers() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('users').get();

      // Convertir los documentos a una lista de mapas
      setState(() {
        usersList = snapshot.docs
            .map((doc) => {
          'uid': doc['uid'],
          'email': doc['email'],
          'username': doc['username'],
          'role': doc[
          'role'], // Asegúrate de que este campo esté en Firestore
        })
            .toList();
      });
    } catch (e) {
      print("Error al obtener la lista de usuarios: $e");
    }
  }

  // Método para actualizar el rol de un usuario
  Future<void> _updateUserRole(String userId, String newRole) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'role': newRole,
      });
      // Actualizamos la lista de usuarios
      _fetchUsers();
    } catch (e) {
      print("Error al actualizar el rol del usuario: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text(
              "Inicio", // Título "Inicio"
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(width: 10), // Espacio entre el título y el nombre
            Text(
              username, // Nombre de usuario a la derecha del título
              style: TextStyle(fontSize: 18),
            ),
            Spacer(), // Empuja el icono de logout a la derecha
            IconButton(
              icon: Icon(Icons.logout),
              onPressed: () {
                // Lógica para logout
              },
            ),
          ],
        ),
      ),
      body: Center(
        child: Column(
          children: [
            SizedBox(height: 20),
            Text("Usuarios Registrados", style: TextStyle(fontSize: 20)),
            SizedBox(height: 20),
            // Lista de usuarios
            Expanded(
              child: ListView.builder(
                itemCount: usersList.length,
                itemBuilder: (context, index) {
                  String role = usersList[index]['role'] ?? 'Sin rol';
                  return ListTile(
                    title: Text(usersList[index]['username'] ?? 'Sin nombre'),
                    subtitle: Text(usersList[index]['email'] ?? 'Sin email'),
                    leading: Icon(Icons.person),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(role),
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () {
                            // Mostrar un cuadro de diálogo o menú para cambiar el rol
                            _showRoleDialog(usersList[index]['uid']);
                          },
                        ),
                      ],
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
          title: Text('Cambiar Rol'),
          content: DropdownButton<String>(
            value: newRole,
            onChanged: (String? newValue) {
              setState(() {
                newRole = newValue!;
              });
            },
            items: <String>['trabajador', 'encargado', 'administrador']
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
                // Actualizamos el rol en Firestore
                _updateUserRole(userId, newRole);
                Navigator.of(context).pop();
              },
              child: Text('Actualizar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancelar'),
            ),
          ],
        );
      },
    );
  }
}
