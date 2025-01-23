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

          final detailedForecast = snapshot.data!['detailed']!;
          final dailyForecast = snapshot.data!['daily']!;

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
                SizedBox(
                  height: 120,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: detailedForecast.length,
                    itemBuilder: (context, index) {
                      final item = detailedForecast[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
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
                            Text('${item['temperature']}°C'),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                // Sekcja kilkudniowa
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Pogoda kilkudniowa',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: dailyForecast.length,
                  itemBuilder: (context, index) {
                    final item = dailyForecast[index];
                    return ListTile(
                      leading: Image.network(
                        'https://openweathermap.org/img/wn/${item['icon']}@2x.png',
                      ),
                      title: Text('${item['time']}'),
                      subtitle: Text(
                          'Min: ${item['min_temp']}°C, Max: ${item['max_temp']}°C\nPogoda: ${item['weather']}\nSzansa na opady: ${item['pop']}%'),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
