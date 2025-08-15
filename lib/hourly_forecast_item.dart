import 'package:flutter/material.dart';

class HourlyForecast extends StatelessWidget {
  final String time;
  final String temperature;
  final IconData icon;
  final String pop;

  const HourlyForecast({
    super.key,
    required this.time,
    required this.temperature,
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
            Text(time, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Icon(icon, size: 32),
            const SizedBox(height: 8),
            Text(temperature),
            const SizedBox(height: 8),
            Text('Precip: $pop'),
          ],
        ),
      ),
    );
  }
}