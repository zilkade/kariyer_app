import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/ilan.dart';
import '../services/api_service.dart';
import '../services/kullanici_verisi.dart';
import '../theme/app_theme.dart';

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
  bool _favori = false;

  @override
  void initState() {
    super.initState();
    _yerelVerileriYukle();
    _detayYukle();
    _incelendiKaydet();
  }

  Future<void> _yerelVerileriYukle() async {
    final fav = await KullaniciVerisi.favoriMi(widget.ilan.id);
    if (!mounted) return;
    setState(() => _favori = fav);
  }

  /// Bu ilan açıldığında cihazda "incelendi" olarak işaretle
  Future<void> _incelendiKaydet() async {
    await KullaniciVerisi.incelendiIsaretle(widget.ilan.id);
  }

  Future<void> _detayYukle() async {
    setState(() {
      _detayYukleniyor = true;
      _detayHata = null;
    });

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
          await Future.delayed(const Duration(seconds: 3));
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

  Future<void> _favoriToggle() async {
    final yeniDurum = await KullaniciVerisi.favoriDegistir(widget.ilan.id);

    if (!mounted) return;

    setState(() => _favori = yeniDurum);

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('İlan Detayı'),
        actions: [
          IconButton(
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                _favori ? Icons.star_rounded : Icons.star_outline_rounded,
                key: ValueKey(_favori),
                color: _favori ? Colors.amber.shade400 : Colors.white,
              ),
            ),
            tooltip: _favori ? 'Favorilerden çıkar' : 'Favorilere ekle',
            onPressed: _favoriToggle,
          ),
        ],
      ),
      body: _govde(context),
      bottomNavigationBar: _altAksiyon(context),
    );
  }

  // ============================================================
  // GÖVDE
  // ============================================================
  Widget _govde(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        _ustBilgi(context),
        const SizedBox(height: AppSpacing.lg),
        _chipSatiri(context),
        const SizedBox(height: AppSpacing.lg),
        _basvuruDurumu(context),
        const SizedBox(height: AppSpacing.lg),
        _ilanMetniBolumu(context),
        const SizedBox(height: AppSpacing.xl),
      ],
    );
  }

  // ---- ÜST BİLGİ ----
  Widget _ustBilgi(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.ilan.kurum.isEmpty ? 'Kurum belirtilmemiş' : widget.ilan.kurum,
          style: AppText.tiny.copyWith(
            color: scheme.onSurfaceVariant,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          widget.ilan.baslik,
          style: AppText.h1.copyWith(
            color: scheme.onSurface,
            height: 1.3,
          ),
        ),
      ],
    );
  }

  // ---- CHIP SATIRI ----
  Widget _chipSatiri(BuildContext context) {
    final koyu = Theme.of(context).brightness == Brightness.dark;
    final gun = widget.ilan.kalanGun;

    Color kalanRenk;
    Color kalanArka;
    if (gun == null) {
      kalanRenk = AppColors.metinIkincil;
      kalanArka = Theme.of(context).colorScheme.surfaceContainerHighest;
    } else if (gun <= 3) {
      kalanRenk = AppColors.kirmizi;
      kalanArka = koyu
          ? AppColors.kirmizi.withValues(alpha: 0.15)
          : AppColors.kirmiziAcik;
    } else if (gun <= 7) {
      kalanRenk = AppColors.turuncu;
      kalanArka = koyu
          ? AppColors.turuncu.withValues(alpha: 0.15)
          : AppColors.turuncuAcik;
    } else {
      kalanRenk = AppColors.yesil;
      kalanArka = koyu
          ? AppColors.yesil.withValues(alpha: 0.15)
          : AppColors.yesilAcik;
    }

    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        if (widget.ilan.tarihGoster.isNotEmpty)
          _BilgiChip(
            icon: Icons.calendar_today_outlined,
            label: 'Yayın',
            deger: widget.ilan.tarihGoster,
          ),
        if (widget.ilan.bitGoster.isNotEmpty)
          _BilgiChip(
            icon: Icons.event_busy_outlined,
            label: 'Son Başvuru',
            deger: widget.ilan.bitGoster,
          ),
        if (gun != null && gun >= 0)
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: kalanArka,
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.hourglass_bottom_rounded,
                    size: 15, color: kalanRenk),
                const SizedBox(width: 6),
                Text(
                  gun == 0 ? 'Son gün!' : '$gun gün kaldı',
                  style: TextStyle(
                    fontSize: 13,
                    color: kalanRenk,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        if (widget.ilan.kpssTurleri.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: koyu
                  ? AppColors.yesil.withValues(alpha: 0.15)
                  : AppColors.yesilAcik,
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.school_outlined,
                    size: 15, color: AppColors.yesil),
                const SizedBox(width: 6),
                Text(
                  widget.ilan.kpssTurleri.toUpperCase().startsWith('KPSS')
                      ? widget.ilan.kpssTurleri
                      : 'KPSS ${widget.ilan.kpssTurleri}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.yesil,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  // ---- BAŞVURU DURUMU ----
  Widget _basvuruDurumu(BuildContext context) {
    final basvuru = _detay?['basvuru_durumu'] as String?;
    if (basvuru == null || basvuru.isEmpty) return const SizedBox.shrink();

    final koyu = Theme.of(context).brightness == Brightness.dark;

    // Koyu temada farklı renk paleti — göz yormayan
    final bg = koyu
        ? AppColors.mavi.withValues(alpha: 0.15)
        : AppColors.maviCokAcik.withValues(alpha: 0.5);
    final borderRenk = koyu
        ? AppColors.mavi.withValues(alpha: 0.4)
        : AppColors.maviCokAcik;
    final metinRenk = koyu ? AppColors.maviAcik : AppColors.maviKoyu;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: borderRenk),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: const BoxDecoration(
              color: AppColors.mavi,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.info_outline,
              color: Colors.white,
              size: 18,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              basvuru,
              style: AppText.body.copyWith(
                color: metinRenk,
                fontWeight: FontWeight.w600,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---- İLAN METNİ BÖLÜMÜ ----
  Widget _ilanMetniBolumu(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final koyu = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 3,
              height: 18,
              decoration: BoxDecoration(
                color: AppColors.mavi,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              'İlan Metni',
              style: AppText.h3.copyWith(color: scheme.onSurface),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),

        if (_detayYukleniyor)
          _yuklemeKutusu(context)
        else if (_detayHata != null)
          _hataKutusu(context)
        else if (_detay != null && _detay!['detay'] != null)
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: koyu
                  ? scheme.surfaceContainerHighest.withValues(alpha: 0.5)
                  : const Color(0xFFFAFBFC),
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(
                color: scheme.outline.withValues(alpha: 0.6),
              ),
            ),
            child: _zenginIlanMetni(context, _ilanMetni(_detay!['detay'])),
          )
        else
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Text(
              'İlan metni bulunamadı.',
              style: AppText.body.copyWith(color: scheme.onSurfaceVariant),
            ),
          ),
      ],
    );
  }

  Widget _yuklemeKutusu(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Column(
        children: [
          const SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: AppColors.mavi,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'İlan metni yükleniyor...',
            style: AppText.bodyKalin.copyWith(color: scheme.onSurface),
          ),
          const SizedBox(height: 4),
          Text(
            'Birkaç saniye sürebilir',
            style: AppText.tiny.copyWith(color: scheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  Widget _hataKutusu(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.turuncuAcik.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.turuncuAcik),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.cloud_off_rounded,
            color: AppColors.turuncu,
            size: 32,
          ),
          const SizedBox(height: AppSpacing.sm),
          const Text(
            'İlan metni yüklenemedi',
            style: AppText.bodyKalin,
          ),
          const SizedBox(height: 4),
          Text(
            'Yukarıdaki "İlan Sayfasını Aç" butonu ile\ntam metne ulaşabilirsiniz.',
            textAlign: TextAlign.center,
            style: AppText.small.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          OutlinedButton.icon(
            onPressed: _detayYukle,
            icon: const Icon(Icons.refresh_rounded, size: 16),
            label: const Text('Tekrar Dene'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.turuncu,
              side: const BorderSide(color: AppColors.turuncu),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ALT AKSİYON
  // ============================================================
  Widget? _altAksiyon(BuildContext context) {
    if (widget.ilan.link.isEmpty) return null;
    final scheme = Theme.of(context).colorScheme;
    final koyu = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.md + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: scheme.surface,
        border: Border(
          top: BorderSide(
            color: scheme.outline.withValues(alpha: koyu ? 0.4 : 0.6),
          ),
        ),
      ),
      child: ElevatedButton.icon(
        onPressed: () => _linkAc(widget.ilan.link),
        icon: const Icon(Icons.open_in_new_rounded, size: 20),
        label: const Text('İlan Sayfasını Aç'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.mavi,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // BBCode + HTML TEMİZLEME
  // ============================================================
  String _ilanMetni(dynamic detay) {
    try {
      if (detay is Map) {
        final govde = detay['govde'] ?? detay;
        if (govde is Map && govde['ilanMetni'] != null) {
          String metin = govde['ilanMetni'].toString();

          // ---- 1) ÖZEL TAG'LER — İÇERİĞİ KORU ----
          metin = metin.replaceAll(
            RegExp(r'\[url=[^\]]*\]([^\[]*)\[/url\]', caseSensitive: false),
            r'$1',
          );
          metin = metin.replaceAll(
            RegExp(r'\[url\]([^\[]*)\[/url\]', caseSensitive: false),
            r'$1',
          );
          metin = metin.replaceAll(
            RegExp(r'\[img\]([^\[]*)\[/img\]', caseSensitive: false),
            r'$1',
          );
          metin = metin.replaceAll(
            RegExp(r'\[email\]([^\[]*)\[/email\]', caseSensitive: false),
            r'$1',
          );

          // ---- 2) LİSTE ELEMANI [*] → • ----
          metin = metin.replaceAll('[*]', '•');

          // ---- 3) KALAN TÜM BBCODE TAG'LERİ (catch-all) ----
          metin = metin.replaceAll(
            RegExp(r'\[/?[a-zA-Z][^\]]*\]', caseSensitive: false),
            '',
          );

          // ---- 4) HTML TAG'LERİ ----
          metin = metin.replaceAll(RegExp(r'<[^>]*>'), '');

          // ---- 5) HTML ENTITY'LER (isimli) ----
          metin = metin
              .replaceAll('&nbsp;', ' ')
              .replaceAll('&amp;', '&')
              .replaceAll('&quot;', '"')
              .replaceAll('&apos;', "'")
              .replaceAll('&lt;', '<')
              .replaceAll('&gt;', '>');

          // ---- 6) HTML NUMERIC ENTITY'LER ----
          metin = metin.replaceAllMapped(
            RegExp(r'&#(\d+);'),
            (m) => String.fromCharCode(int.parse(m.group(1)!)),
          );
          metin = metin.replaceAllMapped(
            RegExp(r'&#x([0-9a-fA-F]+);'),
            (m) => String.fromCharCode(int.parse(m.group(1)!, radix: 16)),
          );

          // ---- 7) FAZLA BOŞLUK / SATIR ----
          metin = metin.replaceAll(RegExp(r'\n{3,}'), '\n\n');
          metin = metin.replaceAll(RegExp(r'[ \t]+'), ' ');
          metin = metin.replaceAll(RegExp(r' *\n *'), '\n');

          return metin.trim();
        }
      }
    } catch (_) {}
    return 'İlan metni yüklenemedi.';
  }

  // ============================================================
  // ZENGİN İLAN METNİ RENDER
  // ============================================================
  Widget _zenginIlanMetni(BuildContext context, String metin) {
    final koyu = Theme.of(context).brightness == Brightness.dark;
    final satirlar = metin.split('\n');

    int baslikSonu = -1;
    for (int i = 0; i < satirlar.length && i < 10; i++) {
      if (satirlar[i].trim().isEmpty) {
        baslikSonu = i;
        break;
      }
    }

    final baslikSatirlari = baslikSonu > 0
        ? satirlar
            .sublist(0, baslikSonu)
            .where((s) => s.trim().isNotEmpty)
            .toList()
        : <String>[];

    final govdeSatirlari =
        baslikSonu > 0 ? satirlar.sublist(baslikSonu + 1) : satirlar;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (baslikSatirlari.isNotEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.lg),
            margin: const EdgeInsets.only(bottom: AppSpacing.lg),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: koyu
                    ? [AppColors.koyuYuzeyUst, AppColors.koyuYuzey]
                    : [AppColors.lacivert, AppColors.lacivertAcik],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Column(
              children: baslikSatirlari.map((satir) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Text(
                    satir.trim(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.5,
                      color: Colors.white.withValues(alpha: 0.95),
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ..._govdeRender(context, govdeSatirlari),
      ],
    );
  }

  List<Widget> _govdeRender(BuildContext context, List<String> satirlar) {
    final scheme = Theme.of(context).colorScheme;
    final widgetlar = <Widget>[];

    for (int i = 0; i < satirlar.length; i++) {
      final ham = satirlar[i];
      final temiz = ham.trim();

      if (temiz.isEmpty) {
        widgetlar.add(const SizedBox(height: AppSpacing.lg));
        continue;
      }

      if (_baslikMi(temiz)) {
        widgetlar.add(_buyukBaslik(context, temiz));
        continue;
      }

      if (_anahtarDegerMi(temiz)) {
        widgetlar.add(_anahtarDeger(context, temiz));
        continue;
      }

      if (RegExp(r'^\d+\s*[\.\)]\s+\S').hasMatch(temiz) && temiz.length > 3) {
        widgetlar.add(_numaraliMadde(context, temiz));
        continue;
      }

      if (RegExp(r'^[a-zçğıöşüA-ZÇĞİÖŞÜ][\.\)]\s+\S').hasMatch(temiz)) {
        widgetlar.add(_harfliMadde(context, temiz));
        continue;
      }

      if (temiz.startsWith('- ') || temiz.startsWith('• ')) {
        widgetlar.add(_tireMadde(context, temiz.substring(2)));
        continue;
      }

      widgetlar.add(Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
        child: SelectableText(
          temiz,
          style: AppText.body.copyWith(
            color: scheme.onSurface,
            height: 1.7,
          ),
        ),
      ));
    }

    return widgetlar;
  }

  bool _baslikMi(String satir) {
    if (satir.length > 100) return false;

    if (RegExp(r'^(I|II|III|IV|V|VI|VII|VIII|IX|X)\s*[\.\)]\s+')
        .hasMatch(satir)) {
      return true;
    }
    if (RegExp(r'^[A-ZÇĞİÖŞÜ]\s*[\.\)]\s+[A-ZÇĞİÖŞÜ]').hasMatch(satir)) {
      return true;
    }
    if (satir.length < 60 &&
        satir == satir.toUpperCase() &&
        RegExp(r'[A-ZÇĞİÖŞÜ]{3,}').hasMatch(satir) &&
        !RegExp(r'^\d').hasMatch(satir)) {
      return true;
    }
    return false;
  }

  bool _anahtarDegerMi(String satir) {
    final m = RegExp(r'^([^:]{2,45}):\s*(.+)$').firstMatch(satir);
    if (m == null) return false;

    final anahtar = m.group(1)!;
    if (anahtar.length < 3) return false;
    if (RegExp(r'\d{1,2}[\.\/]\d{1,2}').hasMatch(anahtar)) return false;
    return true;
  }

  Widget _buyukBaslik(BuildContext context, String satir) {
    final scheme = Theme.of(context).colorScheme;
    final koyu = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(
        top: AppSpacing.md,
        bottom: AppSpacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 3,
                height: 20,
                decoration: BoxDecoration(
                  color: AppColors.mavi,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  satir,
                  style: AppText.h3.copyWith(
                    color: koyu ? AppColors.maviAcik : AppColors.lacivert,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Divider(
            color: scheme.outline.withValues(alpha: 0.4),
            height: 1,
          ),
        ],
      ),
    );
  }

  Widget _anahtarDeger(BuildContext context, String satir) {
    final scheme = Theme.of(context).colorScheme;
    final m = RegExp(r'^([^:]{2,45}):\s*(.+)$').firstMatch(satir);
    if (m == null) return const SizedBox.shrink();

    final anahtar = m.group(1)!.trim();
    final deger = m.group(2)!.trim();
    final sayisal = RegExp(r'^\d').hasMatch(deger);

    return Padding(
      padding: const EdgeInsets.only(
        bottom: AppSpacing.xs,
        left: AppSpacing.sm,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 9, right: 8),
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.mavi.withValues(alpha: 0.5),
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '$anahtar: ',
                    style: AppText.body.copyWith(
                      color: scheme.onSurfaceVariant,
                      height: 1.6,
                    ),
                  ),
                  TextSpan(
                    text: deger,
                    style: AppText.body.copyWith(
                      color: sayisal ? AppColors.maviKoyu : scheme.onSurface,
                      fontWeight: FontWeight.w700,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _numaraliMadde(BuildContext context, String satir) {
    final scheme = Theme.of(context).colorScheme;
    final m = RegExp(r'^(\d+)\s*[\.\)]?\s+(.+)$').firstMatch(satir);
    if (m == null) return const SizedBox.shrink();

    final no = m.group(1)!;
    final icerik = m.group(2)!;

    return Padding(
      padding: const EdgeInsets.only(
        bottom: AppSpacing.sm,
        top: AppSpacing.xs,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 22,
            height: 22,
            margin: const EdgeInsets.only(top: 3, right: AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.maviCokAcik,
              borderRadius: BorderRadius.circular(6),
            ),
            alignment: Alignment.center,
            child: Text(
              no,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.maviKoyu,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Expanded(
            child: SelectableText(
              icerik,
              style: AppText.body.copyWith(
                color: scheme.onSurface,
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _harfliMadde(BuildContext context, String satir) {
    final scheme = Theme.of(context).colorScheme;
    final m = RegExp(r'^([a-zçğıöşüA-ZÇĞİÖŞÜ])\s*[\.\)]\s+(.+)$').firstMatch(satir);
    if (m == null) return const SizedBox.shrink();

    final harf = m.group(1)!;
    final icerik = m.group(2)!;

    return Padding(
      padding: const EdgeInsets.only(
        bottom: AppSpacing.xs,
        left: AppSpacing.md,
        top: 2,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 20,
            child: Text(
              '$harf)',
              style: AppText.body.copyWith(
                color: AppColors.mavi,
                fontWeight: FontWeight.w800,
                height: 1.6,
              ),
            ),
          ),
          Expanded(
            child: SelectableText(
              icerik,
              style: AppText.body.copyWith(
                color: scheme.onSurface,
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tireMadde(BuildContext context, String icerik) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(
        bottom: AppSpacing.xs,
        left: AppSpacing.sm,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 9, right: 8),
            width: 4,
            height: 4,
            decoration: const BoxDecoration(
              color: AppColors.mavi,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: SelectableText(
              icerik,
              style: AppText.body.copyWith(
                color: scheme.onSurface,
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// YARDIMCI WIDGET
// ============================================================
class _BilgiChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String deger;

  const _BilgiChip({
    required this.icon,
    required this.label,
    required this.deger,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: scheme.onSurfaceVariant),
          const SizedBox(width: 6),
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: 13,
              color: scheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            deger,
            style: TextStyle(
              fontSize: 13,
              color: scheme.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}