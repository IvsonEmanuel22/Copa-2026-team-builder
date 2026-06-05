import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../data/formations_data.dart';
import '../services/storage_service.dart';
import '../services/validation_service.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final storage = StorageService();
  bool creatingAccount = false;
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  Uint8List? selectedImageBytes;
  String selectedImageBase64 = '';

  @override
  void initState() { super.initState(); checkSession(); }

  Future<void> checkSession() async {
    if (await storage.hasLoggedAccount() && mounted) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
    }
  }

  Future<void> pickImage() async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 70, maxWidth: 600, maxHeight: 600);
    if (image == null) return;
    final bytes = await image.readAsBytes();
    setState(() { selectedImageBytes = bytes; selectedImageBase64 = base64Encode(bytes); });
  }

  Future<void> createAccount() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim().toLowerCase();
    final password = passwordController.text.trim();
    if (name.isEmpty || email.isEmpty || password.isEmpty) return showMessage('Preencha nome, e-mail e senha.');
    if (!ValidationService.isValidEmail(email)) return showMessage('Use Gmail, Hotmail, Outlook ou outro provedor conhecido.');
    if (password.length < 4) return showMessage('A senha precisa ter pelo menos 4 caracteres.');
    await storage.saveAccount(name: name, email: email, password: password, imageBase64: selectedImageBase64);
    await storage.saveSelectedFormation(formations.first.name);
    if (!mounted) return;
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
  }

  Future<void> login() async {
    final email = emailController.text.trim().toLowerCase();
    final password = passwordController.text.trim();
    if (email.isEmpty || password.isEmpty) return showMessage('Preencha e-mail e senha.');
    if (!ValidationService.isValidEmail(email)) return showMessage('Digite um e-mail válido.');
    final success = await storage.login(email: email, password: password);
    if (!success) return showMessage('E-mail ou senha incorretos, ou conta inexistente.');
    if (!mounted) return;
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
  }

  void showMessage(String text) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));

  @override
  Widget build(BuildContext context) {
    final profileImage = selectedImageBytes == null ? null : MemoryImage(selectedImageBytes!);
    return Scaffold(
      backgroundColor: const Color(0xffF5F8F2),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(children: [
            const SizedBox(height: 24),
            const Icon(Icons.sports_soccer, size: 76, color: Colors.green),
            const SizedBox(height: 12),
            const Text('Copa Scout 2026', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.green)),
            const SizedBox(height: 8),
            Text(creatingAccount ? 'Crie sua conta para montar sua escalação.' : 'Entre na sua conta para continuar.', textAlign: TextAlign.center, style: const TextStyle(fontSize: 16)),
            if (creatingAccount) ...[
              const SizedBox(height: 26),
              GestureDetector(onTap: pickImage, child: CircleAvatar(radius: 62, backgroundColor: Colors.green.shade100, backgroundImage: profileImage, child: profileImage == null ? const Icon(Icons.add_a_photo, size: 40, color: Colors.green) : null)),
              const SizedBox(height: 8),
              const Text('Toque para escolher uma foto de perfil', style: TextStyle(color: Colors.black54)),
              const SizedBox(height: 18),
              TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Nome', prefixIcon: Icon(Icons.person), border: OutlineInputBorder())),
            ],
            const SizedBox(height: 14),
            TextField(controller: emailController, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: 'E-mail', hintText: 'exemplo@gmail.com', prefixIcon: Icon(Icons.email), border: OutlineInputBorder())),
            const SizedBox(height: 14),
            TextField(controller: passwordController, obscureText: true, decoration: const InputDecoration(labelText: 'Senha', prefixIcon: Icon(Icons.lock), border: OutlineInputBorder())),
            const SizedBox(height: 22),
            SizedBox(width: double.infinity, height: 52, child: ElevatedButton.icon(onPressed: creatingAccount ? createAccount : login, icon: Icon(creatingAccount ? Icons.person_add : Icons.login), label: Text(creatingAccount ? 'Criar conta' : 'Entrar'), style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white))),
            const SizedBox(height: 12),
            TextButton(onPressed: () => setState(() => creatingAccount = !creatingAccount), child: Text(creatingAccount ? 'Já tenho conta' : 'Não tenho conta. Criar agora')),
          ]),
        ),
      ),
    );
  }
}
