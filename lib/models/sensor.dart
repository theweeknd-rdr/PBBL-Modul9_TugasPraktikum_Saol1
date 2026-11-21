enum StatusSiaga {
  aman('Aman'),
  waspada('Waspada'),
  siaga('Siaga');

  final String label;
  const StatusSiaga(this.label);
}

class AmbangBatasSensor {
  final double batasWaspada;
  final double batasSiaga;

  const AmbangBatasSensor({
    required this.batasWaspada,
    required this.batasSiaga,
  });
}

class JenisSensorMeta {
  final String kode;
  final String nama;
  final String satuan;
  final double defaultWaspada;
  final double defaultSiaga;

  const JenisSensorMeta({
    required this.kode,
    required this.nama,
    required this.satuan,
    required this.defaultWaspada,
    required this.defaultSiaga,
  });
}

class SensorInfo {
  static const ketinggianAir = 'ketinggian_air';
  static const pergeseranTanah = 'pergeseran_tanah';
  static const curahHujan = 'curah_hujan';

  static const Map<String, JenisSensorMeta> daftarMeta = {
    ketinggianAir: JenisSensorMeta(
      kode: ketinggianAir,
      nama: 'Ketinggian Air Sungai',
      satuan: 'cm',
      defaultWaspada: 120,
      defaultSiaga: 200,
    ),
    pergeseranTanah: JenisSensorMeta(
      kode: pergeseranTanah,
      nama: 'Pergeseran Tanah',
      satuan: 'mm',
      defaultWaspada: 10,
      defaultSiaga: 25,
    ),
    curahHujan: JenisSensorMeta(
      kode: curahHujan,
      nama: 'Curah Hujan',
      satuan: 'mm/jam',
      defaultWaspada: 20,
      defaultSiaga: 50,
    ),
  };

  static Map<String, AmbangBatasSensor> get defaultAmbangMap => {
        for (final entry in daftarMeta.entries)
          entry.key: AmbangBatasSensor(
            batasWaspada: entry.value.defaultWaspada,
            batasSiaga: entry.value.defaultSiaga,
          ),
      };

  static JenisSensorMeta metaUntuk(String jenisSensor) {
    return daftarMeta[jenisSensor] ??
        JenisSensorMeta(
          kode: jenisSensor,
          nama: jenisSensor,
          satuan: '',
          defaultWaspada: 50,
          defaultSiaga: 100,
        );
  }

  static StatusSiaga evaluasiNilai(
    String jenisSensor,
    double nilai, {
    Map<String, AmbangBatasSensor>? ambangKustom,
  }) {
    final kustom = ambangKustom?[jenisSensor];
    final meta = metaUntuk(jenisSensor);
    final batasSiaga = kustom?.batasSiaga ?? meta.defaultSiaga;
    final batasWaspada = kustom?.batasWaspada ?? meta.defaultWaspada;
    if (nilai >= batasSiaga) return StatusSiaga.siaga;
    if (nilai >= batasWaspada) return StatusSiaga.waspada;
    return StatusSiaga.aman;
  }

  static StatusSiaga gabungStatusTertinggi(Iterable<StatusSiaga> daftar) {
    var tertinggi = StatusSiaga.aman;
    for (final status in daftar) {
      if (status.index > tertinggi.index) {
        tertinggi = status;
      }
    }
    return tertinggi;
  }
}

class SensorPemantauan {
  final String jenisSensor;
  final String lokasiPos;
  final double nilaiTerkini;
  final String waktuTerakhir;

  const SensorPemantauan({
    required this.jenisSensor,
    required this.lokasiPos,
    required this.nilaiTerkini,
    required this.waktuTerakhir,
  });

  SensorPemantauan copyWith({
    String? lokasiPos,
    double? nilaiTerkini,
    String? waktuTerakhir,
  }) {
    return SensorPemantauan(
      jenisSensor: jenisSensor,
      lokasiPos: lokasiPos ?? this.lokasiPos,
      nilaiTerkini: nilaiTerkini ?? this.nilaiTerkini,
      waktuTerakhir: waktuTerakhir ?? this.waktuTerakhir,
    );
  }
}
