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
      await mqttService.connect();
      mqttService.subscribe('home/temperature');

      mqttService.listenToMessages((topic, payload) {
        setState(() {
          receivedMessage = payload;
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
        backgroundColor: Colors.deepPurple,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Dashboard', style: TextStyle(color: Colors.white)),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.thermostat, color: Colors.red),
                        Text(temperature,
                            style: const TextStyle(color: Colors.white)),
                      ],
                    ),
                    const SizedBox(width: 10),
                    Row(
                      children: [
                        const Icon(Icons.water_drop, color: Colors.blue),
                        Text(humidity,
                            style: const TextStyle(color: Colors.white)),
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
                        builder: (context) => const WeatherForecastScreen(),
                      ),
                    );
                  },
                  child: const Text(
                    'Prognoza',
                    style: TextStyle(
                      color: Colors.white,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          Container(
            color: Colors.deepPurple[50],
            child: GridView.count(
              crossAxisCount: 2,
              children: [
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
                      color: Colors.purple[100],
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.thermostat, size: 48, color: Colors.purple),
                        SizedBox(height: 8),
                        Text(
                          "Termostat",
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.purple),
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
                      color: Colors.orange[100],
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.add, size: 48, color: Colors.orange),
                        SizedBox(height: 8),
                        Text(
                          "Nowe urządzenie",
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 20,
            right: 20,
            child: FloatingActionButton(
              onPressed: () {
                mqttService.disconnect();
                Navigator.pushReplacementNamed(
                    context, '/login'); // Powrót do ekranu logowania
              },
              backgroundColor: Colors.red,
              child: const Icon(Icons.logout, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    mqttService.disconnect();
    super.dispose();
  }
}
