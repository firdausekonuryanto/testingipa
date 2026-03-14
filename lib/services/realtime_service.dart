import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:internusa_group/services/tokenmanager_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class RealtimeService {
  WebSocketChannel? _channel;
  String? _socketId;

  bool _subscribed = false;
  bool _connecting = false;
  bool get isConnected => _channel != null && _subscribed;

  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: "http://${dotenv.env['IP_PORT_SERVER']!}",
      headers: {
        "Accept": "application/json",
        "Content-Type": "application/json",
      },
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  Future<void> connect({
    required String employeeId,
    required Function(Map<String, dynamic>) onNotification,
  }) async {
    if (_channel != null || _connecting) {
      return;
    }

    _connecting = true;

    try {
      final url =
          '${dotenv.env['WS_SCHEME']!}://${dotenv.env['WS_HOST']!}/app/${dotenv.env['WS_KEY']!}?protocol=7&client=flutter&version=1.0&flash=false';

      _channel = WebSocketChannel.connect(Uri.parse(url));

      _channel!.stream.listen(
        (message) async {
          final decoded = jsonDecode(message);
          final event = decoded['event'];

          if (event == 'pusher:connection_established') {
            final data = jsonDecode(decoded['data']);
            _socketId = data['socket_id'];

            await _subscribe(employeeId);

            return;
          }

          if (event == 'pusher_internal:subscription_succeeded') {
            _subscribed = true;
            return;
          }

          if (event == 'notification.sent') {
            final payload = decoded['data'] is String
                ? jsonDecode(decoded['data'])
                : decoded['data'];

            onNotification(payload);

            return;
          }

          if (event == 'pusher:ping') {
            _send({'event': 'pusher:pong'});
            return;
          }

          if (event == 'pusher:error') {
            return;
          }
        },
        onError: (e) {
          _reset();
        },
        onDone: () {
          debugPrint("🔌 WS disconnected");
          _reset();
        },
      );
    } catch (e) {
      _reset();
    } finally {
      _connecting = false;
    }
  }

  Future<void> _subscribe(String employeeId) async {
    if (_socketId == null) {
      return;
    }

    final channelName = "private-user.$employeeId";

    try {
      final authData = await _getAuth(channelName);

      final payload = {
        "event": "pusher:subscribe",
        "data": {
          "channel": channelName,
          "auth": authData["auth"],
        }
      };

      _send(payload);
    } catch (e) {
      debugPrint("❌ Subscribe failed: $e");
    }
  }

  Future<Map<String, dynamic>> _getAuth(String channelName) async {
    try {
      final token = await Tokenmanager.getToken();

      if (token == null) {
        throw Exception("Token is null — user not authenticated");
      }

      final response = await _dio.post(
        "/api/broadcasting/auth",
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
            "Accept": "application/json",
          },
        ),
        data: {
          "socket_id": _socketId,
          "channel_name": channelName,
        },
      );

      return Map<String, dynamic>.from(response.data);
    } catch (e) {
      debugPrint("❌ Auth error: $e");
      rethrow;
    }
  }

  void _send(Map<String, dynamic> data) {
    _channel?.sink.add(jsonEncode(data));
  }

  void disconnect() {
    debugPrint("🔌 Realtime disconnecting...");
    _channel?.sink.close();
    _reset();
  }

  void _reset() {
    _channel = null;
    _socketId = null;
    _subscribed = false;
    _connecting = false;
  }
}
