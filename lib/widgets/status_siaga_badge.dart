import 'package:flutter/material.dart';

import '../models/sensor.dart';

class StatusSiagaBadge extends StatelessWidget {
  final StatusSiaga status;

  const StatusSiagaBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final (warnaLatar, warnaTeks, ikon) = switch (status) {
      StatusSiaga.aman => (
          Colors.green.shade100,
          Colors.green.shade900,
          Icons.check_circle_outline,
        ),
      StatusSiaga.waspada => (
          Colors.orange.shade100,
          Colors.orange.shade900,
          Icons.warning_amber_rounded,
        ),
      StatusSiaga.siaga => (
          Colors.red.shade100,
          Colors.red.shade900,
          Icons.crisis_alert,
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: warnaLatar,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(ikon, size: 16, color: warnaTeks),
          const SizedBox(width: 4),
          Text(
            status.label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: warnaTeks,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }
}
