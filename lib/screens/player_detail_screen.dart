import 'package:flutter/material.dart';
import '../models/player.dart';
import '../widgets/info_box.dart';
import '../widgets/player_image.dart';

class PlayerDetailScreen extends StatefulWidget {
  final Player player;
  final bool isFavorite;
  final VoidCallback onFavoriteChanged;
  const PlayerDetailScreen({super.key, required this.player, required this.isFavorite, required this.onFavoriteChanged});
  @override
  State<PlayerDetailScreen> createState() => _PlayerDetailScreenState();
}

class _PlayerDetailScreenState extends State<PlayerDetailScreen> {
  late bool favorite;
  @override
  void initState() { super.initState(); favorite = widget.isFavorite; }
  void changeFavorite() { setState(() => favorite = !favorite); widget.onFavoriteChanged(); }

  @override
  Widget build(BuildContext context) {
    final p = widget.player;
    return Scaffold(
      backgroundColor: const Color(0xffF5F8F2),
      appBar: AppBar(backgroundColor: Colors.green, foregroundColor: Colors.white, title: Text(p.name)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(22),
        child: Column(children: [
          PlayerImage(player: p, size: 160),
          const SizedBox(height: 22),
          Text(p.name, textAlign: TextAlign.center, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(p.country, style: const TextStyle(fontSize: 20, color: Colors.green, fontWeight: FontWeight.bold)),
          const SizedBox(height: 22),
          InfoBox(title: 'País', value: p.country), InfoBox(title: 'Clube', value: p.club), InfoBox(title: 'Camisa', value: p.number.toString()), InfoBox(title: 'Posição original', value: p.position), InfoBox(title: 'Funções no campo', value: p.roles.join(', ')), InfoBox(title: 'Características', value: p.characteristics),
          const SizedBox(height: 16),
          Card(elevation: 3, child: Padding(padding: const EdgeInsets.all(18), child: Text(p.description.isEmpty ? 'Sem descrição cadastrada.' : p.description, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, height: 1.4)))),
          const SizedBox(height: 24),
          SizedBox(width: double.infinity, height: 52, child: ElevatedButton.icon(onPressed: changeFavorite, icon: Icon(favorite ? Icons.favorite : Icons.favorite_border), label: Text(favorite ? 'Remover dos favoritos' : 'Adicionar aos favoritos'), style: ElevatedButton.styleFrom(backgroundColor: favorite ? Colors.red : Colors.blue, foregroundColor: Colors.white))),
        ]),
      ),
    );
  }
}
