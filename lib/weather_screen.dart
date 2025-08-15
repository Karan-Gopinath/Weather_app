
import 'dart:convert';
import 'dart:ui' show FontWeight, ImageFilter;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:myapp/additional_info_item.dart';
import 'package:myapp/hourly_forecast_item.dart';
import 'package:myapp/daily_forecast_item.dart';
import 'package:myapp/utils.dart';
import 'package:myapp/secrets.dart';

class WeatherScreen extends StatefulWidget {
  final Function(ThemeMode) onThemeChanged;
  const WeatherScreen({super.key, required this.onThemeChanged});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  late Future<Map<String, dynamic>> weather;
  String cityName = 'London';
  double? lat;
  double? lon;
  String units = 'metric';
  List<String> favorites = [];
  bool isFavorite = false;

  String get unitSymbol => units == 'metric' ? 'C' : 'F';
  String get windUnit => units == 'metric' ? 'm/s' : 'mph';
  String get visibilityUnit => units == 'metric' ? 'km' : 'mi';

  @override
  void initState() {
    super.initState();
    _loadFavorites();
    weather = getWeather();
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      favorites = prefs.getStringList('favorites') ?? [];
      isFavorite = favorites.contains(cityName);
    });
  }

  Future<void> _toggleFavorite() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      if (isFavorite) {
        favorites.remove(cityName);
      } else {
        if (!favorites.contains(cityName)) {
          favorites.add(cityName);
        }
      }
      isFavorite = !isFavorite;
      prefs.setStringList('favorites', favorites);
    });
  }

  Future<Map<String, dynamic>> getWeather() async {
    try {
      Uri currentUri;
      Uri forecastUri;
      if (lat != null && lon != null) {
        currentUri = Uri.parse(
            'https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&appid=$openweatherApi&units=$units');
        forecastUri = Uri.parse(
            'https://api.openweathermap.org/data/2.5/forecast?lat=$lat&lon=$lon&appid=$openweatherApi&units=$units');
      } else {
        currentUri = Uri.parse(
            'https://api.openweathermap.org/data/2.5/weather?q=$cityName&appid=$openweatherApi&units=$units');
        forecastUri = Uri.parse(
            'https://api.openweathermap.org/data/2.5/forecast?q=$cityName&appid=$openweatherApi&units=$units');
      }

      final currentRes = await http.get(currentUri);
      final forecastRes = await http.get(forecastUri);

      final currentData = jsonDecode(currentRes.body);
      final forecastData = jsonDecode(forecastRes.body);

      if (int.tryParse(currentData['cod'].toString()) != 200) {
        throw currentData['message'] ?? 'An unexpected error occurred';
      }
      if (forecastData['cod'] != '200') {
        throw 'An unexpected error occurred with forecast';
      }

      return {'current': currentData, 'forecast': forecastData};
    } catch (e) {
      throw e.toString();
    }
  }

  Future<void> getLocation() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (scaffoldMessenger.mounted) {
          scaffoldMessenger.showSnackBar(
            SnackBar(
              content: const Text('Location services are disabled. Please enable them.'),
              action: SnackBarAction(
                label: 'Settings',
                onPressed: () async {
                  await Geolocator.openLocationSettings();
                },
              ),
            ),
          );
        }
        throw 'Location services are disabled.';
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (scaffoldMessenger.mounted) {
            scaffoldMessenger.showSnackBar(
              const SnackBar(content: Text('Location permissions are denied.')),
            );
          }
          throw 'Location permissions are denied.';
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (scaffoldMessenger.mounted) {
          scaffoldMessenger.showSnackBar(
            SnackBar(
              content: const Text('Location permissions are permanently denied. Please enable them in settings.'),
              action: SnackBarAction(
                label: 'Settings',
                onPressed: () async {
                  await Geolocator.openAppSettings();
                },
              ),
            ),
          );
        }
        throw 'Location permissions are permanently denied.';
      }

      // ignore: deprecated_member_use
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      if (!mounted) return;
      setState(() {
        lat = position.latitude;
        lon = position.longitude;
        cityName = '';
        weather = getWeather();
      });
    } catch (e) {
      if (scaffoldMessenger.mounted) {
        scaffoldMessenger.showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  void showSearchDialog() {
    showDialog(
      context: context,
      builder: (ctx) {
        final controller = TextEditingController();
        return AlertDialog(
          title: const Text('Search City'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: 'Enter city name',
              border: OutlineInputBorder(),
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  setState(() {
                    cityName = controller.text.trim();
                    lat = null;
                    lon = null;
                    weather = getWeather();
                  });
                }
                Navigator.pop(ctx);
              },
              child: const Text('Search'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather App'),
        centerTitle: true,
        actions: [
          if (cityName.isNotEmpty)
            IconButton(
              onPressed: _toggleFavorite,
              icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border),
              tooltip: 'Favorite',
            ),
          IconButton(
            onPressed: getLocation,
            icon: const Icon(Icons.location_on),
            tooltip: 'Use Current Location',
          ),
          IconButton(
            onPressed: showSearchDialog,
            icon: const Icon(Icons.search),
            tooltip: 'Search City',
          ),
          IconButton(
            onPressed: () {
              setState(() {
                weather = getWeather();
              });
            },
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
          PopupMenuButton<ThemeMode>(
            icon: const Icon(Icons.brightness_6),
            tooltip: 'Change Theme',
            onSelected: widget.onThemeChanged,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: ThemeMode.system,
                child: Text('System'),
              ),
              const PopupMenuItem(
                value: ThemeMode.light,
                child: Text('Light'),
              ),
              const PopupMenuItem(
                value: ThemeMode.dark,
                child: Text('Dark'),
              ),
            ],
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary),
              child: const Text(
                'Favorite Cities',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ...favorites.map(
              (fav) => ListTile(
                title: Text(fav),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () async {
                    final prefs = await SharedPreferences.getInstance();
                    setState(() {
                      favorites.remove(fav);
                      prefs.setStringList('favorites', favorites);
                      if (cityName == fav) isFavorite = false;
                    });
                  },
                ),
                onTap: () {
                  setState(() {
                    cityName = fav;
                    lat = null;
                    lon = null;
                    weather = getWeather();
                    isFavorite = true;
                  });
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
      body: FutureBuilder(
        future: weather,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.red)));
          }

          final data = snapshot.data!;
          final current = data['current'];
          final forecast = data['forecast'];

          final currentTemp = current['main']['temp'].toStringAsFixed(0);
          final feelsLike = current['main']['feels_like'].toStringAsFixed(0);
          final currentSkyMain = current['weather'][0]['main'];
          final currentSkyDesc = current['weather'][0]['description']
              .split(' ')
              .map((w) => w[0].toUpperCase() + w.substring(1))
              .join(' ');
          final currentPressure = current['main']['pressure'].toString();
          final currentHumidity = current['main']['humidity'].toString();
          final currentWind = current['wind']['speed'].toStringAsFixed(1);
          final windDeg = current['wind']['deg'].toDouble();
          final currentVisibility = units == 'metric'
              ? (current['visibility'] / 1000).toStringAsFixed(1)
              : (current['visibility'] / 1609).toStringAsFixed(1);
          double precip = 0;
          if (current.containsKey('rain')) precip += current['rain']['1h'] ?? 0.0;
          if (current.containsKey('snow')) precip += current['snow']['1h'] ?? 0.0;
          final sunriseTime = DateFormat('HH:mm').format(
              DateTime.fromMillisecondsSinceEpoch(current['sys']['sunrise'] * 1000));
          final sunsetTime = DateFormat('HH:mm').format(
              DateTime.fromMillisecondsSinceEpoch(current['sys']['sunset'] * 1000));
          final displayCity = current['name'] ?? cityName;
          if (cityName.isEmpty && displayCity.isNotEmpty) {
            cityName = displayCity;
            isFavorite = favorites.contains(cityName);
          }

          final hourlyList = forecast['list'].take(5).toList();

          final grouped = <String, List<dynamic>>{};
          for (var item in forecast['list']) {
            final date = item['dt_txt'].substring(0, 10);
            grouped.putIfAbsent(date, () => []);
            grouped[date]!.add(item);
          }

          final dailyForecast = [];
          final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
          for (var entry in grouped.entries) {
            if (entry.key == today) continue;
            final temps = entry.value.map((e) => e['main']['temp'] as double).toList();
            final minTemp = temps.reduce((a, b) => a < b ? a : b);
            final maxTemp = temps.reduce((a, b) => a > b ? a : b);
            final maxPop = entry.value.map((e) => e['pop'] as double).reduce((a, b) => a > b ? a : b) * 100;
            final repItem = entry.value.firstWhere(
              (e) => DateTime.parse(e['dt_txt']).hour >= 12,
              orElse: () => entry.value[0],
            );
            final mainWeather = repItem['weather'][0]['main'];
            final dateStr = DateFormat('EEE, MMM d').format(DateTime.parse(entry.key));
            dailyForecast.add({
              'date': dateStr,
              'min': minTemp,
              'max': maxTemp,
              'pop': maxPop,
              'icon': mainWeather,
            });
            if (dailyForecast.length == 5) break;
          }

          return RefreshIndicator(
            onRefresh: () async {
              setState(() {
                weather = getWeather();
              });
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            displayCity,
                            style: Theme.of(context).textTheme.headlineSmall,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Row(
                          children: [
                            Text('°C', style: TextStyle(color: Theme.of(context).colorScheme.primary)),
                            Switch(
                              value: units == 'metric',
                              onChanged: (val) {
                                setState(() {
                                  units = val ? 'metric' : 'imperial';
                                  weather = getWeather();
                                });
                              },
                            ),
                            Text('°F', style: TextStyle(color: Theme.of(context).colorScheme.primary)),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: Card(
                        elevation: 8,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    // ignore: deprecated_member_use
                                    Theme.of(context).colorScheme.primary.withOpacity(0.2),
                                    // ignore: deprecated_member_use
                                    Theme.of(context).colorScheme.surface.withOpacity(0.2),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                children: [
                                  Text(
                                    '$currentTemp°$unitSymbol',
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall
                                        ?.copyWith(fontSize: 32),
                                  ),
                                  const SizedBox(height: 8),
                                  Icon(getWeatherIcon(currentSkyMain), size: 70),
                                  const SizedBox(height: 8),
                                  Text(
                                    currentSkyDesc,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(fontSize: 20, fontWeight: FontWeight.w900),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Feels like $feelsLike°$unitSymbol',
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 16),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Hourly Forecast',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 170,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: hourlyList.length,
                        itemBuilder: (context, index) {
                          final forecastItem = hourlyList[index];
                          final parsedTime = DateTime.parse(forecastItem['dt_txt']);
                          final formattedTime = DateFormat.j().format(parsedTime);
                          final pop = (forecastItem['pop'] * 100).toStringAsFixed(0) + '%';
                          return HourlyForecast(
                            time: formattedTime,
                            temperature: forecastItem['main']['temp'].toStringAsFixed(0) + '°',
                            icon: getWeatherIcon(forecastItem['weather'][0]['main']),
                            pop: pop,
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Daily Forecast',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 170,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: dailyForecast.length,
                        itemBuilder: (context, index) {
                          final item = dailyForecast[index];
                          return DailyForecast(
                            date: item['date'],
                            minTemp: item['min'].toStringAsFixed(0) + '°',
                            maxTemp: item['max'].toStringAsFixed(0) + '°',
                            icon: getWeatherIcon(item['icon']),
                            pop: item['pop'].toStringAsFixed(0) + '%',
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Additional Information',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        AdditionalInfoItem(
                          icon: Icons.water_drop,
                          label: 'Humidity',
                          value: '$currentHumidity%',
                        ),
                        AdditionalInfoItem(
                          icon: Icons.air,
                          label: 'Wind Speed',
                          value: '$currentWind $windUnit',
                        ),
                        AdditionalInfoItem(
                          icon: Icons.arrow_forward,
                          label: 'Wind Dir',
                          value: getWindDirection(windDeg),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        AdditionalInfoItem(
                          icon: Icons.beach_access,
                          label: 'Pressure',
                          value: '$currentPressure hPa',
                        ),
                        AdditionalInfoItem(
                          icon: Icons.umbrella,
                          label: 'Precip',
                          value: '${precip.toStringAsFixed(1)} mm',
                        ),
                        AdditionalInfoItem(
                          icon: Icons.visibility,
                          label: 'Visibility',
                          value: '$currentVisibility $visibilityUnit',
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        AdditionalInfoItem(
                          icon: Icons.wb_sunny,
                          label: 'Sunrise',
                          value: sunriseTime,
                        ),
                        AdditionalInfoItem(
                          icon: Icons.nights_stay,
                          label: 'Sunset',
                          value: sunsetTime,
                        ),
                        const SizedBox(width: 100),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
