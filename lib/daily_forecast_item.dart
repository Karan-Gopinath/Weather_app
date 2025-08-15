
import 'package:flutter/material.dart';

class DailyForecast extends StatelessWidget {
  final String date;
  final String minTemp;
  final String maxTemp;
  final IconData icon;
  final String pop;

  const DailyForecast({
    super.key,
    required this.date,
    required this.minTemp,
    required this.maxTemp,
    required this.icon,
    required this.pop,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        width: 140,
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(date, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Icon(icon, size: 32),
            const SizedBox(height: 8),
            Text('$minTemp / $maxTemp'),
            const SizedBox(height: 8),
            Text('Precip: $pop'),
          ],
        ),
      ),
    );
  }
}
