import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/ilan_listesi.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const KariyerApp());
}

class KariyerApp extends StatefulWidget {
  const KariyerApp({super.key});

  @override
  State<KariyerApp> createState() => _KariyerAppState();
}

class _KariyerAppState extends State<KariyerApp> {
  ThemeMode _tema = ThemeMode.system;

  @override
  void initState() {
    super.initState();
    _temaYukle();
  }

  Future<void> _temaYukle() async {
    final prefs = await SharedPreferences.getInstance();
    final kayitli = prefs.getString('tema') ?? 'system';
    if (!mounted) return;
    setState(() => _tema = _parse(kayitli));
  }

  ThemeMode _parse(String s) => switch (s) {
        'light' => ThemeMode.light,
        'dark' => ThemeMode.dark,
        _ => ThemeMode.system,
      };

  String _toStr(ThemeMode m) => switch (m) {
        ThemeMode.light => 'light',
        ThemeMode.dark => 'dark',
        ThemeMode.system => 'system',
      };

  Future<void> _temaDegistir(ThemeMode yeni) async {
    setState(() => _tema = yeni);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('tema', _toStr(yeni));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Eşleş',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: _tema,
      home: IlanListesiEkrani(
        onTemaDegistir: _temaDegistir,
        mevcutTema: _tema,
      ),
    );
  }
}