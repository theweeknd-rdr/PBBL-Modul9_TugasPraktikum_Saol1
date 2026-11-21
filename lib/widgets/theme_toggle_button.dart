import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/theme_cubit.dart';
import '../helpers/pengaturan_helper.dart';

class ThemeToggleButton extends StatelessWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    final themeMode = context.watch<ThemeCubit>().state;
    final isDark =
        themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system &&
            MediaQuery.platformBrightnessOf(context) == Brightness.dark);

    return IconButton(
      icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
      onPressed: () async {
        final nextDark = !isDark;
        context.read<ThemeCubit>().setDark(nextDark);
        await PengaturanHelper.instance.simpanTemaGelap(nextDark);
      },
      tooltip: 'Ganti Tema',
    );
  }
}
