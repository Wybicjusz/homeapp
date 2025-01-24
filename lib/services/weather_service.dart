import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherService {
  final String apiKey = '4f7abb17f90fd6265b06891ebc6f8801';
  final double defaultLat = 51.1079;
  final double defaultLon = 17.0385;

  // Pobierz bieżącą pogodę
  Future<Map<String, dynamic>> fetchCurrentWeather(
      {double? lat, double? lon}) async {
    final double latitude = lat ?? defaultLat;
    final double longitude = lon ?? defaultLon;

    final url = Uri.parse(
        'https://api.openweathermap.org/data/2.5/weather?lat=$latitude&lon=$longitude&appid=$apiKey&units=metric');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return {
        'temperature': data['main']['temp'],
        'humidity': data['main']['humidity'],
      };
    } else {
      throw Exception('Failed to load current weather data');
    }
  }

  // Pobierz prognozę szczegółową i kilkudniową
  Future<Map<String, List<Map<String, dynamic>>>>
      fetchDetailedAndDailyForecast({
    double? lat,
    double? lon,
  }) async {
    final double latitude = lat ?? defaultLat;
    final double longitude = lon ?? defaultLon;

    final url = Uri.parse(
        'https://api.openweathermap.org/data/3.0/onecall?lat=$latitude&lon=$longitude&appid=$apiKey&units=metric&exclude=minutely');

    final response = await http.get(url);

    print('Request URL: $url');
    print('Response status code: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      // Szczegółowa prognoza godzinowa
      final List hourlyForecast = data['hourly'] ?? [];
      final List<Map<String, dynamic>> detailedForecast =
          hourlyForecast.map((item) {
        final time = DateTime.fromMillisecondsSinceEpoch(item['dt'] * 1000);
        return {
          'time':
              '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}', // Format HH:mm
          'temperature': item['temp'].round(), // Zaokrąglenie temperatury
          'humidity': item['humidity'],
          'precipitation_chance':
              ((item['pop'] ?? 0) * 100).round(), // Szansa na opady w %
          'weather': item['weather'][0]['description'],
          'icon': item['weather'][0]['icon'],
        };
      }).toList();

      print('Detailed forecast data: $detailedForecast');

      // Prognoza dzienna
      final List dailyForecast = data['daily'];
      final List<Map<String, dynamic>> dailyForecastData =
          dailyForecast.map((item) {
        return {
          'time': DateTime.fromMillisecondsSinceEpoch(item['dt'] * 1000)
              .toLocal()
              .toString()
              .split(' ')[0], // Data w formacie YYYY-MM-DD
          'temperature': {
            'min': item['temp']['min'].round(),
            'max': item['temp']['max'].round(),
          },
          'precipitation':
              ((item['pop'] ?? 0) * 100).round(), // Szansa na opady w %
          'weather': item['weather'][0]['description'],
          'icon': item['weather'][0]['icon'],
        };
      }).toList();

      print('Daily forecast data: $dailyForecastData');

      return {
        'detailed': detailedForecast,
        'daily': dailyForecastData,
      };
    } else {
      print('API Error: ${response.statusCode}, Body: ${response.body}');
      throw Exception('Failed to load forecast data');
    }
  }
}
