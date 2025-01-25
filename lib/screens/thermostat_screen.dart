import 'package:flutter/material.dart';
import 'package:homeapp/services/mqtt_service.dart';
import 'package:intl/intl.dart'; // Dodano do formatowania daty i czasu

class ThermostatScreen extends StatefulWidget {
  const ThermostatScreen({super.key});

  @override
  _ThermostatScreenState createState() => _ThermostatScreenState();
}

class _ThermostatScreenState extends State<ThermostatScreen> {
  final MQTTService mqttService = MQTTService();
  String currentTemperature = 'Ładowanie...';
  String targetTemperature = '22'; // Domyślna temperatura docelowa
  String lastUpdated = 'Ładowanie...';
  List<String> messages = [];

  @override
  void initState() {
    super.initState();
    connectToMQTT();
  }

  Future<void> connectToMQTT() async {
    try {
      await mqttService.connect();
      if (mqttService.isClientConnected()) {
        mqttService.subscribe('home/temperature');
        mqttService.listenToMessages((topic, message) {
          setState(() {
            currentTemperature = message;
            lastUpdated = DateFormat('HH:mm dd-MM-yyyy').format(DateTime.now());
            messages.add('[$topic]: $message');
          });
        });
      }
    } catch (e) {
      print('Error connecting to MQTT: $e');
    }
  }

  void updateTargetTemperature(int change) {
    final updatedTemperature = int.parse(targetTemperature) + change;
    setState(() {
      targetTemperature = updatedTemperature.toString();
      messages.add('[home/targetTemperature]: $targetTemperature');
    });
    mqttService.publish('home/targetTemperature', targetTemperature);
  }

  @override
  void dispose() {
    mqttService.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Termostat',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF6A1B9A),
      ),
      backgroundColor: const Color(0xFFF5E6F9),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Temperatura otoczenia
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const Text(
                        'Temperatura otoczenia:',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF6A1B9A),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '$currentTemperature°C',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Ostatnio aktualizowane: $lastUpdated',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Temperatura docelowa
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const Text(
                        'Temperatura docelowa:',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF6A1B9A),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '$targetTemperature°C',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => mqttService.publish(
                          'home/temperatureRequest',
                          'update',
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF9C27B0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 20,
                          ),
                        ),
                        child: const Text(
                          'Zaktualizuj temperaturę',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () => updateTargetTemperature(1),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF9C27B0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 20,
                          ),
                        ),
                        child: const Text(
                          'Podnieś temperaturę +1°C',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () => updateTargetTemperature(-1),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF9C27B0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 20,
                          ),
                        ),
                        child: const Text(
                          'Zmniejsz temperaturę -1°C',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Historia komunikacji
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Historia komunikacji:',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF6A1B9A),
                        ),
                      ),
                      const SizedBox(height: 8),
                      ListView.builder(
                        shrinkWrap: true,
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Text(
                              messages[index],
                              style: const TextStyle(color: Colors.black),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
