import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/ilan.dart';

class ApiService {
  // Kendi sunucumuz — Cloudflare Tunnel üzerinden 7/24 çalışır
  static const String baseUrl = 'https://api.esles.me';

  static Future<List<Ilan>> ilanlariGetir({
    String arama = '',
    String kategori = 'Tümü',
    String kpssTur = 'Tümü',
    bool sadeceYeni = false,
    bool sadeceAktif = true,
    bool sadeceKpss = false,
    bool sadeceFavori = false,
    String siralama = 'Yayın tarihi',
    int limit = 500,
  }) async {
    final params = {
      'arama': arama,
      'kategori': kategori,
      'kpss_tur': kpssTur,
      'sadece_yeni': sadeceYeni.toString(),
      'sadece_aktif': sadeceAktif.toString(),
      'sadece_kpss': sadeceKpss.toString(),
      'sadece_favori': sadeceFavori.toString(),
      'siralama': siralama,
      'limit': limit.toString(),
    };
    final uri = Uri.parse('$baseUrl/ilanlar').replace(queryParameters: params);
    final resp = await http.get(uri).timeout(const Duration(seconds: 30));

    if (resp.statusCode != 200) {
      throw Exception('Sunucu hatası: ${resp.statusCode}');
    }

    final List<dynamic> veri = json.decode(utf8.decode(resp.bodyBytes));
    return veri.map((e) => Ilan.fromJson(e as Map<String, dynamic>)).toList();
  }

  static Future<Map<String, dynamic>> ilanDetay(String id, {bool taze = false}) async {
    final uri = Uri.parse('$baseUrl/ilan/$id?taze=$taze');
    final resp = await http.get(uri).timeout(const Duration(seconds: 60));
    if (resp.statusCode != 200) {
      throw Exception('Detay alınamadı: ${resp.statusCode}');
    }
    return json.decode(utf8.decode(resp.bodyBytes)) as Map<String, dynamic>;
  }

  static Future<bool> favoriDegistir(String id) async {
    final uri = Uri.parse('$baseUrl/ilan/$id/favori');
    final resp = await http.post(uri).timeout(const Duration(seconds: 30));
    if (resp.statusCode != 200) return false;
    final data = json.decode(utf8.decode(resp.bodyBytes));
    return data['success'] == true;
  }

  static Future<Map<String, dynamic>> istatistik() async {
    final uri = Uri.parse('$baseUrl/istatistik');
    final resp = await http.get(uri).timeout(const Duration(seconds: 30));
    if (resp.statusCode != 200) throw Exception('İstatistik alınamadı');
    return json.decode(utf8.decode(resp.bodyBytes)) as Map<String, dynamic>;
  }

  static Future<List<String>> kategoriler() async {
    final uri = Uri.parse('$baseUrl/kategoriler');
    final resp = await http.get(uri).timeout(const Duration(seconds: 30));
    if (resp.statusCode != 200) throw Exception('Kategoriler alınamadı');
    final List<dynamic> data = json.decode(utf8.decode(resp.bodyBytes));
    return data.map((e) => e.toString()).toList();
  }
}