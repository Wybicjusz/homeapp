import 'package:flutter/material.dart';
import 'package:homeapp/services/mqtt_service.dart';
import 'package:homeapp/services/weather_service.dart';
import 'package:homeapp/screens/forecast_screen.dart';
import 'package:homeapp/screens/thermostat_screen.dart';

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
            const Text('Dashboard'),
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
                          builder: (context) =>
                              const WeatherForecastScreen()), // Ekran prognozy
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
        child: GridView.count(
          crossAxisCount: 2,
          children: [
            // Kafelek termometru
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ThermostatScreen(),
                  ),
                );
              },
              child: Container(
                margin: const EdgeInsets.all(8.0),
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.blue[100],
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.thermostat, size: 48, color: Colors.blue),
                    SizedBox(height: 8),
                    Text(
                      "Termostat",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                print("Dodaj nowe urządzenie!");
              },
              child: Container(
                margin: const EdgeInsets.all(8.0),
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.green[100],
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.add, size: 48, color: Colors.green),
                    SizedBox(height: 8),
                    Text(
                      "Dodaj nowe",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
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
