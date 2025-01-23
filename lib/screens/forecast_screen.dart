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
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Szczegółowa prognoza (co 1 godzina):',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: detailedForecast.length,
                  itemBuilder: (context, index) {
                    final item = detailedForecast[index];
                    return ListTile(
                      leading: Image.network(
                        'https://openweathermap.org/img/wn/${item['icon']}@2x.png',
                      ),
                      title: Text('${item['time']}'),
                      subtitle: Text(
                          'Temperatura: ${item['temperature']}°C\nWilgotność: ${item['humidity']}%\nPogoda: ${item['weather']}'),
                    );
                  },
                ),
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Prognoza na kilka dni:',
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
                          'Min: ${item['min_temp']}°C, Max: ${item['max_temp']}°C\nPogoda: ${item['weather']}'),
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
