import 'package:flutter/material.dart';
import 'package:homeapp/services/weather_service.dart';

class WeatherForecastScreen extends StatefulWidget {
  const WeatherForecastScreen({super.key});

  @override
  _WeatherForecastScreenState createState() => _WeatherForecastScreenState();
}

class _WeatherForecastScreenState extends State<WeatherForecastScreen> {
  late Future<Map<String, List<Map<String, dynamic>>>> _forecastData;

  @override
  void initState() {
    super.initState();
    _forecastData = WeatherService().fetchDetailedAndDailyForecast();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Prognoza pogody'),
      ),
      body: FutureBuilder<Map<String, List<Map<String, dynamic>>>>(
        future: _forecastData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Błąd: ${snapshot.error}'),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('Brak danych pogodowych'),
            );
          }

          final detailedForecast = snapshot.data!['detailed'] ?? [];
          final dailyForecast = snapshot.data!['daily'] ?? [];

          if (detailedForecast.isEmpty && dailyForecast.isEmpty) {
            return const Center(
              child: Text('Brak dostępnych danych prognozy.'),
            );
          }

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Sekcja szczegółowa
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Pogoda dzisiaj',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                detailedForecast.isNotEmpty
                    ? SizedBox(
                        height: 120,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: detailedForecast.length.clamp(0, 12),
                          itemBuilder: (context, index) {
                            final item = detailedForecast[index];
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Column(
                                children: [
                                  Text(
                                    item['time'],
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  Image.network(
                                    'https://openweathermap.org/img/wn/${item['icon']}@2x.png',
                                    width: 50,
                                    height: 50,
                                  ),
                                  const SizedBox(height: 5),
                                  Text('${item['temperature'].round()}°C'),
                                  Text(
                                      'Szansa: ${item['precipitation_chance'] ?? 0}%'),
                                ],
                              ),
                            );
                          },
                        ),
                      )
                    : const Center(
                        child: Text('Brak szczegółowych danych pogodowych.')),
                // Sekcja kilkudniowa
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Pogoda kilkudniowa',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                dailyForecast.isNotEmpty
                    ? ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: dailyForecast.length,
                        itemBuilder: (context, index) {
                          final item = dailyForecast[index];
                          return ListTile(
                            leading: Image.network(
                              'https://openweathermap.org/img/wn/${item['icon']}@2x.png',
                            ),
                            title: Text(
                              item['time'],
                            ),
                            subtitle: Text(
                              'Min: ${item['temperature']['min'].round()}°C, '
                              'Max: ${item['temperature']['max'].round()}°C\n'
                              'Pogoda: ${item['weather']}\n'
                              'Szansa na opady: ${item['precipitation'] ?? 0}%',
                            ),
                          );
                        },
                      )
                    : const Center(
                        child: Text('Brak danych pogodowych na kilka dni.')),
              ],
            ),
          );
        },
      ),
    );
  }
}
