import 'package:flutter/material.dart';

class BosDurum extends StatelessWidget {
  final String mesaj;
  final VoidCallback? onPressed;
  const BosDurum({super.key, required this.mesaj, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Icon(Icons.dashboard, size: 64),
          const SizedBox(height: 12),
          Text(mesaj, textAlign: TextAlign.center),
          if (onPressed != null) ...<Widget>[
            const SizedBox(height: 16),
            ElevatedButton(onPressed: onPressed, child: const Text('Oluştur')),
          ],
        ],
      ),
    );
  }
}
