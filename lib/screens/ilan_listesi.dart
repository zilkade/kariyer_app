import 'package:flutter/material.dart';
import '../models/ilan.dart';
import '../services/api_service.dart';
import 'ilan_detay.dart';

class IlanListesiEkrani extends StatefulWidget {
  const IlanListesiEkrani({super.key});

  @override
  State<IlanListesiEkrani> createState() => _IlanListesiEkraniState();
}

class _IlanListesiEkraniState extends State<IlanListesiEkrani> {
  List<Ilan> _ilanlar = [];
  bool _yukleniyor = true;
  String? _hata;
  String _arama = '';
  bool _sadeceYeni = false;
  bool _sadeceKpss = false;
  bool _sadeceFavori = false;

  final TextEditingController _aramaCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _yukle();
  }

  Future<void> _yukle() async {
    setState(() {
      _yukleniyor = true;
      _hata = null;
    });

    try {
      final liste = await ApiService.ilanlariGetir(
        arama: _arama,
        sadeceYeni: _sadeceYeni,
        sadeceKpss: _sadeceKpss,
        sadeceFavori: _sadeceFavori,
      );

      if (!mounted) return;
      setState(() {
        _ilanlar = liste;
        _yukleniyor = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _hata = 'Bağlantı hatası: $e';
        _yukleniyor = false;
      });
    }
  }

  Future<void> _favoriDegistir(Ilan ilan) async {
    final ok = await ApiService.favoriDegistir(ilan.id);
    if (ok && mounted) {
      await _yukle();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kariyer Kapısı Takip'),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _yukle,
            tooltip: 'Yenile',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
            child: TextField(
              controller: _aramaCtrl,
              decoration: InputDecoration(
                hintText: 'Kurum veya başlıkta ara...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _arama.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _aramaCtrl.clear();
                          setState(() => _arama = '');
                          _yukle();
                        },
                      )
                    : null,
                isDense: true,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onSubmitted: (v) {
                setState(() => _arama = v);
                _yukle();
              },
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                FilterChip(
                  label: const Text('✨ Yeni'),
                  selected: _sadeceYeni,
                  onSelected: (v) {
                    setState(() => _sadeceYeni = v);
                    _yukle();
                  },
                ),
                const SizedBox(width: 6),
                FilterChip(
                  label: const Text('📚 KPSS'),
                  selected: _sadeceKpss,
                  onSelected: (v) {
                    setState(() => _sadeceKpss = v);
                    _yukle();
                  },
                ),
                const SizedBox(width: 6),
                FilterChip(
                  label: const Text('⭐ Favoriler'),
                  selected: _sadeceFavori,
                  onSelected: (v) {
                    setState(() => _sadeceFavori = v);
                    _yukle();
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(child: _govde()),
        ],
      ),
    );
  }

  Widget _govde() {
    if (_yukleniyor) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('İlanlar yükleniyor...'),
            SizedBox(height: 8),
            Text(
              '(İlk açılışta 20-50 saniye sürebilir)',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    if (_hata != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(_hata!, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _yukle,
                icon: const Icon(Icons.refresh),
                label: const Text('Tekrar Dene'),
              ),
            ],
          ),
        ),
      );
    }

    if (_ilanlar.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('Bu filtreye uyan ilan yok'),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _yukle,
      child: ListView.separated(
        padding: const EdgeInsets.all(12),
        itemCount: _ilanlar.length,
        separatorBuilder: (_, _) => const SizedBox(height: 8),
        itemBuilder: (context, i) => _ilanKarti(_ilanlar[i]),
      ),
    );
  }

  Widget _ilanKarti(Ilan ilan) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => IlanDetayEkrani(ilan: ilan)),
        ).then((_) => _yukle()),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      ilan.kurum,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (ilan.yeniMi)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade100,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'YENİ',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  IconButton(
                    icon: Icon(
                      ilan.favoriMi ? Icons.star : Icons.star_border,
                      color: ilan.favoriMi ? Colors.amber : Colors.grey,
                      size: 20,
                    ),
                    onPressed: () => _favoriDegistir(ilan),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                ilan.baslik,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: [
                  if (ilan.tarihGoster.isNotEmpty)
                    _chip(Icons.calendar_today, ilan.tarihGoster, Colors.blueGrey),
                  if (ilan.bitGoster.isNotEmpty)
                    _chip(Icons.timer_outlined, ilan.bitGoster, Colors.orange),
                  if (ilan.kalanGun != null && ilan.kalanGun! >= 0)
                    _chip(Icons.hourglass_bottom, '${ilan.kalanGun} gün', Colors.red),
                  if (ilan.kpssTurleri.isNotEmpty)
                    _chip(Icons.school, 'KPSS ${ilan.kpssTurleri}', Colors.green),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _chip(IconData ikon, String metin, Color renk) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: renk.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(ikon, size: 12, color: renk),
          const SizedBox(width: 4),
          Text(
            metin,
            style: TextStyle(fontSize: 11, color: renk, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}