import 'package:hive_flutter/hive_flutter.dart';

import '../models/pembacaan_sensor.dart';
import '../models/sensor.dart';

class HiveHelper {
  HiveHelper._internal();

  static final HiveHelper instance = HiveHelper._internal();

  static const String namaBoxPembacaan = 'pembacaanSensorBox';

  Future<void> init() async {
    await Hive.initFlutter();
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(PembacaanSensorAdapter());
    }
    await Hive.openBox<PembacaanSensor>(namaBoxPembacaan);
  }

  bool get isReady => Hive.isBoxOpen(namaBoxPembacaan);

  Box<PembacaanSensor> get box => Hive.box<PembacaanSensor>(namaBoxPembacaan);

  Future<void> tambahPembacaan(PembacaanSensor pembacaan) async {
    await box.put(pembacaan.id, pembacaan);
  }

  List<PembacaanSensor> ambilSemuaPembacaan() {
    final daftar = box.values.toList();
    daftar.sort((a, b) {
      final cmpWaktu = b.waktu.compareTo(a.waktu);
      if (cmpWaktu != 0) return cmpWaktu;
      return b.id.compareTo(a.id);
    });
    return daftar;
  }

  Future<void> ubahPembacaan(PembacaanSensor pembacaan) async {
    await box.put(pembacaan.id, pembacaan);
  }

  Future<void> hapusPembacaan(String id) async {
    await box.delete(id);
  }

  StatusSiaga hitungStatusSiagaTerbaru(
    Map<String, AmbangBatasSensor> ambang,
  ) {
    final semua = ambilSemuaPembacaan();
    if (semua.isEmpty) return StatusSiaga.aman;

    final terbaruPerJenis = <String, PembacaanSensor>{};
    for (final item in semua) {
      terbaruPerJenis.putIfAbsent(item.jenisSensor, () => item);
    }

    final statusPerJenis = terbaruPerJenis.values.map(
      (item) => SensorInfo.evaluasiNilai(
        item.jenisSensor,
        item.nilai,
        ambangKustom: ambang,
      ),
    );
    return SensorInfo.gabungStatusTertinggi(statusPerJenis);
  }
}
