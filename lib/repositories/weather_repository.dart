import 'package:homeapp/services/weather_service.dart';

class WeatherRepository {
  final WeatherService weatherService;

  WeatherRepository({required this.weatherService});

  // Pobierz prognozę szczegółową i kilkudniową
  Future<Map<String, List<Map<String, dynamic>>>> fetchWeatherForecast() {
    return weatherService.fetchDetailedAndDailyForecast();
  }

  // Pobierz bieżącą pogodę
  Future<Map<String, dynamic>> fetchCurrentWeather() {
    return weatherService.fetchCurrentWeather();
  }
}
