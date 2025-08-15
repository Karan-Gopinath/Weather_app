import 'dart:convert';
import 'dart:ui' show FontWeight, ImageFilter;
import 'package:flutter/material.dart';
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

  Future getCurrentWeather() async {
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
     return data ; 
     // temp = data['list'][0]['main']['temp'];
    
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
        builder: (context, asyncSnapshot) {
          
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
                            children:  [
                              Text(
                                '$temp k',
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 8),
                              Icon(Icons.cloud, size: 70),
                              SizedBox(height: 8),
                              Text(
                                'Rain',
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
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      const HourlyForcast(
                        time: '00:00',
                        temperature: '300°F',
                        icon: Icons.sunny,
                      ),
                      const HourlyForcast(
                        time: '03:00',
                        temperature: '300°F',
                        icon: Icons.cloud,
                      ),
                      const HourlyForcast(
                        time: '06:00',
                        temperature: '300°F',
                        icon: Icons.sunny,
                      ),
                      const HourlyForcast(
                        time: ' 09:00',
                        temperature: '300°F',
                        icon: Icons.cloud,
                      ),
                      HourlyForcast(
                        time: '12:00',
                        temperature: ' 300°F',
                        icon: Icons.sunny_snowing,
                      ),
                    ],
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
                      value: "80%",
                    ),
                    AdditonalInfoItem(
                      icon: Icons.air,
                      label: "Wind Speed",
                      value: "10 mph",
                    ),
                    AdditonalInfoItem(
                      icon: Icons.beach_access,
                      label: "Pressure",
                      value: "1013 hPa",
                    ),
                  ],
                ),
              ],
            ),
          );
        }
      ),
    );
  }
}
