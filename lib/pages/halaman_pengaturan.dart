import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/theme_cubit.dart';
import '../helpers/pengaturan_helper.dart';
import '../models/sensor.dart';
import '../widgets/primary_button.dart';

class HalamanPengaturan extends StatefulWidget {
  const HalamanPengaturan({super.key});

  @override
  State<HalamanPengaturan> createState() => _HalamanPengaturanState();
}

class _HalamanPengaturanState extends State<HalamanPengaturan> {
  final Map<String, TextEditingController> _waspadaControllers = {};
  final Map<String, TextEditingController> _siagaControllers = {};
  bool _temaGelap = false;
  bool _memuat = true;

  @override
  void initState() {
    super.initState();
    for (final entry in SensorInfo.daftarMeta.entries) {
      _waspadaControllers[entry.key] = TextEditingController();
      _siagaControllers[entry.key] = TextEditingController();
    }
    _muatPengaturan();
  }

  Future<void> _muatPengaturan() async {
    final ambang = await PengaturanHelper.instance.muatSemuaAmbang();
    final gelap = await PengaturanHelper.instance.muatTemaGelap();
    for (final kode in SensorInfo.daftarMeta.keys) {
      final nilai = ambang[kode]!;
      _waspadaControllers[kode]!.text = _formatAngka(nilai.batasWaspada);
      _siagaControllers[kode]!.text = _formatAngka(nilai.batasSiaga);
    }
    if (!mounted) return;
    setState(() {
      _temaGelap = gelap;
      _memuat = false;
    });
  }

  String _formatAngka(double nilai) {
    return nilai == nilai.roundToDouble()
        ? nilai.toInt().toString()
        : nilai.toString();
  }

  Future<void> _simpanPengaturan() async {
    final baru = <String, AmbangBatasSensor>{};
    for (final entry in SensorInfo.daftarMeta.entries) {
      final kode = entry.key;
      final meta = entry.value;
      final waspada = double.tryParse(
        _waspadaControllers[kode]!.text.replaceAll(',', '.'),
      );
      final siaga = double.tryParse(
        _siagaControllers[kode]!.text.replaceAll(',', '.'),
      );
      if (waspada == null || siaga == null || waspada <= 0 || waspada >= siaga) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Ambang ${meta.nama} tidak valid (Waspada harus lebih kecil dari Siaga).',
            ),
          ),
        );
        return;
      }
      baru[kode] = AmbangBatasSensor(
        batasWaspada: waspada,
        batasSiaga: siaga,
      );
    }

    await PengaturanHelper.instance.simpanSemuaAmbang(baru);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Ambang batas status siaga disimpan ke SharedPreferences.'),
      ),
    );
  }

  Future<void> _resetDefault() async {
    await PengaturanHelper.instance.resetSemuaAmbang();
    final defaultMap = SensorInfo.defaultAmbangMap;
    for (final kode in SensorInfo.daftarMeta.keys) {
      _waspadaControllers[kode]!.text = _formatAngka(
        defaultMap[kode]!.batasWaspada,
      );
      _siagaControllers[kode]!.text = _formatAngka(
        defaultMap[kode]!.batasSiaga,
      );
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Ambang batas dikembalikan ke nilai default.'),
      ),
    );
  }

  @override
  void dispose() {
    for (final c in _waspadaControllers.values) {
      c.dispose();
    }
    for (final c in _siagaControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Pengaturan Ambang Batas')),
      body: _memuat
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  margin: EdgeInsets.zero,
                  child: SwitchListTile(
                    title: const Text('Mode Gelap'),
                    subtitle: const Text(
                      'Preferensi tema tersimpan di SharedPreferences',
                    ),
                    value: _temaGelap,
                    onChanged: (nilai) async {
                      setState(() => _temaGelap = nilai);
                      await PengaturanHelper.instance.simpanTemaGelap(nilai);
                      if (!context.mounted) return;
                      context.read<ThemeCubit>().setDark(nilai);
                    },
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Ambang Batas Status Siaga BPBD',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ...SensorInfo.daftarMeta.values.map(
                  (meta) => Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${meta.nama} (${meta.satuan})',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _waspadaControllers[meta.kode],
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                        decimal: true,
                                      ),
                                  decoration: const InputDecoration(
                                    labelText: 'Batas Waspada',
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextField(
                                  controller: _siagaControllers[meta.kode],
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                        decimal: true,
                                      ),
                                  decoration: const InputDecoration(
                                    labelText: 'Batas Siaga',
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _resetDefault,
                        icon: const Icon(Icons.restore),
                        label: const Text('Reset Default'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: PrimaryButton(
                        label: 'Simpan',
                        icon: Icons.save,
                        onPressed: _simpanPengaturan,
                      ),
                    ),
                  ],
                ),
              ],
            ),
    );
  }
}
