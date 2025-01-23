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

  // Pobierz prognozę na 5 dni (co 3 godziny)
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

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      // Szczegółowa prognoza godzinowa
      final List hourlyForecast = data['hourly'];
      final List<Map<String, dynamic>> detailedForecast =
          hourlyForecast.map((item) {
        return {
          'time':
              DateTime.fromMillisecondsSinceEpoch(item['dt'] * 1000).toString(),
          'temperature': item['temp'],
          'humidity': item['humidity'],
          'weather': item['weather'][0]['description'],
          'icon': item['weather'][0]['icon'],
        };
      }).toList();

      // Prognoza dzienna
      final List dailyForecast = data['daily'];
      final List<Map<String, dynamic>> dailyForecastData =
          dailyForecast.map((item) {
        return {
          'time':
              DateTime.fromMillisecondsSinceEpoch(item['dt'] * 1000).toString(),
          'temperature': {
            'day': item['temp']['day'],
            'min': item['temp']['min'],
            'max': item['temp']['max'],
          },
          'humidity': item['humidity'],
          'weather': item['weather'][0]['description'],
          'icon': item['weather'][0]['icon'],
        };
      }).toList();

      return {
        'detailed': detailedForecast,
        'daily': dailyForecastData,
      };
    } else {
      throw Exception('Failed to load forecast data');
    }
  }
}
