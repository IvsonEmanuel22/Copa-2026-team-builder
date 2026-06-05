import 'package:flutter/material.dart';

class TacticalSlot {
  final String code;
  final String label;
  final Alignment alignment;

  const TacticalSlot({
    required this.code,
    required this.label,
    required this.alignment,
  });
}

class Formation {
  final String name;
  final List<TacticalSlot> slots;

  const Formation({
    required this.name,
    required this.slots,
  });
}
