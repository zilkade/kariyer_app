import 'package:flutter/material.dart';
import '../models/ilan.dart';
import '../theme/app_theme.dart';

/// Tek bir ilanı gösteren kart.
///
/// Hiyerarşi:
///   1. Üst satır: kurum + YENİ badge + favori
///   2. Başlık (ana odak)
///   3. Meta chip'leri: yayın, son başvuru, kalan gün, KPSS
class IlanKarti extends StatelessWidget {
  final Ilan ilan;
  final VoidCallback onTap;
  final VoidCallback onFavori;
  final bool favoriMi;
  final bool incelendi;

  const IlanKarti({
    super.key,
    required this.ilan,
    required this.onTap,
    required this.onFavori,
    this.favoriMi = false,
    this.incelendi = false,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final koyu = Theme.of(context).brightness == Brightness.dark;

    // Okunmuş ilanlar için soluk görünüm
    // Sadece cihaz bazlı: kullanıcı bu ilanı incelemediyse yenidir
    final yeniMi = !incelendi;
    final cardBg = yeniMi
        ? scheme.surface
        : (koyu
            ? scheme.surface.withValues(alpha: 0.55)
            : const Color(0xFFF8FAFC));

    return Material(
      color: cardBg,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(
              color: yeniMi
                  ? scheme.outline.withValues(alpha: koyu ? 0.4 : 0.6)
                  : scheme.outline.withValues(alpha: 0.35),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ---------- ÜST SATIR ----------
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      ilan.kurum.isEmpty ? 'Kurum belirtilmemiş' : ilan.kurum,
                      style: AppText.tiny.copyWith(
                        color: scheme.onSurfaceVariant,
                        letterSpacing: 0.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (!incelendi) ...[
                    const SizedBox(width: AppSpacing.sm),
                    _Badge(
                      text: 'YENİ',
                      bg: AppColors.maviCokAcik,
                      fg: AppColors.maviKoyu,
                    ),
                  ],
                  const SizedBox(width: AppSpacing.xs),
                  _FavoriButon(
                    aktif: favoriMi,
                    onTap: onFavori,
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.sm),

              // ---------- BAŞLIK ----------
              Text(
                ilan.baslik.isEmpty ? 'Başlık yok' : ilan.baslik,
                style: AppText.h3.copyWith(
                  color: yeniMi
                      ? scheme.onSurface
                      : scheme.onSurface.withValues(alpha: 0.75),
                  height: 1.35,
                  fontWeight: yeniMi ? FontWeight.w700 : FontWeight.w500,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: AppSpacing.md),

              // ---------- META CHIP'LER ----------
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.xs,
                children: [
                  if (ilan.tarihGoster.isNotEmpty)
                    _MetaChip(
                      icon: Icons.calendar_today_outlined,
                      text: ilan.tarihGoster,
                      renk: scheme.onSurfaceVariant,
                    ),
                  if (ilan.bitGoster.isNotEmpty)
                    _MetaChip(
                      icon: Icons.event_busy_outlined,
                      text: 'Son: ${ilan.bitGoster}',
                      renk: _kalanRenk(ilan.kalanGun),
                    ),
                  if (ilan.kalanGun != null && ilan.kalanGun! >= 0)
                    _KalanGunChip(gun: ilan.kalanGun!),
                  if (ilan.kpssTurleri.isNotEmpty)
                    _MetaChip(
                      icon: Icons.school_outlined,
                      text: ilan.kpssTurleri.toUpperCase().startsWith('KPSS')
                          ? ilan.kpssTurleri
                          : 'KPSS ${ilan.kpssTurleri}',
                      renk: AppColors.yesil,
                      bgAcik: koyu ? null : AppColors.yesilAcik,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _kalanRenk(int? gun) {
    if (gun == null) return AppColors.metinIkincil;
    if (gun <= 3) return AppColors.kirmizi;
    if (gun <= 7) return AppColors.turuncu;
    return AppColors.metinIkincil;
  }
}

// ============================================================
// YARDIMCI WIDGET'LAR
// ============================================================

class _Badge extends StatelessWidget {
  final String text;
  final Color bg;
  final Color fg;

  const _Badge({required this.text, required this.bg, required this.fg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: fg,
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _FavoriButon extends StatelessWidget {
  final bool aktif;
  final VoidCallback onTap;

  const _FavoriButon({required this.aktif, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: onTap,
      radius: 22,
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          transitionBuilder: (child, anim) => ScaleTransition(
            scale: anim,
            child: child,
          ),
          child: Icon(
            aktif ? Icons.star_rounded : Icons.star_outline_rounded,
            key: ValueKey(aktif),
            color: aktif ? Colors.amber.shade600 : Colors.grey.shade500,
            size: 24,
          ),
        ),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color renk;
  final Color? bgAcik;

  const _MetaChip({
    required this.icon,
    required this.text,
    required this.renk,
    this.bgAcik,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: bgAcik ?? Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: renk),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: renk,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _KalanGunChip extends StatelessWidget {
  final int gun;

  const _KalanGunChip({required this.gun});

  @override
  Widget build(BuildContext context) {
    final koyu = Theme.of(context).brightness == Brightness.dark;

    late final Color bg;
    late final Color fg;
    late final String label;

    if (gun <= 3) {
      bg = koyu ? AppColors.kirmizi.withValues(alpha: 0.15) : AppColors.kirmiziAcik;
      fg = AppColors.kirmizi;
      label = gun == 0 ? 'Son gün!' : '$gun gün kaldı';
    } else if (gun <= 7) {
      bg = koyu ? AppColors.turuncu.withValues(alpha: 0.15) : AppColors.turuncuAcik;
      fg = AppColors.turuncu;
      label = '$gun gün kaldı';
    } else {
      bg = koyu ? AppColors.yesil.withValues(alpha: 0.15) : AppColors.yesilAcik;
      fg = AppColors.yesil;
      label = '$gun gün kaldı';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.hourglass_bottom_rounded, size: 13, color: fg),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: fg,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}