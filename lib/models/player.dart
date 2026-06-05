import 'package:flutter/material.dart';
import '../utils/app_utils.dart';

class Player {
  final int id;
  final String name;
  final String country;
  final String position;
  final List<String> roles;
  final String club;
  final int number;
  final String characteristics;
  final String description;
  final IconData icon;
  final Color color;
  final bool custom;

  Player({
    required this.id,
    required this.name,
    required this.country,
    required this.position,
    required this.roles,
    required this.club,
    required this.number,
    required this.characteristics,
    required this.description,
    required this.icon,
    required this.color,
    this.custom = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'country': country,
      'position': position,
      'roles': roles,
      'club': club,
      'number': number,
      'characteristics': characteristics,
      'description': description,
      'color': color.value,
      'custom': custom,
    };
  }

  factory Player.fromJson(Map<String, dynamic> json) {
    final roles = (json['roles'] as List?)?.map((e) => e.toString()).toList() ?? ['CM'];
    final id = json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? DateTime.now().millisecondsSinceEpoch;
    return Player(
      id: id,
      name: json['name']?.toString() ?? 'Jogador',
      country: json['country']?.toString() ?? 'País',
      position: json['position']?.toString() ?? 'Meio-campista',
      roles: roles,
      club: json['club']?.toString() ?? 'Clube',
      number: json['number'] is int ? json['number'] : int.tryParse(json['number'].toString()) ?? 10,
      characteristics: json['characteristics']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      icon: iconForRoles(roles),
      color: Color(json['color'] is int ? json['color'] : colorFromId(id).value),
      custom: true,
    );
  }
}
