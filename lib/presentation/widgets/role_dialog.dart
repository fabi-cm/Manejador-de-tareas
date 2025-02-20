import 'package:flutter/material.dart';
import '../blocs/admin_cubit.dart';

class RoleDialog extends StatelessWidget {
  final String userId;
  final AdminCubit adminCubit; // Recibimos el AdminCubit como parámetro

  const RoleDialog({
    super.key,
    required this.userId,
    required this.adminCubit,
  });

  @override
  Widget build(BuildContext context) {
    String newRole = 'trabajador'; // Valor predeterminado

    return AlertDialog(
      title: const Text('Cambiar Rol'),
      content: DropdownButton<String>(
        value: newRole,
        onChanged: (String? newValue) {
          newRole = newValue!;
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
            adminCubit.updateUserRole(userId, newRole); // Usamos el AdminCubit pasado como parámetro
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
  }
}