import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/sensor.dart';

class PengaturanHelper {
  PengaturanHelper._internal();

  static final PengaturanHelper instance = PengaturanHelper._internal();

  static const String kunciTemaGelap = 'tema_gelap';

  final ValueNotifier<Map<String, AmbangBatasSensor>> ambangNotifier =
      ValueNotifier<Map<String, AmbangBatasSensor>>(
        SensorInfo.defaultAmbangMap,
      );

  static String kunciWaspada(String jenisSensor) =>
      'batas_waspada_$jenisSensor';

  static String kunciSiaga(String jenisSensor) => 'batas_siaga_$jenisSensor';

  Future<Map<String, AmbangBatasSensor>> muatSemuaAmbang() async {
    final prefs = await SharedPreferences.getInstance();
    final hasil = <String, AmbangBatasSensor>{};
    for (final entry in SensorInfo.daftarMeta.entries) {
      final kode = entry.key;
      final meta = entry.value;
      final waspada = prefs.getDouble(kunciWaspada(kode)) ?? meta.defaultWaspada;
      final siaga = prefs.getDouble(kunciSiaga(kode)) ?? meta.defaultSiaga;
      hasil[kode] = AmbangBatasSensor(
        batasWaspada: waspada,
        batasSiaga: siaga,
      );
    }
    ambangNotifier.value = hasil;
    return hasil;
  }

  Future<void> simpanSemuaAmbang(
    Map<String, AmbangBatasSensor> daftarAmbang,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    for (final entry in daftarAmbang.entries) {
      await prefs.setDouble(
        kunciWaspada(entry.key),
        entry.value.batasWaspada,
      );
      await prefs.setDouble(kunciSiaga(entry.key), entry.value.batasSiaga);
    }
    ambangNotifier.value = Map<String, AmbangBatasSensor>.from(daftarAmbang);
  }

  Future<void> resetSemuaAmbang() async {
    final prefs = await SharedPreferences.getInstance();
    for (final kode in SensorInfo.daftarMeta.keys) {
      await prefs.remove(kunciWaspada(kode));
      await prefs.remove(kunciSiaga(kode));
    }
    ambangNotifier.value = SensorInfo.defaultAmbangMap;
  }

  Future<bool> muatTemaGelap() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(kunciTemaGelap) ?? false;
  }

  Future<void> simpanTemaGelap(bool aktif) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(kunciTemaGelap, aktif);
  }
}
