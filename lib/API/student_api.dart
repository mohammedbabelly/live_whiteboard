import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:live_whiteboard/Helpers/constants.dart';
import 'package:live_whiteboard/Models/my_offset.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:socket_io_client/socket_io_client.dart';
import 'package:http/http.dart' as http;

class StudentApi {
  static late IO.Socket? socket;
  IO.Socket connectToSocket(
      String sessionId, Function onChanged, Function whenSomeoneJoin) {
    final socketUrl = '${Constants.baseUrl}';
    socket = IO.io(
      socketUrl,
      OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .enableReconnection()
          .build(),
    );
    socket!.connect();
    socket!.onConnect((_) {
      print('Student socket connected on $socketUrl');
      listenOnSession(sessionId, onChanged);
      socket!.emit("join$sessionId");
      socket!.on(sessionId + "Count", (data) {
        print("someone joined: $data");
      });
    });
    socket!.onDisconnect((_) {
      print('Student socket is disconnect!');
    });
    socket!.onConnectError(
        (data) => print('Error connecting to Student socket: $data'));
    socket!.onConnectTimeout(
        (data) => 'Timout connecting to Student socket: $data');
    socket!.onConnecting((data) => "Connecting to $socketUrl...");

    return socket!;
  }

  void exitSocket(String sessionId) {
    socket!.emit("exit$sessionId");
  }

  Future<void> getSession(String sessionId) async {
    try {
      var url = Uri.parse('${Constants.baseUrl}/api/session/$sessionId');
      print(url);
      var response = await http.get(url);
      print('Response status: ${response.statusCode}');
      if (Constants.successStatusCodes.contains(response.statusCode)) {
        // print('session $sessionId started.');
      } else
        throw Exception();
    } catch (_) {}
  }

  void listenOnSession(String sessionId, Function onChanged) {
    if (socket != null && socket!.connected) {
      socket!.on(sessionId, (data) {
        try {
          print('Data from socket: $data');
          List decodedData = json.decode(data['data']);
          List<MyOffset?> newPointes = decodedData.map((e) {
            if (e != null) if (e != null) return MyOffset.fromJson(e);
          }).toList();
          onChanged(newPointes);
        } catch (_) {
          print('error $_');
        }
      });
    }
  }
}
