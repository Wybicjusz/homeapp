import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:homeapp/blocs/weather_bloc.dart';
import 'package:homeapp/blocs/weather_event.dart';
import 'package:homeapp/blocs/weather_state.dart';

class WeatherForecastScreen extends StatelessWidget {
  const WeatherForecastScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Prognoza pogody'),
      ),
      backgroundColor: const Color.fromARGB(255, 200, 200, 190),
      body: BlocBuilder<WeatherBloc, WeatherState>(
        builder: (context, state) {
          if (state is WeatherInitial) {
            return Center(
              child: ElevatedButton(
                onPressed: () {
                  context.read<WeatherBloc>().add(const FetchWeather(
                      51.1079, 17.0385)); // Domyślne współrzędne
                },
                child: const Text('Pobierz pogodę'),
              ),
            );
          } else if (state is WeatherLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is WeatherLoaded) {
            final detailedForecast = state.weatherData['detailed'] ?? [];
            final dailyForecast = state.weatherData['daily'] ?? [];

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
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
          } else if (state is WeatherError) {
            return Center(
              child: Text(state.message),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
