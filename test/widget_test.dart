import 'package:flutter_test/flutter_test.dart';
import 'package:aiot_peringatan_dini_hive/main.dart';
import 'package:aiot_peringatan_dini_hive/models/pembacaan_sensor.dart';
import 'package:aiot_peringatan_dini_hive/models/sensor.dart';

void main() {
  test('PembacaanSensor preserves fields and evaluates status', () {
    final pembacaan = PembacaanSensor(
      id: 'ps_1',
      jenisSensor: SensorInfo.ketinggianAir,
      nilai: 165.0,
      lokasiPos: 'Pos Dayeuhkolot',
      waktu: '2026-11-21 22:00:00',
    );

    expect(pembacaan.id, 'ps_1');
    expect(pembacaan.jenisSensor, SensorInfo.ketinggianAir);
    expect(pembacaan.nilai, 165.0);
    expect(
      SensorInfo.evaluasiNilai(pembacaan.jenisSensor, pembacaan.nilai),
      StatusSiaga.waspada,
    );
  });

  testWidgets('AiotPeringatanDiniApp renders dashboard', (tester) async {
    await tester.pumpWidget(const AiotPeringatanDiniApp());

    expect(find.text('AIoT Peringatan Dini'), findsOneWidget);
    expect(find.text('Ketinggian Air Sungai'), findsOneWidget);
  });
}
