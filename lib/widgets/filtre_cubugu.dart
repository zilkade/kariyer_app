import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Ana ekrandaki arama + filtre çubuğu.
///
/// - Arama: debounce'lu (yazarken gecikmeli tetikler)
/// - Filtreler: Yeni / KPSS / Favoriler / İncelediklerim
/// - Aktif filtreler: temizle butonu görünür
class FiltreCubugu extends StatefulWidget {
  final String arama;
  final bool sadeceYeni;
  final bool sadeceKpss;
  final bool sadeceFavori;
  final bool sadeceIncelenen;

  final ValueChanged<String> onAramaChanged;
  final ValueChanged<bool> onYeniChanged;
  final ValueChanged<bool> onKpssChanged;
  final ValueChanged<bool> onFavoriChanged;
  final ValueChanged<bool> onIncelenenChanged;
  final VoidCallback onTemizle;

  const FiltreCubugu({
    super.key,
    required this.arama,
    required this.sadeceYeni,
    required this.sadeceKpss,
    required this.sadeceFavori,
    required this.sadeceIncelenen,
    required this.onAramaChanged,
    required this.onYeniChanged,
    required this.onKpssChanged,
    required this.onFavoriChanged,
    required this.onIncelenenChanged,
    required this.onTemizle,
  });

  @override
  State<FiltreCubugu> createState() => _FiltreCubuguState();
}

class _FiltreCubuguState extends State<FiltreCubugu> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.arama);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _filtreAktif =>
      widget.arama.isNotEmpty ||
      widget.sadeceYeni ||
      widget.sadeceKpss ||
      widget.sadeceFavori ||
      widget.sadeceIncelenen;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final koyu = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: scheme.outline.withValues(alpha: koyu ? 0.4 : 0.6),
        ),
      ),
      child: Column(
        children: [
          // ---------- ARAMA ----------
          TextField(
            controller: _controller,
            style: AppText.body,
            decoration: InputDecoration(
              hintText: 'Kurum veya başlıkta ara...',
              prefixIcon: const Icon(Icons.search_rounded, size: 20),
              suffixIcon: _controller.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.close_rounded, size: 20),
                      onPressed: () {
                        _controller.clear();
                        widget.onAramaChanged('');
                        setState(() {});
                      },
                    )
                  : null,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
            ),
            onChanged: widget.onAramaChanged,
            onSubmitted: widget.onAramaChanged,
          ),

          const SizedBox(height: AppSpacing.md),

          // ---------- FİLTRE ÇİPLERİ ----------
          Row(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _FiltreChip(
                        label: 'Yeni',
                        icon: Icons.auto_awesome_outlined,
                        secili: widget.sadeceYeni,
                        onTap: () => widget.onYeniChanged(!widget.sadeceYeni),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      _FiltreChip(
                        label: 'KPSS',
                        icon: Icons.school_outlined,
                        secili: widget.sadeceKpss,
                        onTap: () => widget.onKpssChanged(!widget.sadeceKpss),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      _FiltreChip(
                        label: 'Favoriler',
                        icon: Icons.star_outline_rounded,
                        secili: widget.sadeceFavori,
                        onTap: () =>
                            widget.onFavoriChanged(!widget.sadeceFavori),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      _FiltreChip(
                        label: 'İncelediklerim',
                        icon: Icons.history_rounded,
                        secili: widget.sadeceIncelenen,
                        onTap: () => widget.onIncelenenChanged(
                            !widget.sadeceIncelenen),
                      ),
                    ],
                  ),
                ),
              ),
              if (_filtreAktif) ...[
                const SizedBox(width: AppSpacing.sm),
                TextButton.icon(
                  onPressed: () {
                    _controller.clear();
                    widget.onTemizle();
                  },
                  icon: const Icon(Icons.refresh_rounded, size: 16),
                  label: const Text('Temizle'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.mavi,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                    ),
                    textStyle: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _FiltreChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool secili;
  final VoidCallback onTap;

  const _FiltreChip({
    required this.label,
    required this.icon,
    required this.secili,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final koyu = Theme.of(context).brightness == Brightness.dark;

    final bg = secili
        ? (koyu ? AppColors.maviKoyu : AppColors.maviCokAcik)
        : scheme.surfaceContainerHighest;
    final fg = secili
        ? (koyu ? AppColors.maviCokAcik : AppColors.maviKoyu)
        : scheme.onSurfaceVariant;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.full),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: 7,
        ),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(AppRadius.full),
          border: Border.all(
            color: secili ? AppColors.mavi : scheme.outline,
            width: secili ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: fg),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: fg,
                fontWeight: secili ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}