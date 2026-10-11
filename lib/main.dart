import 'package:flutter/material.dart';
import 'screens/ilan_listesi.dart';

void main() {
  runApp(const KariyerApp());
}

class KariyerApp extends StatelessWidget {
  const KariyerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kariyer Kapısı Takip',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2563EB),
          brightness: Brightness.light,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF3B82F6),
          brightness: Brightness.dark,
        ),
      ),
      themeMode: ThemeMode.system,
      home: const IlanListesiEkrani(),
    );
  }
}