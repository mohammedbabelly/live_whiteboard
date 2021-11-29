import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:live_whiteboard/Helpers/constants.dart';
import 'package:live_whiteboard/Models/my_offset.dart';
import 'package:live_whiteboard/Models/sessions.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:socket_io_client/socket_io_client.dart';
import 'package:http/http.dart' as http;

class TeacherApi {
  static late IO.Socket? socket;
  IO.Socket connectToSocket() {
    final socketUrl = '${Constants.baseUrl}';
    socket = IO.io(
      socketUrl,
      OptionBuilder()
          .setTransports(['websocket'])
          .enableAutoConnect()
          .enableReconnection()
          .build(),
    );

    socket!.onConnect((_) {
      print('Teacher socket connected on $socketUrl');
      socket!.emit("IgvJwEmHXunXqbwJrVgko", "From mobile");
    });
    socket!.onDisconnect((_) => print('Teacher socket is disconnect!'));
    socket!.onConnectError(
        (data) => print('Error connecting to teacher socket: $data'));
    socket!.onConnectTimeout(
        (data) => 'Timout connecting to teacher socket: $data');
    socket!.onConnecting((data) => "Connecting to $socketUrl...");

    return socket!;
  }

  void emitNewOffsets(List<Offset?> points, String sessionId) {
    try {
      if (socket != null && socket!.connected) {
        var list = points
            .map((e) => e != null ? MyOffset.fromOffset(e) : true)
            .toList();
        var data = json.encode(list);
        socket!.emit(sessionId, {"id": "1", "typing": "typing"});
        socket!.emitWithAck(sessionId, 'init', ack: (data) {
          print('ack $data');
          if (data != null) {
            print('from server $data');
          } else {
            print("Null");
          }
        });
      }
    } catch (_) {
      print('error emitting: _');
    }
  }

  void listenTest(String sessionId) {
    socket!.on(sessionId, (data) => print('Data from socket: $data'));
  }

  Future<void> startSession(String sessionId) async {
    try {
      var url = Uri.parse('${Constants.baseUrl}/api/session/$sessionId');
      print(url);
      var response = await http.get(url);
      print('Response status: ${response.statusCode}');
      if (response.statusCode == 200) {
        print('session $sessionId started.');
      } else
        throw Exception();
    } catch (_) {
      print("Could not start the session.");
    }
  }

  Future<String> createSession(String sessionName) async {
    try {
      var url = Uri.parse(
          '${Constants.baseUrl}/api/session?sessionName=$sessionName');
      print(url);
      var response = await http.post(url);
      print('Response status: ${response.statusCode}');
      if (response.statusCode == 200) {
        var sessionId = json.decode(response.body)['sessionsId'];
        print('session $sessionName started with id = $sessionId');
        return sessionId;
      } else
        throw Exception();
    } catch (_) {
      print("Could not start the session.");
      return '';
    }
  }
}
