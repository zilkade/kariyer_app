import 'package:shared_preferences/shared_preferences.dart';

/// Kullanıcıya özel veriler — cihazda saklanır.
///
/// İçerik:
///   • Favoriler
///   • İncelediklerim (okundu)
///
/// Hesap sistemi eklenene kadar bu veriler sunucuya gönderilmez.
/// Her cihaz kendi listesini tutar.
class KullaniciVerisi {
  static const String _favoriKey = 'favoriler';
  static const String _okunduKey = 'okunan_ilanlar';
  static const int _maxKayit = 500; // şişmesin

  // ============================================================
  // FAVORİLER
  // ============================================================
  static Future<Set<String>> favoriler() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList(_favoriKey) ?? []).toSet();
  }

  static Future<bool> favoriMi(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final liste = prefs.getStringList(_favoriKey) ?? [];
    return liste.contains(id);
  }

  /// Favori durumunu değiştir — yeni değeri döndürür (true = favori)
  static Future<bool> favoriDegistir(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final liste = prefs.getStringList(_favoriKey) ?? [];
    final vardi = liste.contains(id);

    if (vardi) {
      liste.remove(id);
    } else {
      liste.add(id);
      if (liste.length > _maxKayit) {
        liste.removeRange(0, liste.length - _maxKayit);
      }
    }
    await prefs.setStringList(_favoriKey, liste);
    return !vardi;
  }

  static Future<int> favoriSayisi() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList(_favoriKey) ?? []).length;
  }

  // ============================================================
  // İNCELEDİKLERİM (okundu)
  // ============================================================
  static Future<Set<String>> incelenenler() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList(_okunduKey) ?? []).toSet();
  }

  static Future<bool> incelendiMi(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final liste = prefs.getStringList(_okunduKey) ?? [];
    return liste.contains(id);
  }

  static Future<void> incelendiIsaretle(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final liste = prefs.getStringList(_okunduKey) ?? [];
    if (!liste.contains(id)) {
      liste.add(id);
      if (liste.length > _maxKayit) {
        liste.removeRange(0, liste.length - _maxKayit);
      }
      await prefs.setStringList(_okunduKey, liste);
    }
  }

  static Future<int> incelenenSayisi() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList(_okunduKey) ?? []).length;
  }

  // ============================================================
  // TEMİZLİK
  // ============================================================
  static Future<void> favorileriTemizle() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_favoriKey);
  }

  static Future<void> incelenenleriTemizle() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_okunduKey);
  }

  static Future<void> hepsiniTemizle() async {
    await favorileriTemizle();
    await incelenenleriTemizle();
  }
}