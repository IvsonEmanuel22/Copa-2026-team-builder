import 'package:flutter/material.dart';
import '../models/formation.dart';
import '../models/player.dart';
import 'field_painter.dart';

class MiniField extends StatelessWidget {
  final Formation formation;
  final Map<int, int> assignments;
  final List<Player> players;
  final void Function(int slotIndex) onTapSlot;
  const MiniField({super.key, required this.formation, required this.assignments, required this.players, required this.onTapSlot});

  Player? findPlayerById(int id) {
    try { return players.firstWhere((p) => p.id == id); } catch (_) { return null; }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 430),
        child: AspectRatio(
          aspectRatio: .78,
          child: Container(
            decoration: BoxDecoration(color: Colors.green.shade700, borderRadius: BorderRadius.circular(18), border: Border.all(color: Colors.white, width: 3)),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: LayoutBuilder(builder: (context, c) {
                return Stack(children: [
                  Positioned.fill(child: CustomPaint(painter: FieldPainter())),
                  ...List.generate(formation.slots.length, (i) {
                    final slot = formation.slots[i];
                    final player = assignments[i] == null ? null : findPlayerById(assignments[i]!);
                    const w = 82.0, h = 78.0;
                    final left = ((slot.alignment.x + 1) / 2) * c.maxWidth - w / 2;
                    final top = ((slot.alignment.y + 1) / 2) * c.maxHeight - h / 2;
                    return Positioned(
                      left: left.clamp(4.0, c.maxWidth - w - 4).toDouble(),
                      top: top.clamp(4.0, c.maxHeight - h - 4).toDouble(),
                      child: GestureDetector(
                        onTap: () => onTapSlot(i),
                        child: SizedBox(width: w, height: h, child: Column(children: [
                          CircleAvatar(radius: 22, backgroundColor: player == null ? Colors.white.withOpacity(.75) : Colors.white, child: player == null ? Text(slot.code, style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 11)) : Icon(player.icon, color: player.color, size: 23)),
                          const SizedBox(height: 3),
                          Container(width: 78, padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3), decoration: BoxDecoration(color: Colors.black.withOpacity(.55), borderRadius: BorderRadius.circular(8)), child: Text(player == null ? slot.label : player.name, textAlign: TextAlign.center, overflow: TextOverflow.ellipsis, maxLines: 1, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold))),
                        ])),
                      ),
                    );
                  }),
                ]);
              }),
            ),
          ),
        ),
      ),
    );
  }
}
