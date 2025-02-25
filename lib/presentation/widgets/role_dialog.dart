import 'package:flutter/material.dart';
import '../blocs/admin_cubit.dart';

class RoleDialog extends StatefulWidget {
  final String userId;
  final AdminCubit adminCubit; // Recibimos el AdminCubit como parámetro

  const RoleDialog({
    super.key,
    required this.userId,
    required this.adminCubit,
  });

  @override
  _RoleDialogState createState() => _RoleDialogState();
}

class _RoleDialogState extends State<RoleDialog> {
  String newRole = 'trabajador'; // Valor predeterminado

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Cambiar Rol'),
      content: DropdownButton<String>(
        value: newRole,
        onChanged: (String? newValue) {
          setState(() {
            newRole = newValue!; // Actualizar el estado con el nuevo valor
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
            widget.adminCubit.updateUserRole(widget.userId, newRole); // Usamos el AdminCubit pasado como parámetro
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