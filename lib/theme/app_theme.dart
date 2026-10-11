import 'package:flutter/material.dart';

/// Kariyer Kapısı Takip — Merkezi Tasarım Sistemi
/// Renk paleti, boşluk ölçeği, yuvarlaklık ve tema tanımları.
class AppColors {
  // ---- Ana Palet ----
  static const Color lacivert      = Color(0xFF142B4A);
  static const Color lacivertKoyu  = Color(0xFF0D1E35);
  static const Color lacivertAcik  = Color(0xFF1E3D63);

  static const Color mavi          = Color(0xFF2563EB);
  static const Color maviKoyu      = Color(0xFF1D4ED8);
  static const Color maviAcik      = Color(0xFF3B82F6);
  static const Color maviCokAcik   = Color(0xFFDBEAFE);

  static const Color griArka       = Color(0xFFF3F6FA);
  static const Color griYuzey      = Color(0xFFE8EEF5);
  static const Color griSinir      = Color(0xFFD4DCE6);

  static const Color beyaz         = Color(0xFFFFFFFF);

  static const Color yesil         = Color(0xFF16A34A);
  static const Color yesilAcik     = Color(0xFFD1FAE5);

  static const Color kirmizi       = Color(0xFFDC2626);
  static const Color kirmiziAcik   = Color(0xFFFEE2E2);

  static const Color turuncu       = Color(0xFFEA580C);
  static const Color turuncuAcik   = Color(0xFFFFEDD5);

  static const Color sari          = Color(0xFFCA8A04);
  static const Color sariAcik      = Color(0xFFFEF3C7);

  // ---- Metin Renkleri (Açık Tema) ----
  static const Color metinAna      = Color(0xFF0F172A);
  static const Color metinIkincil  = Color(0xFF64748B);
  static const Color metinSolgun   = Color(0xFF94A3B8);

  // ---- Koyu Tema ----
  static const Color koyuArka      = Color(0xFF0A1628);
  static const Color koyuYuzey     = Color(0xFF142B4A);
  static const Color koyuYuzeyUst  = Color(0xFF1E3D63);
  static const Color koyuSinir     = Color(0xFF2D4A6B);

  static const Color koyuMetinAna     = Color(0xFFF1F5F9);
  static const Color koyuMetinIkincil = Color(0xFF94A3B8);
  static const Color koyuMetinSolgun  = Color(0xFF64748B);
}

/// 4px grid spacing
class AppSpacing {
  static const double xs  = 4;
  static const double sm  = 8;
  static const double md  = 12;
  static const double lg  = 16;
  static const double xl  = 24;
  static const double xxl = 32;
}

class AppRadius {
  static const double sm   = 8;
  static const double md   = 12;
  static const double lg   = 16;
  static const double full = 999;
}

/// Tipografi ölçeği
class AppText {
  static const TextStyle h1 = TextStyle(
    fontSize: 24, fontWeight: FontWeight.w700, letterSpacing: -0.4,
  );
  static const TextStyle h2 = TextStyle(
    fontSize: 20, fontWeight: FontWeight.w700, letterSpacing: -0.2,
  );
  static const TextStyle h3 = TextStyle(
    fontSize: 16, fontWeight: FontWeight.w600,
  );
  static const TextStyle body = TextStyle(
    fontSize: 14, height: 1.5,
  );
  static const TextStyle bodyKalin = TextStyle(
    fontSize: 14, fontWeight: FontWeight.w600,
  );
  static const TextStyle small = TextStyle(
    fontSize: 13, height: 1.4,
  );
  static const TextStyle tiny = TextStyle(
    fontSize: 12, fontWeight: FontWeight.w500,
  );
  static const TextStyle mono = TextStyle(
    fontFamily: 'monospace', fontSize: 12, height: 1.4,
  );
}

class AppTheme {
  static ThemeData light() {
    const scheme = ColorScheme.light(
      primary: AppColors.lacivert,
      onPrimary: AppColors.beyaz,
      primaryContainer: AppColors.lacivertAcik,
      onPrimaryContainer: AppColors.beyaz,
      secondary: AppColors.mavi,
      onSecondary: AppColors.beyaz,
      secondaryContainer: AppColors.maviCokAcik,
      onSecondaryContainer: AppColors.maviKoyu,
      surface: AppColors.beyaz,
      onSurface: AppColors.metinAna,
      surfaceContainerHighest: AppColors.griYuzey,
      onSurfaceVariant: AppColors.metinIkincil,
      outline: AppColors.griSinir,
      error: AppColors.kirmizi,
      onError: AppColors.beyaz,
    );
    return _build(scheme, AppColors.griArka);
  }

  static ThemeData dark() {
    const scheme = ColorScheme.dark(
      primary: AppColors.maviAcik,
      onPrimary: AppColors.beyaz,
      primaryContainer: AppColors.maviKoyu,
      onPrimaryContainer: AppColors.beyaz,
      secondary: AppColors.mavi,
      onSecondary: AppColors.beyaz,
      secondaryContainer: AppColors.koyuYuzeyUst,
      onSecondaryContainer: AppColors.maviCokAcik,
      surface: AppColors.koyuYuzey,
      onSurface: AppColors.koyuMetinAna,
      surfaceContainerHighest: AppColors.koyuYuzeyUst,
      onSurfaceVariant: AppColors.koyuMetinIkincil,
      outline: AppColors.koyuSinir,
      error: Color(0xFFEF4444),
      onError: AppColors.beyaz,
    );
    return _build(scheme, AppColors.koyuArka);
  }

  static ThemeData _build(ColorScheme scheme, Color bg) {
    final koyu = scheme.brightness == Brightness.dark;

    return ThemeData(
      useMaterial3: true,
      brightness: scheme.brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: bg,

      appBarTheme: AppBarTheme(
        backgroundColor: koyu ? AppColors.koyuYuzey : AppColors.lacivert,
        foregroundColor: AppColors.beyaz,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        centerTitle: false,
        titleTextStyle: const TextStyle(
          color: AppColors.beyaz,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.2,
        ),
        iconTheme: const IconThemeData(color: AppColors.beyaz),
      ),

      cardTheme: CardThemeData(
        color: scheme.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          side: BorderSide(color: scheme.outline.withValues(alpha: 0.6)),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: koyu ? AppColors.koyuYuzeyUst : AppColors.beyaz,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg, vertical: AppSpacing.md,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: scheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: scheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.mavi, width: 2),
        ),
        hintStyle: TextStyle(color: scheme.onSurfaceVariant),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.mavi,
          foregroundColor: AppColors.beyaz,
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl, vertical: AppSpacing.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          textStyle: const TextStyle(
            fontSize: 15, fontWeight: FontWeight.w600,
          ),
        ),
      ),

      chipTheme: ChipThemeData(
        backgroundColor: scheme.surfaceContainerHighest,
        selectedColor: AppColors.maviCokAcik,
        labelStyle: TextStyle(
          color: scheme.onSurface, fontSize: 13, fontWeight: FontWeight.w500,
        ),
        side: BorderSide(color: scheme.outline),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.full),
        ),
      ),

      dividerTheme: DividerThemeData(
        color: scheme.outline.withValues(alpha: 0.5),
        thickness: 1,
        space: 1,
      ),
    );
  }
}