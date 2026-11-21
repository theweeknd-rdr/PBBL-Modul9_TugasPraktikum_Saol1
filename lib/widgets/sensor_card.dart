import 'package:flutter/material.dart';

import '../models/sensor.dart';
import 'status_siaga_badge.dart';

class SensorCard extends StatelessWidget {
  final SensorPemantauan sensor;
  final VoidCallback onCatat;
  final Map<String, AmbangBatasSensor>? ambangKustom;

  const SensorCard({
    super.key,
    required this.sensor,
    required this.onCatat,
    this.ambangKustom,
  });

  IconData _ikonUntuk(String jenisSensor) {
    return switch (jenisSensor) {
      SensorInfo.ketinggianAir => Icons.water,
      SensorInfo.pergeseranTanah => Icons.landslide,
      SensorInfo.curahHujan => Icons.cloudy_snowing,
      _ => Icons.sensors,
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final meta = SensorInfo.metaUntuk(sensor.jenisSensor);
    final status = SensorInfo.evaluasiNilai(
      sensor.jenisSensor,
      sensor.nilaiTerkini,
      ambangKustom: ambangKustom,
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _ikonUntuk(sensor.jenisSensor),
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          meta.nama,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      StatusSiagaBadge(status: status),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${sensor.lokasiPos} • ${sensor.waktuTerakhir}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${sensor.nilaiTerkini} ${meta.satuan}',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filledTonal(
              onPressed: onCatat,
              tooltip: 'Simpan ke Hive',
              icon: const Icon(Icons.save_alt),
            ),
          ],
        ),
      ),
    );
  }
}
