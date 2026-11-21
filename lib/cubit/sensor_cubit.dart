import 'dart:math';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/sensor.dart';

class SensorCubit extends Cubit<List<SensorPemantauan>> {
  SensorCubit()
      : super(const [
          SensorPemantauan(
            jenisSensor: SensorInfo.ketinggianAir,
            lokasiPos: 'Pos Dayeuhkolot',
            nilaiTerkini: 85.0,
            waktuTerakhir: 'Belum tercatat',
          ),
          SensorPemantauan(
            jenisSensor: SensorInfo.pergeseranTanah,
            lokasiPos: 'Pos Lembang',
            nilaiTerkini: 4.2,
            waktuTerakhir: 'Belum tercatat',
          ),
          SensorPemantauan(
            jenisSensor: SensorInfo.curahHujan,
            lokasiPos: 'Pos Majalaya',
            nilaiTerkini: 12.5,
            waktuTerakhir: 'Belum tercatat',
          ),
        ]);

  final _random = Random();

  void perbaruiSensor({
    required String jenisSensor,
    required double nilaiBaru,
    required String lokasiPos,
    required String waktu,
  }) {
    final daftar = state.map((sensor) {
      if (sensor.jenisSensor == jenisSensor) {
        return sensor.copyWith(
          nilaiTerkini: nilaiBaru,
          lokasiPos: lokasiPos,
          waktuTerakhir: waktu,
        );
      }
      return sensor;
    }).toList();
    emit(daftar);
  }

  List<SensorPemantauan> simulasikanSemua({required String waktu}) {
    final daftarBaru = state.map((sensor) {
      final nilai = switch (sensor.jenisSensor) {
        SensorInfo.ketinggianAir => 70.0 + _random.nextInt(170),
        SensorInfo.pergeseranTanah =>
          double.parse((2.0 + _random.nextDouble() * 28.0).toStringAsFixed(1)),
        SensorInfo.curahHujan =>
          double.parse((5.0 + _random.nextDouble() * 60.0).toStringAsFixed(1)),
        _ => 10.0,
      };
      return sensor.copyWith(
        nilaiTerkini: nilai,
        waktuTerakhir: waktu,
      );
    }).toList();

    emit(daftarBaru);
    return daftarBaru;
  }
}
