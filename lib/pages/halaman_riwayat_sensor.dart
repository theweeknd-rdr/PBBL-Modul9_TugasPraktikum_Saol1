import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../helpers/hive_helper.dart';
import '../helpers/pengaturan_helper.dart';
import '../models/pembacaan_sensor.dart';
import '../models/sensor.dart';
import '../widgets/status_siaga_badge.dart';

class HalamanRiwayatSensor extends StatefulWidget {
  const HalamanRiwayatSensor({super.key});

  @override
  State<HalamanRiwayatSensor> createState() => _HalamanRiwayatSensorState();
}

class _HalamanRiwayatSensorState extends State<HalamanRiwayatSensor> {
  Future<void> _koreksiNilai(PembacaanSensor pembacaan) async {
    final controller = TextEditingController(
      text: pembacaan.nilai.toString(),
    );
    final meta = SensorInfo.metaUntuk(pembacaan.jenisSensor);

    final nilaiBaru = await showDialog<double>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Koreksi ${meta.nama}'),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: 'Nilai (${meta.satuan})',
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(
              dialogContext,
              double.tryParse(controller.text.replaceAll(',', '.')),
            ),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );

    if (nilaiBaru != null) {
      pembacaan.nilai = nilaiBaru;
      await HiveHelper.instance.ubahPembacaan(pembacaan);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Map<String, AmbangBatasSensor>>(
      valueListenable: PengaturanHelper.instance.ambangNotifier,
      builder: (context, ambang, _) {
        return ValueListenableBuilder<Box<PembacaanSensor>>(
          valueListenable: HiveHelper.instance.box.listenable(),
          builder: (context, box, _) {
            final daftar = HiveHelper.instance.ambilSemuaPembacaan();
            final statusSiaga =
                HiveHelper.instance.hitungStatusSiagaTerbaru(ambang);

            return Scaffold(
              appBar: AppBar(
                title: const Text('Riwayat Sensor'),
                actions: [
                  Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: StatusSiagaBadge(status: statusSiaga),
                  ),
                ],
              ),
              body: daftar.isEmpty
                  ? const Center(
                      child: Text('Belum ada riwayat pembacaan sensor.'),
                    )
                  : ListView.builder(
                      itemCount: daftar.length,
                      itemBuilder: (context, index) {
                        final item = daftar[index];
                        final meta = SensorInfo.metaUntuk(item.jenisSensor);
                        final statusItem = SensorInfo.evaluasiNilai(
                          item.jenisSensor,
                          item.nilai,
                          ambangKustom: ambang,
                        );

                        return Dismissible(
                          key: ValueKey(item.id),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            color: Colors.red,
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: const Icon(
                              Icons.delete,
                              color: Colors.white,
                            ),
                          ),
                          onDismissed: (direction) async {
                            await HiveHelper.instance.hapusPembacaan(item.id);
                          },
                          child: Card(
                            child: ListTile(
                              title: Text('${meta.nama} (${item.jenisSensor})'),
                              subtitle: Text(
                                '${item.lokasiPos} • ${item.waktu}',
                              ),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '${item.nilai} ${meta.satuan}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    statusItem.label,
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelSmall,
                                  ),
                                ],
                              ),
                              onTap: () => _koreksiNilai(item),
                            ),
                          ),
                        );
                      },
                    ),
            );
          },
        );
      },
    );
  }
}
