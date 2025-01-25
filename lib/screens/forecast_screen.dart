import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:homeapp/blocs/weather_bloc.dart';
import 'package:homeapp/blocs/weather_state.dart';
import 'package:homeapp/blocs/weather_event.dart';

class WeatherForecastScreen extends StatelessWidget {
  const WeatherForecastScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF6A1B9A),
        title: const Text('Prognoza pogody'),
      ),
      backgroundColor: const Color(0xFFF3E5F5), // Jasnofioletowe tło
      body: BlocBuilder<WeatherBloc, WeatherState>(
        builder: (context, state) {
          if (state is WeatherInitial) {
            // Automatyczne pobranie danych pogodowych
            context
                .read<WeatherBloc>()
                .add(const FetchWeather(51.1079, 17.0385));
            return const Center(child: CircularProgressIndicator());
          } else if (state is WeatherLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is WeatherLoaded) {
            final detailedForecast = state.weatherData['detailed'] ?? [];
            final dailyForecast = state.weatherData['daily'] ?? [];

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Sekcja dzisiejszej pogody
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: const Text(
                      'Pogoda dzisiaj',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF6A1B9A),
                      ),
                    ),
                  ),
                  detailedForecast.isNotEmpty
                      ? SizedBox(
                          height: 140, // Zwiększona wysokość
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: detailedForecast.length.clamp(0, 12),
                            itemBuilder: (context, index) {
                              final item = detailedForecast[index];
                              return Container(
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFD1C4E9),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
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
                                    Text(
                                      '${item['temperature'].round()}°C',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      'Szansa: ${item['precipitation_chance'] ?? 0}%',
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        )
                      : const Center(
                          child: Text('Brak szczegółowych danych pogodowych.')),

                  // Sekcja kilkudniowej prognozy
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: const Text(
                      'Pogoda kilkudniowa',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF6A1B9A),
                      ),
                    ),
                  ),
                  dailyForecast.isNotEmpty
                      ? ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: dailyForecast.length,
                          itemBuilder: (context, index) {
                            final item = dailyForecast[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              child: ListTile(
                                leading: Image.network(
                                  'https://openweathermap.org/img/wn/${item['icon']}@2x.png',
                                ),
                                title: Text(
                                  item['time'],
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text(
                                  'Min: ${item['temperature']['min'].round()}°C, '
                                  'Max: ${item['temperature']['max'].round()}°C\n'
                                  'Pogoda: ${item['weather']}\n'
                                  'Szansa na opady: ${item['precipitation'] ?? 0}%',
                                ),
                              ),
                            );
                          },
                        )
                      : const Center(
                          child: Text('Brak danych pogodowych na kilka dni.')),
                ],
              ),
            );
          } else if (state is WeatherError) {
            return Center(
              child: Text(
                state.message,
                style: const TextStyle(color: Colors.red),
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
