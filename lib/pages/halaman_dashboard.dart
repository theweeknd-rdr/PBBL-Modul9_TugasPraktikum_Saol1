import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/sensor_cubit.dart';
import '../helpers/hive_helper.dart';
import '../helpers/pengaturan_helper.dart';
import '../models/pembacaan_sensor.dart';
import '../models/sensor.dart';
import '../widgets/primary_button.dart';
import '../widgets/sensor_card.dart';
import '../widgets/theme_toggle_button.dart';
import 'halaman_pengaturan.dart';
import 'halaman_riwayat_sensor.dart';

class HalamanDashboard extends StatefulWidget {
  const HalamanDashboard({super.key});

  @override
  State<HalamanDashboard> createState() => _HalamanDashboardState();
}

class _HalamanDashboardState extends State<HalamanDashboard> {
  int _urutanId = 0;

  String _formatWaktuSekarang() {
    return DateTime.now().toString().substring(0, 19);
  }

  String _buatIdUnik(String jenisSensor) {
    _urutanId++;
    return '${DateTime.now().microsecondsSinceEpoch}_${_urutanId}_$jenisSensor';
  }

  Future<void> _simpanSensorKeHive(
    BuildContext context,
    SensorPemantauan sensor,
  ) async {
    final waktu = _formatWaktuSekarang();
    context.read<SensorCubit>().perbaruiSensor(
          jenisSensor: sensor.jenisSensor,
          nilaiBaru: sensor.nilaiTerkini,
          lokasiPos: sensor.lokasiPos,
          waktu: waktu,
        );
    await HiveHelper.instance.tambahPembacaan(
      PembacaanSensor(
        id: _buatIdUnik(sensor.jenisSensor),
        jenisSensor: sensor.jenisSensor,
        nilai: sensor.nilaiTerkini,
        lokasiPos: sensor.lokasiPos,
        waktu: waktu,
      ),
    );
    if (!context.mounted) return;
    final nama = SensorInfo.metaUntuk(sensor.jenisSensor).nama;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Pembacaan $nama disimpan ke Hive.')),
    );
  }

  Future<void> _simulasikanDanSimpan(BuildContext context) async {
    final waktu = _formatWaktuSekarang();
    final hasil = context.read<SensorCubit>().simulasikanSemua(waktu: waktu);
    for (final sensor in hasil) {
      await HiveHelper.instance.tambahPembacaan(
        PembacaanSensor(
          id: _buatIdUnik(sensor.jenisSensor),
          jenisSensor: sensor.jenisSensor,
          nilai: sensor.nilaiTerkini,
          lokasiPos: sensor.lokasiPos,
          waktu: waktu,
        ),
      );
    }
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Simulasi 3 sensor berhasil dicatat ke Hive.'),
      ),
    );
  }

  Future<void> _bukaDialogInputManual(BuildContext context) async {
    String jenisDipilih = SensorInfo.ketinggianAir;
    final nilaiController = TextEditingController();
    final lokasiController = TextEditingController(text: 'Pos Dayeuhkolot');

    final simpan = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          title: const Text('Input Pembacaan Sensor'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  initialValue: jenisDipilih,
                  decoration: const InputDecoration(
                    labelText: 'Jenis Sensor',
                    border: OutlineInputBorder(),
                  ),
                  items: SensorInfo.daftarMeta.values
                      .map(
                        (meta) => DropdownMenuItem(
                          value: meta.kode,
                          child: Text('${meta.nama} (${meta.satuan})'),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setDialogState(() => jenisDipilih = value);
                    }
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: nilaiController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Nilai Pembacaan',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: lokasiController,
                  decoration: const InputDecoration(
                    labelText: 'Lokasi Pos Pemantauan',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );

    if (simpan != true || !context.mounted) return;
    final nilai = double.tryParse(nilaiController.text.replaceAll(',', '.'));
    final lokasi = lokasiController.text.trim();
    if (nilai == null || lokasi.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Masukkan nilai angka dan lokasi pos yang valid.'),
        ),
      );
      return;
    }

    final waktu = _formatWaktuSekarang();
    context.read<SensorCubit>().perbaruiSensor(
          jenisSensor: jenisDipilih,
          nilaiBaru: nilai,
          lokasiPos: lokasi,
          waktu: waktu,
        );
    await HiveHelper.instance.tambahPembacaan(
      PembacaanSensor(
        id: _buatIdUnik(jenisDipilih),
        jenisSensor: jenisDipilih,
        nilai: nilai,
        lokasiPos: lokasi,
        waktu: waktu,
      ),
    );
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Data pembacaan manual disimpan ke Hive.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('AIoT Peringatan Dini'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'Riwayat Sensor',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const HalamanRiwayatSensor(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.tune),
            tooltip: 'Pengaturan Ambang Batas',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const HalamanPengaturan(),
                ),
              );
            },
          ),
          const ThemeToggleButton(),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Text(
              'Pemantauan Langsung Sensor BPBD',
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: ValueListenableBuilder<Map<String, AmbangBatasSensor>>(
              valueListenable: PengaturanHelper.instance.ambangNotifier,
              builder: (context, ambang, _) {
                return BlocBuilder<SensorCubit, List<SensorPemantauan>>(
                  builder: (context, daftarSensor) {
                    return ListView.builder(
                      itemCount: daftarSensor.length,
                      itemBuilder: (context, index) {
                        final sensor = daftarSensor[index];
                        return SensorCard(
                          sensor: sensor,
                          ambangKustom: ambang,
                          onCatat: () => _simpanSensorKeHive(context, sensor),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            color: theme.colorScheme.surfaceContainerHighest,
            child: Row(
              children: [
                Expanded(
                  child: PrimaryButton(
                    label: 'Simulasi',
                    icon: Icons.sensors,
                    onPressed: () => _simulasikanDanSimpan(context),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: PrimaryButton(
                    label: 'Input Manual',
                    icon: Icons.add_chart,
                    onPressed: () => _bukaDialogInputManual(context),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
