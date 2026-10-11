import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/ilan.dart';
import '../services/api_service.dart';

class IlanDetayEkrani extends StatefulWidget {
  final Ilan ilan;
  const IlanDetayEkrani({super.key, required this.ilan});

  @override
  State<IlanDetayEkrani> createState() => _IlanDetayEkraniState();
}

class _IlanDetayEkraniState extends State<IlanDetayEkrani> {
  Map<String, dynamic>? _detay;
  bool _detayYukleniyor = true;
  String? _detayHata;

  @override
  void initState() {
    super.initState();
    _detayYukle();
  }

  Future<void> _detayYukle() async {
    setState(() {
      _detayYukleniyor = true;
      _detayHata = null;
    });

    // 3 kez dene, her başarısız denemede 5 sn ara ver
    for (int deneme = 1; deneme <= 3; deneme++) {
      try {
        final d = await ApiService.ilanDetay(widget.ilan.id);
        if (!mounted) return;
        setState(() {
          _detay = d;
          _detayYukleniyor = false;
        });
        return;
      } catch (e) {
        if (deneme < 3) {
          await Future.delayed(const Duration(seconds: 5));
          continue;
        }
        if (!mounted) return;
        setState(() {
          _detayHata = e.toString();
          _detayYukleniyor = false;
        });
      }
    }
  }

  Future<void> _linkAc(String url) async {
    if (url.isEmpty) return;
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ilan = widget.ilan;
    final basvuru = _detay?['basvuru_durumu'] as String?;

    return Scaffold(
      appBar: AppBar(title: const Text('İlan Detayı')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ---- ANA BİLGİLER (anında gösterilir, listeden gelir) ----
          Row(
            children: [
              if (ilan.yeniMi)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'YENİ',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              Expanded(
                child: Text(
                  ilan.kurum,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                ),
              ),
              IconButton(
                icon: Icon(
                  ilan.favoriMi ? Icons.star : Icons.star_border,
                  color: ilan.favoriMi ? Colors.amber : Colors.grey,
                ),
                onPressed: () async {
                  final ok = await ApiService.favoriDegistir(ilan.id);
                  if (!context.mounted) return;
                  if (ok) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Favori güncellendi'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                    Navigator.pop(context);
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            ilan.baslik,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          // ---- CHIP'LER ----
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              if (ilan.tarihGoster.isNotEmpty)
                Chip(
                  avatar: const Icon(Icons.calendar_today, size: 16),
                  label: Text('Yayın: ${ilan.tarihGoster}'),
                ),
              if (ilan.bitGoster.isNotEmpty)
                Chip(
                  avatar: const Icon(Icons.timer_outlined, size: 16),
                  label: Text('Son: ${ilan.bitGoster}'),
                ),
              if (ilan.kalanGun != null && ilan.kalanGun! >= 0)
                Chip(
                  avatar: const Icon(Icons.hourglass_bottom, size: 16),
                  label: Text('${ilan.kalanGun} gün kaldı'),
                  backgroundColor: ilan.kalanGun! <= 3
                      ? Colors.red.shade50
                      : Colors.orange.shade50,
                ),
              if (ilan.kpssTurleri.isNotEmpty)
                Chip(
                  avatar: const Icon(Icons.school, size: 16),
                  label: Text('KPSS ${ilan.kpssTurleri}'),
                  backgroundColor: Colors.green.shade50,
                ),
            ],
          ),
          const SizedBox(height: 16),

          // ---- BAŞVURU DURUMU (detay geldiyse) ----
          if (basvuru != null && basvuru.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.blue),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(basvuru,
                        style: const TextStyle(fontSize: 14)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // ---- ANA AKSİYON: BAŞVUR ----
          if (ilan.link.isNotEmpty)
            ElevatedButton.icon(
              onPressed: () => _linkAc(ilan.link),
              icon: const Icon(Icons.open_in_new),
              label: const Text('İlan Sayfasını Aç'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
                backgroundColor: Colors.green.shade600,
                foregroundColor: Colors.white,
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 8),

          // ---- İLAN METNİ (arka planda yüklenir) ----
          const Text(
            'İlan Metni',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          if (_detayYukleniyor)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 12),
                  Text(
                    'İlan metni yükleniyor...',
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '(Birkaç saniye sürebilir)',
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            )
          else if (_detayHata != null)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  const Icon(Icons.info_outline,
                      color: Colors.orange, size: 32),
                  const SizedBox(height: 8),
                  const Text(
                    'İlan metni yüklenemedi',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Yukarıdaki "İlan Sayfasını Aç" butonundan\ndetayları görebilirsiniz.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                  ),
                  const SizedBox(height: 12),
                  TextButton.icon(
                    onPressed: _detayYukle,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Tekrar Dene'),
                  ),
                ],
              ),
            )
          else if (_detay != null && _detay!['detay'] != null)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Text(
                _ilanMetni(_detay!['detay']),
                style: const TextStyle(fontSize: 14, height: 1.6),
              ),
            )
          else
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'İlan metni bulunamadı.',
                style: TextStyle(color: Colors.grey),
              ),
            ),
        ],
      ),
    );
  }

  /// Kariyer Kapısı'nın döndürdüğü metin BBCode + HTML karışımı.
  /// Bu fonksiyon ikisini de temizleyip düz metin döndürür.
  String _ilanMetni(dynamic detay) {
    try {
      if (detay is Map) {
        final govde = detay['govde'] ?? detay;
        if (govde is Map && govde['ilanMetni'] != null) {
          String metin = govde['ilanMetni'].toString();

          // ---- 1) BBCode basit tag'leri temizle ----
          // [b] [/b]  [i]  [u]  [s]  [justify]  [left]  [right]  [center]
          // [quote]  [code]  [list]  [*]
          metin = metin.replaceAll(
            RegExp(
              r'\[/?(b|i|u|s|justify|left|right|center|quote|code|list|\*)[^\]]*\]',
              caseSensitive: false,
            ),
            '',
          );

          // ---- 2) BBCode nitelikli tag'ler: [size=14pt] [color=red] [font=...] ----
          metin = metin.replaceAll(
            RegExp(
              r'\[(size|color|font)=[^\]]*\]',
              caseSensitive: false,
            ),
            '',
          );

          // ---- 3) BBCode link tag'leri: [url=...]metin[/url] → metin ----
          metin = metin.replaceAll(
            RegExp(
              r'\[url=[^\]]*\]([^\[]*)\[/url\]',
              caseSensitive: false,
            ),
            r'$1',
          );
          // [url]URL[/url] → URL
          metin = metin.replaceAll(
            RegExp(
              r'\[url\]([^\[]*)\[/url\]',
              caseSensitive: false,
            ),
            r'$1',
          );
          // [img]URL[/img] → URL
          metin = metin.replaceAll(
            RegExp(
              r'\[img\]([^\[]*)\[/img\]',
              caseSensitive: false,
            ),
            r'$1',
          );
          // [email]mail@x[/email] → mail@x
          metin = metin.replaceAll(
            RegExp(
              r'\[email\]([^\[]*)\[/email\]',
              caseSensitive: false,
            ),
            r'$1',
          );

          // ---- 4) HTML tag'leri temizle ----
          metin = metin.replaceAll(RegExp(r'<[^>]*>'), '');

          // ---- 5) HTML entity'leri çöz ----
          metin = metin
              .replaceAll('&nbsp;', ' ')
              .replaceAll('&amp;', '&')
              .replaceAll('&quot;', '"')
              .replaceAll('&#39;', "'")
              .replaceAll('&lt;', '<')
              .replaceAll('&gt;', '>');

          // ---- 6) Fazla boşluk / satır düzenleme ----
          metin = metin.replaceAll(RegExp(r'\n{3,}'), '\n\n');
          metin = metin.replaceAll(RegExp(r'[ \t]+'), ' ');
          metin = metin.replaceAll(RegExp(r' *\n *'), '\n');

          return metin.trim();
        }
      }
    } catch (_) {}
    return 'İlan metni yüklenemedi.';
  }
}