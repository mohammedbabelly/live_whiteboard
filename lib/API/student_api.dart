import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:live_whiteboard/Helpers/constants.dart';
import 'package:live_whiteboard/Models/my_offset.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:socket_io_client/socket_io_client.dart';

class StudentApi {
  static late IO.Socket? socket;
  IO.Socket connectToSocket(String sessionId, Function onChanged) {
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
      print('Student socket connected on $socketUrl');
      listenOnSession(sessionId, onChanged);
    });
    socket!.onDisconnect((_) => print('Student socket is disconnect!'));
    socket!.onConnectError(
        (data) => print('Error connecting to Student socket: $data'));
    socket!.onConnectTimeout(
        (data) => 'Timout connecting to Student socket: $data');
    socket!.onConnecting((data) => "Connecting to $socketUrl...");

    return socket!;
  }

  void listenOnSession(String sessionId, Function onChanged) {
    if (socket != null && socket!.connected) {
      socket!.on(sessionId, (data) {
        try {
          print('Data from socket: $data');
          List decodedData = json.decode(data['data']);
          var myRenderBox = MyRenderBox();
          List<Offset?> newPointes = decodedData.map((e) {
            if (e != null)
            // return MyOffset.fromJson(e).toLocalOffset(myRenderBox);
            if (e != null) return MyOffset.fromJson(e).toOffset();
          }).toList();
          onChanged(newPointes);
        } catch (_) {
          print('error emitting: _');
        }
        // onChanged(data);
      });
    }
  }
}
