import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'cubit/sensor_cubit.dart';
import 'cubit/theme_cubit.dart';
import 'helpers/hive_helper.dart';
import 'helpers/pengaturan_helper.dart';
import 'pages/halaman_dashboard.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveHelper.instance.init();
  await PengaturanHelper.instance.muatSemuaAmbang();
  final temaGelap = await PengaturanHelper.instance.muatTemaGelap();
  runApp(
    AiotPeringatanDiniApp(
      temaAwal: temaGelap ? ThemeMode.dark : ThemeMode.light,
    ),
  );
}

class AiotPeringatanDiniApp extends StatelessWidget {
  final ThemeMode temaAwal;

  const AiotPeringatanDiniApp({
    super.key,
    this.temaAwal = ThemeMode.system,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => SensorCubit()),
        BlocProvider(create: (_) => ThemeCubit(temaAwal)),
      ],
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          return MaterialApp(
            title: 'AIoT Peringatan Dini Bencana',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeMode,
            home: const HalamanDashboard(),
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}
