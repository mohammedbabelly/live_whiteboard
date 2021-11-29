import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:live_whiteboard/Helpers/constants.dart';
import 'package:live_whiteboard/Models/my_offset.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:socket_io_client/socket_io_client.dart';
import 'package:http/http.dart' as http;

class TeacherApi {
  static late IO.Socket? socket;
  IO.Socket connectToSocket() {
    final socketUrl = '${Constants.baseUrl}';
    socket = null;
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
      print("socketId = ${socket!.id}");
    });
    socket!.onDisconnect((_) {
      print('Teacher socket is disconnect!');
      socket!.dispose();
    });
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
        var list = points.map((e) {
          if (e != null) return MyOffset.fromOffset(e);
        }).toList();
        var data = json.encode(list);
        socket!.emit(sessionId, data);
      }
    } catch (_) {
      print('error emitting: _');
    }
  }

  void listenTest(String sessionId, Function onChanged) {
    socket!.on(sessionId, (data) {
      try {
        print('Data from socket: $data');
        List decodedData = json.decode(data['data']);
        List<Offset?> newPointes = decodedData.map((e) {
          if (e != null) return MyOffset.fromJson(e).toOffset();
        }).toList();
        return newPointes;
      } catch (_) {
        print('error emitting: _');
      }
      onChanged(data);
    });
  }

  //join$sessionID
  //exit$sessionID
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
