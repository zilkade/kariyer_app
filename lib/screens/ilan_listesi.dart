import 'package:flutter/material.dart';
import '../models/ilan.dart';
import '../services/api_service.dart';
import '../services/kullanici_verisi.dart';
import '../theme/app_theme.dart';
import '../widgets/filtre_cubugu.dart';
import '../widgets/ilan_karti.dart';
import 'ilan_detay.dart';

class IlanListesiEkrani extends StatefulWidget {
  final Future<void> Function(ThemeMode) onTemaDegistir;
  final ThemeMode mevcutTema;

  const IlanListesiEkrani({
    super.key,
    required this.onTemaDegistir,
    required this.mevcutTema,
  });

  @override
  State<IlanListesiEkrani> createState() => _IlanListesiEkraniState();
}

class _IlanListesiEkraniState extends State<IlanListesiEkrani> {
  // ---- Veri ----
  List<Ilan> _ilanlar = [];
  bool _ilkYukleme = true;
  bool _yenileniyor = false;
  String? _hata;

  // ---- Filtreler ----
  String _arama = '';
  bool _sadeceYeni = false;
  bool _sadeceKpss = false;
  bool _sadeceFavori = false;
  bool _sadeceIncelenen = false;
  Set<String> _favoriIds = {};
  Set<String> _okunanIds = {};

  // ---- Debounce ----
  int _aramaToken = 0;

  @override
  void initState() {
    super.initState();
    _yerelVerileriYukle();
    _yukle(ilkMi: true);
  }

  Future<void> _yerelVerileriYukle() async {
    final fav = await KullaniciVerisi.favoriler();
    final oku = await KullaniciVerisi.incelenenler();
    if (!mounted) return;
    setState(() {
      _favoriIds = fav;
      _okunanIds = oku;
    });
  }

  // ============================================================
  // VERİ YÜKLEME
  // ============================================================
  Future<void> _yukle({bool ilkMi = false}) async {
    setState(() {
      if (ilkMi) {
        _ilkYukleme = true;
      } else {
        _yenileniyor = true;
      }
      _hata = null;
    });

    try {
      final liste = await ApiService.ilanlariGetir(
        arama: _arama,
        sadeceYeni: _sadeceYeni,
        sadeceKpss: _sadeceKpss,
      );

      final fav = await KullaniciVerisi.favoriler();
      final oku = await KullaniciVerisi.incelenenler();

      var filtreli = liste;
      if (_sadeceFavori) {
        filtreli = filtreli.where((i) => fav.contains(i.id)).toList();
      }
      if (_sadeceIncelenen) {
        filtreli = filtreli.where((i) => oku.contains(i.id)).toList();
      }

      if (!mounted) return;
      setState(() {
        _ilanlar = filtreli;
        _favoriIds = fav;
        _okunanIds = oku;
        _ilkYukleme = false;
        _yenileniyor = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _hata = _kullaniciDostuHata(e);
        _ilkYukleme = false;
        _yenileniyor = false;
      });
    }
  }

  String _kullaniciDostuHata(Object e) {
    final s = e.toString().toLowerCase();
    if (s.contains('socket') ||
        s.contains('connection') ||
        s.contains('timeout')) {
      return 'İnternet bağlantısı kurulamadı.\nLütfen bağlantınızı kontrol edip tekrar deneyin.';
    }
    if (s.contains('500') || s.contains('502') || s.contains('503')) {
      return 'Sunucu şu an yanıt vermiyor.\nBirkaç dakika sonra tekrar deneyin.';
    }
    if (s.contains('404')) {
      return 'Aradığınız veriler bulunamadı.';
    }
    return 'Beklenmeyen bir hata oluştu.\nLütfen tekrar deneyin.';
  }

  // ============================================================
  // ARAMA — DEBOUNCE
  // ============================================================
  void _aramaDegistir(String v) {
    _arama = v;
    final token = ++_aramaToken;

    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      if (token != _aramaToken) return;
      _yukle();
    });
  }

  // ============================================================
  // FİLTRE DEĞİŞİKLİKLERİ
  // ============================================================
  void _yeniDegistir(bool v) {
    setState(() => _sadeceYeni = v);
    _yukle();
  }

  void _kpssDegistir(bool v) {
    setState(() => _sadeceKpss = v);
    _yukle();
  }

  void _favoriDegistir(bool v) {
    setState(() => _sadeceFavori = v);
    _yukle();
  }

  void _incelenenDegistir(bool v) {
    setState(() => _sadeceIncelenen = v);
    _yukle();
  }

  void _filtreleriTemizle() {
    setState(() {
      _arama = '';
      _sadeceYeni = false;
      _sadeceKpss = false;
      _sadeceFavori = false;
      _sadeceIncelenen = false;
    });
    _yukle();
  }

  // ============================================================
  // FAVORİ TOGGLE
  // ============================================================
  Future<void> _favoriToggle(Ilan ilan) async {
    final yeniDurum = await KullaniciVerisi.favoriDegistir(ilan.id);

    if (!mounted) return;

    final yeniSet = Set<String>.from(_favoriIds);
    if (yeniDurum) {
      yeniSet.add(ilan.id);
    } else {
      yeniSet.remove(ilan.id);
    }

    setState(() {
      _favoriIds = yeniSet;

      if (_sadeceFavori && !yeniDurum) {
        _ilanlar = _ilanlar.where((i) => i.id != ilan.id).toList();
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          yeniDurum ? '⭐ Favorilere eklendi' : 'Favorilerden çıkarıldı',
        ),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ============================================================
  // DETAYA GİT
  // ============================================================
  Future<void> _detayaGit(Ilan ilan) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => IlanDetayEkrani(ilan: ilan)),
    );
    if (mounted) {
      await _yerelVerileriYukle();
      _yukle();
    }
  }

  // ============================================================
  // BUILD
  // ============================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar(context),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.sm,
            ),
            child: FiltreCubugu(
              arama: _arama,
              sadeceYeni: _sadeceYeni,
              sadeceKpss: _sadeceKpss,
              sadeceFavori: _sadeceFavori,
              sadeceIncelenen: _sadeceIncelenen,
              onAramaChanged: _aramaDegistir,
              onYeniChanged: _yeniDegistir,
              onKpssChanged: _kpssDegistir,
              onFavoriChanged: _favoriDegistir,
              onIncelenenChanged: _incelenenDegistir,
              onTemizle: _filtreleriTemizle,
            ),
          ),
          if (_yenileniyor)
            const Padding(
              padding: EdgeInsets.only(top: AppSpacing.xs),
              child: LinearProgressIndicator(minHeight: 2),
            ),
          Expanded(child: _govde(context)),
        ],
      ),
    );
  }

  // ============================================================
  // APPBAR
  // ============================================================
  PreferredSizeWidget _appBar(BuildContext context) {
    return AppBar(
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            padding: const EdgeInsets.all(3),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Image.asset(
                'assets/images/image.png',
                fit: BoxFit.contain,
                errorBuilder: (_, _, _) => const Icon(
                  Icons.check_circle,
                  color: Color(0xFF2563EB),
                  size: 24,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          const Text('Eşleş'),
        ],
      ),
      actions: [
        PopupMenuButton<ThemeMode>(
          icon: Icon(_temaIkon(widget.mevcutTema)),
          tooltip: 'Tema',
          onSelected: widget.onTemaDegistir,
          itemBuilder: (_) => const [
            PopupMenuItem(
              value: ThemeMode.system,
              child: ListTile(
                leading: Icon(Icons.brightness_auto_rounded),
                title: Text('Sistem'),
                dense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
            PopupMenuItem(
              value: ThemeMode.light,
              child: ListTile(
                leading: Icon(Icons.light_mode_rounded),
                title: Text('Açık'),
                dense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
            PopupMenuItem(
              value: ThemeMode.dark,
              child: ListTile(
                leading: Icon(Icons.dark_mode_rounded),
                title: Text('Koyu'),
                dense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
        IconButton(
          icon: const Icon(Icons.refresh_rounded),
          tooltip: 'Yenile',
          onPressed: () => _yukle(),
        ),
      ],
    );
  }

  IconData _temaIkon(ThemeMode m) => switch (m) {
        ThemeMode.dark => Icons.dark_mode_rounded,
        ThemeMode.light => Icons.light_mode_rounded,
        ThemeMode.system => Icons.brightness_auto_rounded,
      };

  // ============================================================
  // GÖVDE
  // ============================================================
  Widget _govde(BuildContext context) {
    if (_ilkYukleme) {
      return _YuklemeSkeleton();
    }

    if (_hata != null) {
      return _HataEkrani(
        mesaj: _hata!,
        onTekrar: () => _yukle(ilkMi: true),
      );
    }

    if (_ilanlar.isEmpty) {
      final filtreVar = _arama.isNotEmpty ||
          _sadeceYeni ||
          _sadeceKpss ||
          _sadeceFavori ||
          _sadeceIncelenen;

      return _BosEkrani(
        filtreVar: filtreVar,
        onTemizle: _filtreleriTemizle,
      );
    }

    return RefreshIndicator(
      onRefresh: () => _yukle(),
      color: AppColors.mavi,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          0,
          AppSpacing.md,
          AppSpacing.xl,
        ),
        itemCount: _ilanlar.length,
        separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
        itemBuilder: (context, i) {
          final ilan = _ilanlar[i];
          return IlanKarti(
            ilan: ilan,
            onTap: () => _detayaGit(ilan),
            onFavori: () => _favoriToggle(ilan),
            favoriMi: _favoriIds.contains(ilan.id),
            incelendi: _okunanIds.contains(ilan.id),
          );
        },
      ),
    );
  }
}

// ============================================================
// YARDIMCI EKRANLAR
// ============================================================

class _YuklemeSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: 6,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (_, _) => _SkeletonKart(),
    );
  }
}

class _SkeletonKart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final renk = scheme.onSurface.withValues(alpha: 0.06);

    Widget kutu({double? w, double h = 12, double r = 6}) => Container(
          width: w,
          height: h,
          decoration: BoxDecoration(
            color: renk,
            borderRadius: BorderRadius.circular(r),
          ),
        );

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: scheme.outline.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: kutu(w: 120, h: 10)),
              const SizedBox(width: 8),
              kutu(w: 40, h: 16, r: 8),
            ],
          ),
          const SizedBox(height: 12),
          kutu(w: double.infinity, h: 16),
          const SizedBox(height: 6),
          kutu(w: 200, h: 16),
          const SizedBox(height: 14),
          Row(
            children: [
              kutu(w: 90, h: 22, r: 8),
              const SizedBox(width: 6),
              kutu(w: 110, h: 22, r: 8),
            ],
          ),
        ],
      ),
    );
  }
}

class _HataEkrani extends StatelessWidget {
  final String mesaj;
  final VoidCallback onTekrar;

  const _HataEkrani({required this.mesaj, required this.onTekrar});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.kirmizi.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.cloud_off_rounded,
                size: 48,
                color: AppColors.kirmizi,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            const Text(
              'Bağlantı sorunu',
              style: AppText.h2,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              mesaj,
              textAlign: TextAlign.center,
              style: AppText.body.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            ElevatedButton.icon(
              onPressed: onTekrar,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Tekrar Dene'),
            ),
          ],
        ),
      ),
    );
  }
}

class _BosEkrani extends StatelessWidget {
  final bool filtreVar;
  final VoidCallback onTemizle;

  const _BosEkrani({required this.filtreVar, required this.onTemizle});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: scheme.surfaceContainerHighest,
                shape: BoxShape.circle,
              ),
              child: Icon(
                filtreVar ? Icons.filter_alt_off_rounded : Icons.inbox_rounded,
                size: 48,
                color: scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              filtreVar ? 'Sonuç bulunamadı' : 'Henüz ilan yok',
              style: AppText.h2,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              filtreVar
                  ? 'Arama veya filtrelerinizi değiştirmeyi deneyin.'
                  : 'Yeni ilanlar geldiğinde burada görünecek.',
              textAlign: TextAlign.center,
              style: AppText.body.copyWith(color: scheme.onSurfaceVariant),
            ),
            if (filtreVar) ...[
              const SizedBox(height: AppSpacing.xl),
              OutlinedButton.icon(
                onPressed: onTemizle,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Filtreleri Temizle'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.mavi,
                  side: const BorderSide(color: AppColors.mavi),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xl,
                    vertical: AppSpacing.md,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}