import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class MQTTService {
  late MqttServerClient client;

  Future<void> connect() async {
    client = MqttServerClient.withPort(
      '36937337b9c5426d99f926675642f4aa.s1.eu.hivemq.cloud', // Twój URL
      'flutter', // Identyfikator klienta (username)
      8883, // Port TLS MQTT
    );

    client.logging(on: true);
    client.keepAlivePeriod = 20;
    client.secure = true; // Użyj szyfrowania TLS
    client.onConnected = () => print('Connected to HiveMQ!');
    client.onDisconnected = () => print('Disconnected from HiveMQ!');
    client.onSubscribed = (String topic) => print('Subscribed to $topic');

    // Konfiguracja poświadczeń użytkownika
    final connMessage = MqttConnectMessage()
        .withClientIdentifier('flutter') // Identyfikator klienta
        .authenticateAs('flutter', 'Test123123') // Ustaw poświadczenia
        .startClean();
    client.connectionMessage = connMessage;

    try {
      await client.connect();
    } catch (e) {
      print('Connection error: $e');
      client.disconnect();
    }
  }

  void subscribe(String topic) {
    client.subscribe(topic, MqttQos.atLeastOnce);
    print('Subscribed to topic: $topic');
  }

  void publish(String topic, String message) {
    final builder = MqttClientPayloadBuilder();
    builder.addString(message);
    client.publishMessage(topic, MqttQos.atLeastOnce, builder.payload!);
    print('Published message: "$message" to topic: "$topic"');
  }

  void listenToMessages(Function(String topic, String payload) onMessage) {
    client.updates!.listen((List<MqttReceivedMessage<MqttMessage>> messages) {
      final MqttPublishMessage message =
          messages[0].payload as MqttPublishMessage;
      final payload =
          MqttPublishPayload.bytesToStringAsString(message.payload.message);

      final topic = messages[0].topic;
      print('Received message: "$payload" from topic: "$topic"');

      // Wywołanie funkcji przekazanej przez użytkownika
      onMessage(topic, payload);
    });
  }

  void disconnect() {
    client.disconnect();
    print('Disconnected from broker');
  }
}
