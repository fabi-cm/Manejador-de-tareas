import 'dart:async';
import 'package:flutter/material.dart';

class SearchAndFilterWidget extends StatefulWidget {
  final Function(String) onSearchChanged;
  final Function(String?) onFilterChanged;

  const SearchAndFilterWidget({
    Key? key,
    required this.onSearchChanged,
    required this.onFilterChanged,
  }) : super(key: key);

  @override
  _SearchAndFilterWidgetState createState() => _SearchAndFilterWidgetState();
}

class _SearchAndFilterWidgetState extends State<SearchAndFilterWidget> {
  String? selectedFilter;
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      widget.onSearchChanged(query);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          onChanged: _onSearchChanged,
          decoration: InputDecoration(
            labelText: "Buscar trabajador...",
            prefixIcon: Icon(Icons.search),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        SizedBox(height: 10),
        DropdownButtonFormField<String>(
          value: selectedFilter,
          onChanged: (value) {
            setState(() {
              selectedFilter = value;
            });
            widget.onFilterChanged(value);
          },
          items: [
            DropdownMenuItem(value: null, child: Text("Todos")),
            DropdownMenuItem(value: "Libre", child: Text("Libre")),
            DropdownMenuItem(value: "Trabajando", child: Text("Trabajando")),
            DropdownMenuItem(value: "Tareas por Trabajar", child: Text("Tareas por Trabajar")),
          ],
          decoration: InputDecoration(
            labelText: "Filtrar por estado",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ],
    );
  }
}