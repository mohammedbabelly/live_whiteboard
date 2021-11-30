import 'dart:convert';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:live_whiteboard/Helpers/constants.dart';
import 'package:live_whiteboard/Models/my_offset.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:socket_io_client/socket_io_client.dart';
import 'package:http/http.dart' as http;

class TeacherApi {
  static late IO.Socket? socket;
  IO.Socket connectToSocket(String sessionId, Function whenSomeoneJoin) {
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
      print('Teacher socket connected on $socketUrl');
      socket!.on(sessionId + "Count", (data) {
        print("someone joined: $data");
      });
    });
    socket!.onDisconnect((_) {
      print('Teacher socket is disconnect!');
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
        socket!.emit(sessionId, json.encode(list));
      }
    } catch (_) {
      print('error emitting: $_');
    }
  }

  Future<void> startSession(String sessionId) async {
    try {
      //BotToast.showLoading(clickClose: true);
      var url = Uri.parse('${Constants.baseUrl}/api/session/$sessionId');
      print(url);
      var response = await http.get(url);
      print('Response status: ${response.statusCode}');
      if (response.statusCode == 200) {
        print('session $sessionId started.');
        //BotToast.closeAllLoading();
      } else
        throw Exception();
    } catch (_) {
      //BotToast.closeAllLoading();
      //BotToast.showText(text: "Could not start the session!");
    }
  }

  Future<String> createSession(String sessionName) async {
    try {
      //BotToast.showLoading(clickClose: true);
      var url = Uri.parse(
          '${Constants.baseUrl}/api/session?sessionName=$sessionName');
      print(url);
      var response = await http.post(url);
      print('Response status: ${response.statusCode}');
      if (Constants.successStatusCodes.contains(response.statusCode)) {
        var sessionId = json.decode(response.body)['sessionsId'];
        print('session $sessionName started with id = $sessionId');
        //BotToast.closeAllLoading();
        return sessionId;
      } else
        throw Exception();
    } catch (_) {
      //BotToast.closeAllLoading();
      //BotToast.showText(text: "Could not create the session!");
      return '';
    }
  }
}
