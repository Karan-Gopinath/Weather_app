
import 'package:flutter/material.dart';

IconData getWeatherIcon(String main) {
  switch (main) {
    case 'Thunderstorm':
      return Icons.flash_on;
    case 'Drizzle':
      return Icons.grain;
    case 'Rain':
      return Icons.water_drop;
    case 'Snow':
      return Icons.ac_unit;
    case 'Clear':
      return Icons.wb_sunny;
    case 'Clouds':
      return Icons.cloud;
    case 'Mist':
    case 'Smoke':
    case 'Haze':
    case 'Dust':
    case 'Fog':
    case 'Sand':
    case 'Ash':
    case 'Squall':
    case 'Tornado':
      return Icons.foggy;
    default:
      return Icons.cloud;
  }
}

String getWindDirection(double deg) {
  if (deg >= 337.5 || deg < 22.5) return 'N';
  if (deg >= 22.5 && deg < 67.5) return 'NE';
  if (deg >= 67.5 && deg < 112.5) return 'E';
  if (deg >= 112.5 && deg < 157.5) return 'SE';
  if (deg >= 157.5 && deg < 202.5) return 'S';
  if (deg >= 202.5 && deg < 247.5) return 'SW';
  if (deg >= 247.5 && deg < 292.5) return 'W';
  if (deg >= 292.5 && deg < 337.5) return 'NW';
  return 'N';
}
