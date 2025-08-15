import 'dart:convert';
import 'dart:ui' show FontWeight, ImageFilter;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:myapp/additonal_info_item.dart';
import 'package:http/http.dart' as http;

import 'package:myapp/hourly_forcast_items.dart';
import 'package:myapp/secrets.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  double temp = 0;
  @override
  void initState() {
    super.initState();
    getCurrentWeather();
  }

  Future<Map<String, dynamic>> getCurrentWeather() async {
    try {
      String cityName = "London";
      final res = await http.get(
        Uri.parse(
          'https://api.openweathermap.org/data/2.5/forecast?q=$cityName,uk&APPID=$openweatherApi',
        ),
      );
      final data = jsonDecode(res.body);
      if (data['cod'] != '200') {
        throw 'An unexpected error occured';
      }
      return data;
    } catch (e) {
      throw e.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Weather App",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: FutureBuilder(
        future: getCurrentWeather(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator.adaptive());
          }
          if (snapshot.hasError) {
            return const Center(child: Text("Something went wrong"));
          }
          final data = snapshot.data!;
          final currenttemperature = data['list'][0]['main']['temp'];
          final currentSky = data['list'][0]['weather'][0]['main'];
          final currentpressure = data['list'][0]['main']['pressure'];
          final currenthumidity = data['list'][0]['main']['humidity'];
          final currentwind = data['list'][0]['wind']['speed'];

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Main card
                SizedBox(
                  width: double.infinity,
                  child: Card(
                    elevation: 10,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16.0),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              Text(
                                '$currenttemperature k',
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 8),
                              Icon(
                                currentSky == "Clouds" || currentSky == 'Rain'
                                    ? Icons.cloud
                                    : Icons.sunny,
                                size: 70,
                              ),
                              SizedBox(height: 8),
                              Text(
                                currentSky,
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Section title
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Weather Forecast",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 20),

                // Weather forecast small card
                //SingleChildScrollView(
                //   scrollDirection: Axis.horizontal,
                //   child: Row(
                //     children: [
                //      for (var i = 0; i < 5; i++)
                //       HourlyForcast(
                //         time: data['list'][i + 1]['dt_txt'],
                //         temperature: data['list'][i + 1]['main']['temp'].toString(),
                //         icon: data['list'][i + 1]['weather'][0]['main'] == 'Clouds' ||
                //                 data['list'][i + 1]['weather'][0]['main'] == 'Rain'
                //             ? Icons.cloud
                //             : Icons.sunny,
                //       ),
                //     ],
                //   ),
                // ),
SizedBox(
  height: 150,
  child: ListView.builder(
    scrollDirection: Axis.horizontal,
    itemCount: 5,
    itemBuilder: (context, index) {
      final forecastItem = data['list'][index + 1];

// Convert to DateTime
final parsedTime = DateTime.parse(forecastItem['dt_txt']);

// Format to HH:mm
final formattedTime = DateFormat.j().format(parsedTime);

// Pass the formatted time string to your widget
return HourlyForcast(
  time: formattedTime, // ✅ This is now just hour:minute
  temperature: forecastItem['main']['temp'].toString(),
  icon: forecastItem['weather'][0]['main'] == 'Clouds' ||
        forecastItem['weather'][0]['main'] == 'Rain'
      ? Icons.cloud
      : Icons.sunny,
);

    },
  ),
),

                const SizedBox(height: 20),

                const Text(
                  "Additional Information",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    AdditonalInfoItem(
                      icon: Icons.water_drop,
                      label: "Humidity",
                      value: currenthumidity.toString(),
                    ),
                    AdditonalInfoItem(
                      icon: Icons.air,
                      label: "Wind Speed",
                      value: currentwind.toString(),
                    ),
                    AdditonalInfoItem(
                      icon: Icons.beach_access,
                      label: "Pressure",
                      value: currentpressure.toString(),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
