import 'package:flutter/material.dart';

class TaskItem extends StatelessWidget {
  final String taskId;
  final String title;
  final String description;
  final String status;
  final String priority;
  final Function(String, String) onUpdateStatus;

  const TaskItem({
    super.key,
    required this.taskId,
    required this.title,
    required this.description,
    required this.status,
    required this.priority,
    required this.onUpdateStatus,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16,),
      elevation: 5,
      shadowColor: _getStatusColor(status),
      child: ListTile(
        leading: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.assignment, color: _getStatusColor(status)), // Ícono de la tarea
            const SizedBox(height: 4), // Espacio entre ícono y prioridad
            Text(
              priority, //  Muestra la prioridad debajo del ícono
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            fontStyle: FontStyle.italic,
            decoration: status == "completado" ? TextDecoration.lineThrough : TextDecoration.none,
          ),
        ),
        subtitle: Text(description),
        trailing: ElevatedButton(
          onPressed: () {
            String newStatus;
            switch (status) {
              case 'pendiente':
                newStatus = 'en progreso';
                break;
              case 'en progreso':
                newStatus = 'completado';
                break;
              default:
                newStatus = 'pendiente';
            }
            onUpdateStatus(taskId, newStatus);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: _getStatusColor(status),
            foregroundColor: Colors.white,
          ),
          child: _getStatusIcon(status), // 🔥 Muestra icono según el estado
        ),
        contentPadding: const EdgeInsets.all(15),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pendiente':
        return Colors.red;
      case 'en progreso':
        return Colors.blue;
      case 'completado':
        return Colors.green;
      default:
        return Colors.red;
    }
  }

  /// 🔥 Método para obtener el icono según el estado
  Widget _getStatusIcon(String status) {
    switch (status) {
      case 'pendiente':
        return const Icon(Icons.hourglass_empty, color: Colors.white); // ⏳ Pendiente
      case 'en progreso':
        return const Icon(Icons.work, color: Colors.white); // 🔄 En progreso
      case 'completado':
        return const Icon(Icons.check_circle, color: Colors.white); // ✅ Completado
      default:
        return const Icon(Icons.hourglass_empty, color: Colors.white); // ❓ Desconocido
    }
  }
}
