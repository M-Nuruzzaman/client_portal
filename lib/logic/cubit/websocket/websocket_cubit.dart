// websocket_cubit.dart
import 'package:client_portal/core/utils/api_config.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketCubit extends Cubit<List<String>> {
  final String _serverUrl = ApiConfig.baseUrlWebsocketService;
  late WebSocketChannel _channel;
  String userId = "user333";
  WebSocketCubit() : super([]) {
    _connect();
  }

  void _connect() {
    _channel = IOWebSocketChannel.connect(_serverUrl);
    _channel.stream.listen((message) {
      emit([...state, message]);
    }, onDone: () {
      print("WebSocket Disconnected");
    }, onError: (error) {
      print("WebSocket Error: $error");
    });

    sendMessage("REGISTER:$userId");
    print("WebSocket Connected...");
  }


  void sendMessage(String message) {
    _channel.sink.add(message);
  }

  @override
  Future<void> close() {
    _channel.sink.close();
    return super.close();
  }
}