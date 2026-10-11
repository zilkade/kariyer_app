class Ilan {
  final String id;
  final String kurum;
  final String baslik;
  final String tarihIso;
  final String bitIso;
  final int? kpss;
  final String kpssTurleri;
  final int favori;
  final int yeni;
  final int aktif;
  final String link;
  final String resim;
  final String notMetni;
  final String tarihGoster;
  final String bitGoster;
  final int? kalanGun;
  final String kpssGoster;

  Ilan({
    required this.id,
    required this.kurum,
    required this.baslik,
    required this.tarihIso,
    required this.bitIso,
    this.kpss,
    required this.kpssTurleri,
    required this.favori,
    required this.yeni,
    required this.aktif,
    required this.link,
    required this.resim,
    required this.notMetni,
    required this.tarihGoster,
    required this.bitGoster,
    this.kalanGun,
    required this.kpssGoster,
  });

  factory Ilan.fromJson(Map<String, dynamic> json) {
    return Ilan(
      id: json['id']?.toString() ?? '',
      kurum: json['kurum']?.toString() ?? '',
      baslik: json['baslik']?.toString() ?? '',
      tarihIso: json['tarih_iso']?.toString() ?? '',
      bitIso: json['bit_iso']?.toString() ?? '',
      kpss: json['kpss'] as int?,
      kpssTurleri: json['kpss_turleri']?.toString() ?? '',
      favori: (json['favori'] as num?)?.toInt() ?? 0,
      yeni: (json['yeni'] as num?)?.toInt() ?? 0,
      aktif: (json['aktif'] as num?)?.toInt() ?? 1,
      link: json['link']?.toString() ?? '',
      resim: json['resim']?.toString() ?? '',
      notMetni: json['not_metni']?.toString() ?? '',
      tarihGoster: json['tarih_goster']?.toString() ?? '',
      bitGoster: json['bit_goster']?.toString() ?? '',
      kalanGun: json['kalan_gun'] as int?,
      kpssGoster: json['kpss_goster']?.toString() ?? '',
    );
  }

  bool get favoriMi => favori == 1;
  bool get yeniMi => yeni == 1;
  bool get aktifMi => aktif == 1;
}