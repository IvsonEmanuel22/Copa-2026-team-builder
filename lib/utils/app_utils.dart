import 'package:flutter/material.dart';

String lineupKey(String formationName) {
  return 'lineup_${formationName.replaceAll(RegExp(r'[^A-Za-z0-9]'), '_')}';
}

IconData iconForRoles(List<String> roles) {
  final role = roles.isEmpty ? 'CM' : roles.first;
  if (role == 'GK') return Icons.sports_soccer;
  if (role == 'CB') return Icons.shield;
  if (role == 'LB' || role == 'RB') return Icons.directions_run;
  if (role == 'LWB' || role == 'RWB') return Icons.bolt;
  if (role == 'CDM') return Icons.anchor;
  if (role == 'CM') return Icons.control_camera;
  if (role == 'CAM') return Icons.auto_awesome;
  if (role == 'LW' || role == 'RW') return Icons.flash_on;
  if (role == 'ST') return Icons.local_fire_department;
  return Icons.person;
}

Color colorFromId(int id) {
  final colors = [
    Colors.green,
    Colors.blue,
    Colors.red,
    Colors.orange,
    Colors.purple,
    Colors.teal,
    Colors.indigo,
    Colors.amber,
    Colors.cyan,
    Colors.deepOrange,
  ];
  return colors[id.abs() % colors.length];
}
