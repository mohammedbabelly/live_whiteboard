import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:live_whiteboard/Helpers/constants.dart';
import 'package:live_whiteboard/Models/my_offset.dart';
import 'package:live_whiteboard/Widgets/whiteboard.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:socket_io_client/socket_io_client.dart';
import 'package:http/http.dart' as http;

class InteractiveWhiteBoard extends StatefulWidget {
  @override
  _InteractiveWhiteBoardState createState() => _InteractiveWhiteBoardState();
}

class _InteractiveWhiteBoardState extends State<InteractiveWhiteBoard> {
  List<Offset?> _points = <Offset>[];
  late IO.Socket socket;
  late String sessionId;
  @override
  void initState() {
    sessionId = "-H_5MpO5zSsmjij006SUY";
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          TextButton(
              onPressed: () async => await startSession(),
              child:
                  Text("Start session", style: TextStyle(color: Colors.white))),
          Padding(padding: EdgeInsets.symmetric(horizontal: 15)),
          TextButton(
              onPressed: () => connect(),
              child: Text("Connect to socket",
                  style: TextStyle(color: Colors.white))),
        ],
      ),
      body: Container(
        child: GestureDetector(
          onPanUpdate: (DragUpdateDetails details) {
            if (socket.connected) {
              setState(() {
                var newOffset = MyOffset(
                    details.localPosition.dx, details.localPosition.dy);
                var encoded = newOffset.toRawJson();
                MyOffset decoded = MyOffset.fromRawJson(encoded);
                _points = List.from(_points)..add(decoded.toOffset());
              });
            }
          },
          onPanEnd: (DragEndDetails details) {
            if (socket.connected) {
              _points.add(null);
              emit();
            }
          },
          child: CustomPaint(
            painter: WhiteBoard(_points),
            size: Size.infinite,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.clear),
        onPressed: () {
          _points.clear();
          emit();
        },
      ),
    );
  }

  Future<void> startSession() async {
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

  void connect() async {
    final socketUrl = '${Constants.baseUrl}';
    print('trying to connect to $socketUrl');

    socket = IO.io('https://share--screen.herokuapp.com', <String, dynamic>{
      'transports': [
        'websocket',
        // 'flashsocket',
        // 'htmlfile',
        // 'xhr-polling',
        // 'jsonp-polling',
        // 'polling'
      ],
      'autoConnect': false,
    });
    socket.connect();
    socket.onConnect((_) {
      print('connect');
      socket.emit('msg', 'test');
    });
    socket.on('event', (data) => print(data));
    socket.onDisconnect((_) => print('disconnect'));
    socket.on('fromServer', (_) => print(_));
    socket.onConnectError((data) => print('error connecting: $data'));
    socket.onConnectTimeout((data) => 'connecting timeout: $data');
    socket.onConnecting((data) => "connecting...");
    socket.onConnect((_) {
      print('connected to $socketUrl');
      setState(() {});
      // socket.emit('msg', 'test');
    });
    socket.on(sessionId, (data) => print('data from socket: $data'));
    socket.onDisconnect((_) => print('disconnected from $socketUrl'));
    // socket.on('fromServer', (_) => print(_));
  }

  void emit() {
    final data = json
        .encode(_points.map((e) => MyOffset(e!.dx, e.dy).toJson()).toList());
    socket.emit(sessionId, data);
  }
}
