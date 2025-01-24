import 'package:flutter/material.dart';
import 'package:homeapp/services/mqtt_service.dart';
import 'package:homeapp/services/weather_service.dart';
import 'package:homeapp/screens/forecast_screen.dart';
import 'package:homeapp/screens/login_screen.dart'; // Dodano import ekranu logowania

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final mqttService = MQTTService();
  String receivedMessage = 'Brak wiadomości';
  String temperature = 'Ładowanie...';
  String humidity = 'Ładowanie...';

  @override
  void initState() {
    super.initState();
    connectToMQTT();
    fetchWeatherData();
  }

  Future<void> connectToMQTT() async {
    try {
      // Połączenie z brokerem HiveMQ
      await mqttService.connect();
      mqttService.subscribe('home/temperature');

      // Nasłuchiwanie wiadomości
      mqttService.listenToMessages((topic, payload) {
        setState(() {
          receivedMessage = payload; // Aktualizacja wiadomości w stanie
        });
      });
    } catch (e) {
      print('Błąd podczas łączenia z MQTT: $e');
    }
  }

  Future<void> fetchWeatherData() async {
    try {
      final weatherService = WeatherService();
      final data = await weatherService.fetchCurrentWeather();
      setState(() {
        temperature = '${data['temperature']}°C';
        humidity = '${data['humidity']}%';
      });
    } catch (e) {
      setState(() {
        temperature = 'Błąd';
        humidity = 'Błąd';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Dashboard'), // Napis "Dashboard" po lewej stronie
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.thermostat, color: Colors.red),
                        Text(temperature),
                      ],
                    ),
                    const SizedBox(width: 10),
                    Row(
                      children: [
                        const Icon(Icons.water_drop, color: Colors.blue),
                        Text(humidity),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const WeatherForecastScreen()),
                    );
                  },
                  child: Text(
                    'Prognoza',
                    style: TextStyle(
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Container(
        color: const Color.fromARGB(255, 224, 216, 216),
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Konsola:',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    receivedMessage,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      mqttService.publish('home/temperature', '25');
                    },
                    child: const Text('Wyślij temperaturę: 25°C'),
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: 20,
              right: 20,
              child: ElevatedButton(
                onPressed: () {
                  mqttService.disconnect(); // Odłączenie MQTT
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => LoginScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red, // Kolor przycisku
                ),
                child: const Text(
                  'Wyloguj',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    mqttService.disconnect();
    super.dispose();
  }
}
