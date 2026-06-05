import 'package:flutter/material.dart';
import '../models/player.dart';
import 'player_image.dart';

class PlayerCard extends StatelessWidget {
  final Player player;
  final bool isFavorite;
  final VoidCallback onOpen;
  final VoidCallback onFavorite;
  final VoidCallback onGoToLineup;
  const PlayerCard({super.key, required this.player, required this.isFavorite, required this.onOpen, required this.onFavorite, required this.onGoToLineup});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12), elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(children: [
          PlayerImage(player: player, size: 76),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [Expanded(child: Text(player.name, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold))), if (player.custom) const Chip(label: Text('Criado'), visualDensity: VisualDensity.compact)]),
            Text('${player.country} • ${player.position}'),
            Text('Clube: ${player.club}'),
            Text('Camisa: ${player.number}'),
            const SizedBox(height: 6),
            Chip(label: Text('Funções: ${player.roles.join(', ')}'), backgroundColor: Colors.green.shade100),
            Wrap(spacing: 8, runSpacing: 4, children: [
              ElevatedButton(onPressed: onOpen, child: const Text('Detalhes')),
              ElevatedButton.icon(onPressed: onGoToLineup, icon: const Icon(Icons.stadium), label: const Text('Escalação'), style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white)),
              IconButton(onPressed: onFavorite, icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border, color: isFavorite ? Colors.red : Colors.grey)),
            ]),
          ])),
        ]),
      ),
    );
  }
}
