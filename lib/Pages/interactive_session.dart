import 'package:flutter/material.dart';
import 'package:live_whiteboard/API/teacher_api.dart';
import 'package:live_whiteboard/Widgets/whiteboard.dart';

class InteractiveWhiteBoard extends StatefulWidget {
  @override
  _InteractiveWhiteBoardState createState() => _InteractiveWhiteBoardState();
}

class _InteractiveWhiteBoardState extends State<InteractiveWhiteBoard> {
  List<Offset?> _points = <Offset>[];
  late String sessionId = '';
  @override
  void initState() {
    sessionId = "IgvJwEmHXunXqbwJrVgko";
    TeacherApi().connectToSocket();
    TeacherApi().listenTest(sessionId);
    super.initState();
  }

  @override
  void dispose() {
    TeacherApi.socket!.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          TextButton(
              onPressed: () async => await TeacherApi().startSession(sessionId),
              child:
                  Text("Start session", style: TextStyle(color: Colors.white)))
        ],
      ),
      body: Container(
        child: GestureDetector(
          onPanUpdate: (DragUpdateDetails details) {
            if (sessionId.isNotEmpty) {
              setState(() {
                // var newOffset = MyOffset(
                //     details.localPosition.dx, details.localPosition.dy);
                // var encoded = newOffset.toRawJson();
                // MyOffset decoded = MyOffset.fromRawJson(encoded);
                _points = List.from(_points)
                  ..add(Offset(
                      details.localPosition.dx, details.localPosition.dy));
              });
            }
          },
          onPanEnd: (DragEndDetails details) {
            if (sessionId.isNotEmpty) {
              _points.add(null);
              TeacherApi().emitNewOffsets(_points, sessionId);
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
          TeacherApi().emitNewOffsets(_points, sessionId);
        },
      ),
    );
  }

  // void connect() async {
  //   final socketUrl = '${Constants.baseUrl}';
  //   print('trying to connect to $socketUrl');

  //   socket = IO.io('https://share--screen.herokuapp.com', <String, dynamic>{
  //     'transports': [
  //       'websocket',
  //       // 'flashsocket',
  //       // 'htmlfile',
  //       // 'xhr-polling',
  //       // 'jsonp-polling',
  //       // 'polling'
  //     ],
  //     'autoConnect': false,
  //   });
  //   socket.connect();
  //   socket.onConnect((_) {
  //     print('connect');
  //     socket.emit('msg', 'test');
  //   });
  //   socket.on('event', (data) => print(data));
  //   socket.onDisconnect((_) => print('disconnect'));
  //   socket.on('fromServer', (_) => print(_));
  //   socket.onConnectError((data) => print('error connecting: $data'));
  //   socket.onConnectTimeout((data) => 'connecting timeout: $data');
  //   socket.onConnecting((data) => "connecting...");
  //   socket.onConnect((_) {
  //     print('connected to $socketUrl');
  //     setState(() {});
  //     // socket.emit('msg', 'test');
  //   });
  //   socket.on(sessionId, (data) => print('data from socket: $data'));
  //   socket.onDisconnect((_) => print('disconnected from $socketUrl'));
  //   // socket.on('fromServer', (_) => print(_));
  // }

}
