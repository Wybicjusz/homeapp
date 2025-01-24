import 'package:flutter/material.dart';
import 'package:homeapp/services/mqtt_service.dart';

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
            lastUpdated = DateTime.now().toString();
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
        title: const Text('Termostat'),
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Temperatura otoczenia
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text(
                      'Temperatura otoczenia:',
                      style: TextStyle(fontSize: 18),
                    ),
                    Text(
                      '$currentTemperature°C',
                      style: const TextStyle(
                          fontSize: 32, fontWeight: FontWeight.bold),
                    ),
                    Text('Ostatnio aktualizowane: $lastUpdated'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Temperatura docelowa
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text(
                      'Temperatura docelowa:',
                      style: TextStyle(fontSize: 18),
                    ),
                    Text(
                      '$targetTemperature°C',
                      style: const TextStyle(
                          fontSize: 32, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () => mqttService.publish(
                          'home/temperatureRequest', 'update'),
                      child: const Text('Zaktualizuj temperaturę'),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () => updateTargetTemperature(1),
                      child: const Text('Podnieś temperaturę +1°C'),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () => updateTargetTemperature(-1),
                      child: const Text('Zmniejsz temperaturę -1°C'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Historia komunikacji
            Expanded(
              child: ListView.builder(
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(messages[index]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
