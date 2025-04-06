
// websocket_service.dart
import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketService extends ChangeNotifier {
  final String _serverUrl = 'ws://your_server_ip:8080/ws';
  late WebSocketChannel _channel;
  List<String> messages = [];
  String userId = "user123";
  WebSocketService() {
    _connect();
  }

  void _connect() {
    _channel = IOWebSocketChannel.connect(_serverUrl);
    _channel.stream.listen((message) {
      messages.add(message);
      notifyListeners();
    }, onDone: () {
      print("WebSocket Disconnected");
    }, onError: (error) {
      print("WebSocket Error: $error");
    });

    // After connection is established, send the userId again (optional, if needed)
    _channel.stream.listen((_) {
      _sendUserId(userId); // Send userId once connected
      print("WebSocket Connected...");
    });

  }

  // Function to send userId after connection is established
  void _sendUserId(String userId) {
    _channel.sink.add('REGISTER:$userId'); // Send the userId to the server
    print("Sent userId: $userId");
  }

  void sendMessage(String message) {
    _channel.sink.add(message);
  }

  @override
  void dispose() {
    _channel.sink.close();
    super.dispose();
  }
}