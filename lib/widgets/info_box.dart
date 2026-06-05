import 'package:flutter/material.dart';

class InfoBox extends StatelessWidget {
  final String title;
  final String value;
  const InfoBox({super.key, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        title: Text(title),
        trailing: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 190),
          child: Text(value.isEmpty ? 'Não informado' : value, textAlign: TextAlign.end, style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}
