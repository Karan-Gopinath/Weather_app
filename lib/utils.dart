import 'package:flutter/material.dart';

IconData getWeatherIcon(String condition) {
  // Convert condition to lowercase for case-insensitive matching
  switch (condition.toLowerCase()) {
    case 'clear':
      return Icons.wb_sunny;
    case 'clouds':
      return Icons.cloud;
    case 'rain':
      return Icons.beach_access;  // Consider using Icons.umbrella for rain
    case 'snow':
      return Icons.ac_unit;
    case 'thunderstorm':
      return Icons.flash_on;
    case 'drizzle':
      return Icons.grain;
    case 'mist':
    case 'smoke':
    case 'haze':
    case 'dust':
    case 'fog':
    case 'sand':
    case 'ash':
      return Icons.foggy;
    case 'squall':
    case 'tornado':
      return Icons.storm;
    default:
      return Icons.wb_cloudy;
  }
}

String getWindDirection(double deg) {
  // Normalize degree value to 0-360 range
  final normalizedDeg = deg % 360;
  
  if (normalizedDeg >= 337.5 || normalizedDeg < 22.5) return 'N';
  if (normalizedDeg >= 22.5 && normalizedDeg < 67.5) return 'NE';
  if (normalizedDeg >= 67.5 && normalizedDeg < 112.5) return 'E';
  if (normalizedDeg >= 112.5 && normalizedDeg < 157.5) return 'SE';
  if (normalizedDeg >= 157.5 && normalizedDeg < 202.5) return 'S';
  if (normalizedDeg >= 202.5 && normalizedDeg < 247.5) return 'SW';
  if (normalizedDeg >= 247.5 && normalizedDeg < 292.5) return 'W';
  return 'NW';
}

// Bonus: Add weather icon mapping for clearer weather representation
String getWeatherCondition(String condition) {
  switch (condition.toLowerCase()) {
    case 'clear':
      return 'Clear sky';
    case 'clouds':
      return 'Cloudy';
    case 'rain':
      return 'Rainy';
    case 'snow':
      return 'Snowy';
    case 'thunderstorm':
      return 'Thunderstorm';
    case 'drizzle':
      return 'Drizzle';
    case 'mist':
      return 'Misty';
    default:
      return condition;
  }
}