import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import '../data/default_players.dart';
import '../data/formations_data.dart';
import '../models/formation.dart';
import '../models/player.dart';
import '../services/storage_service.dart';
import '../widgets/mini_field.dart';
import '../widgets/player_card.dart';
import '../widgets/player_image.dart';
import 'create_player_screen.dart';
import 'login_screen.dart';
import 'player_detail_screen.dart';

enum ScreenPage { players, lineup, favorites, profile }

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final storage = StorageService();
  ScreenPage currentPage = ScreenPage.players;
  String userName = '', userEmail = '', profileImageBase64 = '';
  final searchController = TextEditingController();
  List<Player> customPlayers = [];
  List<int> favoriteIds = [];
  Map<int, int> lineupAssignments = {};
  String selectedFormationName = formations.first.name;
  List<Player> filteredPlayers = [];
  StreamSubscription<AccelerometerEvent>? accelerometerSubscription;
  DateTime lastShake = DateTime.now();

  List<Player> get allPlayers => [...defaultPlayers, ...customPlayers];
  Formation get selectedFormation => formations.firstWhere((f) => f.name == selectedFormationName, orElse: () => formations.first);

  @override
  void initState() { super.initState(); filteredPlayers = allPlayers; loadUserData(); startSensor(); }
  @override
  void dispose() { accelerometerSubscription?.cancel(); searchController.dispose(); super.dispose(); }

  Future<void> loadUserData() async {
    final user = await storage.loadUser();
    final loadedCustom = await storage.loadCustomPlayers();
    final loadedFavs = await storage.loadFavorites();
    final savedFormation = await storage.loadSelectedFormation() ?? formations.first.name;
    final validFormation = formations.any((f) => f.name == savedFormation) ? savedFormation : formations.first.name;
    final loadedLineup = await storage.loadLineup(validFormation);
    setState(() {
      userName = user['name'] ?? '';
      userEmail = user['email'] ?? '';
      profileImageBase64 = user['image'] ?? '';
      customPlayers = loadedCustom;
      favoriteIds = loadedFavs;
      selectedFormationName = validFormation;
      lineupAssignments = cleanLineup(validFormation, loadedLineup, [...defaultPlayers, ...loadedCustom]);
      filteredPlayers = allPlayers;
    });
  }

  Map<int, int> cleanLineup(String formationName, Map<int, int> assignments, List<Player> sourcePlayers) {
    final formation = formations.firstWhere((f) => f.name == formationName, orElse: () => formations.first);
    final validIds = sourcePlayers.map((p) => p.id).toSet();
    final cleaned = <int, int>{};
    for (final e in assignments.entries) {
      if (e.key >= 0 && e.key < formation.slots.length && validIds.contains(e.value)) cleaned[e.key] = e.value;
    }
    return cleaned;
  }

  Uint8List? getProfileBytes() {
    if (profileImageBase64.isEmpty) return null;
    try { return base64Decode(profileImageBase64); } catch (_) { return null; }
  }

  Player? findPlayerById(int id) {
    try { return allPlayers.firstWhere((p) => p.id == id); } catch (_) { return null; }
  }

  bool isCompatible(Player player, TacticalSlot slot) {
    if (player.roles.contains(slot.code)) return true;
    if (slot.code == 'LM' && player.roles.any((r) => ['LW','LM','CAM','CM'].contains(r))) return true;
    if (slot.code == 'RM' && player.roles.any((r) => ['RW','RM','CAM','CM'].contains(r))) return true;
    if (slot.code == 'LWB' && player.roles.any((r) => ['LB','LWB','LW'].contains(r))) return true;
    if (slot.code == 'RWB' && player.roles.any((r) => ['RB','RWB','RW'].contains(r))) return true;
    if (slot.code == 'CM' && player.roles.any((r) => ['CM','CDM','CAM'].contains(r))) return true;
    if (slot.code == 'CAM' && player.roles.any((r) => ['CAM','CM','LW','RW'].contains(r))) return true;
    return false;
  }

  List<Player> compatiblePlayers(TacticalSlot slot) => allPlayers.where((p) => isCompatible(p, slot)).toList();

  void toggleFavorite(Player player) {
    setState(() {
      favoriteIds.contains(player.id) ? favoriteIds.remove(player.id) : favoriteIds.add(player.id);
    });
    storage.saveFavorites(favoriteIds);
  }

  void startSensor() {
    try {
      accelerometerSubscription = accelerometerEventStream().listen((event) {
        final force = sqrt(event.x * event.x + event.y * event.y + event.z * event.z);
        final now = DateTime.now();
        if (force > 18 && now.difference(lastShake).inSeconds >= 2 && currentPage == ScreenPage.lineup) {
          lastShake = now;
          randomizeLineup();
        }
      }, onError: (_) => showMessage('Sensor indisponível neste dispositivo.'));
    } catch (_) {}
  }

  Future<void> changeFormation(String? name) async {
    if (name == null) return;
    await saveLineup();
    final loaded = await storage.loadLineup(name);
    setState(() {
      selectedFormationName = name;
      lineupAssignments = cleanLineup(name, loaded, allPlayers);
    });
    await storage.saveSelectedFormation(name);
    showMessage('Esquema $name carregado.');
  }

  Future<void> saveLineup() async => storage.saveLineup(selectedFormationName, lineupAssignments);

  void randomizeLineup() {
    final random = Random();
    final formation = formations[random.nextInt(formations.length)];
    final newAssignments = <int, int>{};
    final used = <int>{};
    for (int i = 0; i < formation.slots.length; i++) {
      final candidates = allPlayers.where((p) => isCompatible(p, formation.slots[i]) && !used.contains(p.id)).toList();
      if (candidates.isEmpty) continue;
      final selected = candidates[random.nextInt(candidates.length)];
      newAssignments[i] = selected.id;
      used.add(selected.id);
    }
    setState(() { selectedFormationName = formation.name; lineupAssignments = newAssignments; });
    saveLineup();
    showMessage('Formação ${formation.name} aleatorizada.');
  }

  void openSlotPicker(int slotIndex) {
    final slot = selectedFormation.slots[slotIndex];
    final assigned = lineupAssignments[slotIndex];
    final used = lineupAssignments.values.toSet();
    final available = compatiblePlayers(slot).where((p) => !used.contains(p.id) || p.id == assigned).toList();
    showModalBottomSheet(context: context, builder: (_) => SafeArea(child: Padding(
      padding: const EdgeInsets.all(14),
      child: Column(children: [
        Text('Escolher jogador para ${slot.code} - ${slot.label}', textAlign: TextAlign.center, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
        if (assigned != null) ListTile(leading: const Icon(Icons.close, color: Colors.red), title: const Text('Remover jogador desta posição'), onTap: () { Navigator.pop(context); removePlayerFromSlot(slotIndex); }),
        Expanded(child: available.isEmpty ? const Center(child: Text('Nenhum jogador compatível disponível.')) : ListView.builder(itemCount: available.length, itemBuilder: (_, i) {
          final p = available[i];
          return Card(child: ListTile(leading: PlayerImage(player: p, size: 42), title: Text(p.name), subtitle: Text('${p.country} • ${p.position}'), trailing: assigned == p.id ? const Icon(Icons.check, color: Colors.green) : null, onTap: () { Navigator.pop(context); assignPlayerToSlot(slotIndex, p); }));
        })),
      ]),
    )));
  }

  void assignPlayerToSlot(int slotIndex, Player player) { setState(() => lineupAssignments[slotIndex] = player.id); saveLineup(); }
  void removePlayerFromSlot(int slotIndex) { setState(() => lineupAssignments.remove(slotIndex)); saveLineup(); }
  void clearLineup() { setState(() => lineupAssignments.clear()); saveLineup(); showMessage('Escalação limpa.'); }

  void confirmLineup() {
    if (lineupAssignments.isEmpty) return showMessage('Você não pode confirmar com o campo vazio.');
    if (lineupAssignments.length < 11) return showMessage('Complete os 11 jogadores antes de confirmar.');
    saveLineup();
    showDialog(context: context, builder: (_) => AlertDialog(title: const Text('Escalação salva'), content: Text('Sua escalação no esquema $selectedFormationName foi salva.'), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Fechar'))]));
  }

  void filterPlayers(String text) {
    final q = text.toLowerCase();
    setState(() => filteredPlayers = allPlayers.where((p) => p.name.toLowerCase().contains(q) || p.country.toLowerCase().contains(q) || p.position.toLowerCase().contains(q) || p.club.toLowerCase().contains(q) || p.roles.join(' ').toLowerCase().contains(q)).toList());
  }

  void openDetails(Player player) => Navigator.push(context, MaterialPageRoute(builder: (_) => PlayerDetailScreen(player: player, isFavorite: favoriteIds.contains(player.id), onFavoriteChanged: () => toggleFavorite(player))));

  Future<void> openCreatePlayer() async {
    final newPlayer = await Navigator.push<Player>(context, MaterialPageRoute(builder: (_) => const CreatePlayerScreen()));
    if (newPlayer == null) return;
    setState(() { customPlayers.add(newPlayer); filteredPlayers = allPlayers; searchController.clear(); });
    await storage.saveCustomPlayers(customPlayers);
    showMessage('${newPlayer.name} criado.');
  }

  Future<void> logout() async { await storage.logout(); if (!mounted) return; Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen())); }
  void showMessage(String text) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text))); }

  Widget buildProfileAvatar({double radius = 28}) {
    final bytes = getProfileBytes();
    return CircleAvatar(radius: radius, backgroundColor: Colors.green.shade100, backgroundImage: bytes != null ? MemoryImage(bytes) : null, child: bytes == null ? Icon(Icons.person, size: radius, color: Colors.green) : null);
  }

  Widget buildHeader() => Container(width: double.infinity, padding: const EdgeInsets.all(14), color: Colors.green.shade100, child: Row(children: [buildProfileAvatar(radius: 30), const SizedBox(width: 12), Expanded(child: Text('Olá, $userName!\nNa aba Escalação, balance o celular para aleatorizar.', style: const TextStyle(fontWeight: FontWeight.w600)))]));

  Widget buildBody() {
    if (currentPage == ScreenPage.players) return buildPlayersPage(filteredPlayers);
    if (currentPage == ScreenPage.lineup) return buildLineupPage();
    if (currentPage == ScreenPage.favorites) return buildPlayersPage(allPlayers.where((p) => favoriteIds.contains(p.id)).toList(), showSearch: false);
    return buildProfilePage();
  }

  Widget buildPlayersPage(List<Player> list, {bool showSearch = true}) => Column(children: [
    if (showSearch) Padding(padding: const EdgeInsets.all(12), child: TextField(controller: searchController, onChanged: filterPlayers, decoration: const InputDecoration(labelText: 'Pesquisar jogador, país, posição, clube ou função', prefixIcon: Icon(Icons.search), border: OutlineInputBorder()))),
    Padding(padding: const EdgeInsets.symmetric(horizontal: 12), child: SizedBox(width: double.infinity, height: 48, child: ElevatedButton.icon(onPressed: openCreatePlayer, icon: const Icon(Icons.person_add), label: const Text('Criar jogador personalizado'), style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white)))),
    const SizedBox(height: 8),
    Expanded(child: list.isEmpty ? const Center(child: Text('Nenhum jogador encontrado.')) : ListView.builder(padding: const EdgeInsets.all(12), itemCount: list.length, itemBuilder: (_, i) { final p = list[i]; return PlayerCard(player: p, isFavorite: favoriteIds.contains(p.id), onOpen: () => openDetails(p), onFavorite: () => toggleFavorite(p), onGoToLineup: () => setState(() => currentPage = ScreenPage.lineup)); })),
  ]);

  Widget buildLineupPage() => SingleChildScrollView(padding: const EdgeInsets.all(14), child: Column(children: [
    Row(children: [Expanded(child: Text('Escalação: ${lineupAssignments.length}/11', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold))), TextButton.icon(onPressed: clearLineup, icon: const Icon(Icons.delete), label: const Text('Limpar'))]),
    const SizedBox(height: 10),
    DropdownButtonFormField<String>(value: selectedFormationName, decoration: const InputDecoration(labelText: 'Esquema tático', border: OutlineInputBorder()), items: formations.map((f) => DropdownMenuItem(value: f.name, child: Text(f.name))).toList(), onChanged: changeFormation),
    const SizedBox(height: 12),
    SizedBox(width: double.infinity, height: 50, child: ElevatedButton.icon(onPressed: randomizeLineup, icon: const Icon(Icons.shuffle), label: const Text('Aleatorizar formação e jogadores'), style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white))),
    const SizedBox(height: 12),
    MiniField(formation: selectedFormation, assignments: lineupAssignments, players: allPlayers, onTapSlot: openSlotPicker),
    const SizedBox(height: 18),
    SizedBox(width: double.infinity, height: 52, child: ElevatedButton.icon(onPressed: confirmLineup, icon: const Icon(Icons.save), label: const Text('Confirmar e salvar escalação'), style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white))),
  ]));

  Widget buildProfilePage() => Center(child: SingleChildScrollView(padding: const EdgeInsets.all(24), child: Column(children: [
    buildProfileAvatar(radius: 75), const SizedBox(height: 18), Text(userName, textAlign: TextAlign.center, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)), const SizedBox(height: 6), Text(userEmail, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, color: Colors.black54)), const SizedBox(height: 18),
    Text('Jogadores disponíveis: ${allPlayers.length}'), const SizedBox(height: 8), Text('Jogadores criados: ${customPlayers.length}'), const SizedBox(height: 8), Text('Favoritos salvos: ${favoriteIds.length}'), const SizedBox(height: 8), Text('Jogadores escalados em $selectedFormationName: ${lineupAssignments.length}/11', textAlign: TextAlign.center),
    const SizedBox(height: 28), SizedBox(width: double.infinity, height: 52, child: ElevatedButton.icon(onPressed: logout, icon: const Icon(Icons.logout), label: const Text('Sair da conta'), style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white))),
  ])));

  String getTitle() => currentPage == ScreenPage.players ? 'Jogadores da Copa' : currentPage == ScreenPage.lineup ? 'Escalação' : currentPage == ScreenPage.favorites ? 'Favoritos' : 'Perfil';

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xffF5F8F2),
    appBar: AppBar(backgroundColor: Colors.green, foregroundColor: Colors.white, title: Text(getTitle())),
    body: Column(children: [buildHeader(), Expanded(child: buildBody())]),
    bottomNavigationBar: NavigationBar(selectedIndex: currentPage.index, onDestinationSelected: (i) => setState(() => currentPage = ScreenPage.values[i]), destinations: const [
      NavigationDestination(icon: Icon(Icons.sports_soccer), label: 'Jogadores'),
      NavigationDestination(icon: Icon(Icons.stadium), label: 'Escalação'),
      NavigationDestination(icon: Icon(Icons.favorite), label: 'Favoritos'),
      NavigationDestination(icon: Icon(Icons.person), label: 'Perfil'),
    ]),
  );
}
