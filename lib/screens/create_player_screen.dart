import 'package:flutter/material.dart';
import '../models/player.dart';
import '../utils/app_utils.dart';

class CreatePlayerScreen extends StatefulWidget {
  const CreatePlayerScreen({super.key});
  @override
  State<CreatePlayerScreen> createState() => _CreatePlayerScreenState();
}

class _CreatePlayerScreenState extends State<CreatePlayerScreen> {
  final nameController = TextEditingController();
  final countryController = TextEditingController();
  final clubController = TextEditingController();
  final numberController = TextEditingController();
  final characteristicsController = TextEditingController();
  final descriptionController = TextEditingController();
  String selectedPosition = 'Meio-campista';
  final Set<String> selectedRoles = {'CM'};
  final positionOptions = ['Goleiro', 'Lateral direito', 'Lateral esquerdo', 'Zagueiro', 'Volante', 'Meio-campista', 'Meia ofensivo', 'Ponta esquerda', 'Ponta direita', 'Centroavante'];
  final roleOptions = ['GK', 'RB', 'CB', 'LB', 'RWB', 'LWB', 'CDM', 'CM', 'CAM', 'LM', 'RM', 'LW', 'RW', 'ST'];

  void savePlayer() {
    final name = nameController.text.trim();
    final country = countryController.text.trim();
    final club = clubController.text.trim();
    final number = int.tryParse(numberController.text.trim());
    if (name.isEmpty || country.isEmpty || club.isEmpty || number == null) return showMessage('Preencha nome, país, clube e número.');
    if (number < 0 || number > 99) return showMessage('Número entre 0 e 99.');
    if (selectedRoles.isEmpty) return showMessage('Escolha pelo menos uma função.');
    final roles = selectedRoles.toList();
    final id = DateTime.now().millisecondsSinceEpoch;
    Navigator.pop(context, Player(id: id, name: name, country: country, position: selectedPosition, roles: roles, club: club, number: number, characteristics: characteristicsController.text.trim(), description: descriptionController.text.trim(), icon: iconForRoles(roles), color: colorFromId(id), custom: true));
  }

  void showMessage(String text) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F8F2),
      appBar: AppBar(backgroundColor: Colors.green, foregroundColor: Colors.white, title: const Text('Criar jogador')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(children: [
          const Text('Cadastre seu próprio jogador', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 18),
          TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Nome do jogador', border: OutlineInputBorder())),
          const SizedBox(height: 12),
          TextField(controller: countryController, decoration: const InputDecoration(labelText: 'País', border: OutlineInputBorder())),
          const SizedBox(height: 12),
          TextField(controller: clubController, decoration: const InputDecoration(labelText: 'Clube', border: OutlineInputBorder())),
          const SizedBox(height: 12),
          TextField(controller: numberController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Número da camisa', border: OutlineInputBorder())),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(value: selectedPosition, decoration: const InputDecoration(labelText: 'Posição principal', border: OutlineInputBorder()), items: positionOptions.map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(), onChanged: (v) => setState(() => selectedPosition = v ?? selectedPosition)),
          const SizedBox(height: 16),
          const Align(alignment: Alignment.centerLeft, child: Text('Funções no campo', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
          const SizedBox(height: 8),
          Wrap(spacing: 8, runSpacing: 8, children: roleOptions.map((role) => FilterChip(label: Text(role), selected: selectedRoles.contains(role), onSelected: (v) => setState(() => v ? selectedRoles.add(role) : selectedRoles.remove(role)))).toList()),
          const SizedBox(height: 16),
          TextField(controller: characteristicsController, maxLines: 2, decoration: const InputDecoration(labelText: 'Características', hintText: 'Ex: rápido, bom passe...', border: OutlineInputBorder())),
          const SizedBox(height: 12),
          TextField(controller: descriptionController, maxLines: 4, decoration: const InputDecoration(labelText: 'Descrição', border: OutlineInputBorder())),
          const SizedBox(height: 22),
          SizedBox(width: double.infinity, height: 52, child: ElevatedButton.icon(onPressed: savePlayer, icon: const Icon(Icons.save), label: const Text('Salvar jogador'), style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white))),
        ]),
      ),
    );
  }
}
