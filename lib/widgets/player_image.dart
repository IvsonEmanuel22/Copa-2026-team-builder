import 'package:flutter/material.dart';
import '../models/player.dart';

class PlayerImage extends StatelessWidget {
  final Player player;
  final double size;
  const PlayerImage({super.key, required this.player, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: player.color.withOpacity(0.15), borderRadius: BorderRadius.circular(18), border: Border.all(color: player.color, width: 2)),
      child: Icon(player.icon, size: size * 0.48, color: player.color),
    );
  }
}
