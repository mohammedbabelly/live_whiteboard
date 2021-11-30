import 'package:flutter/material.dart';
import 'package:live_whiteboard/API/teacher_api.dart';
import 'package:live_whiteboard/Widgets/whiteboard.dart';

class InteractiveWhiteBoard extends StatefulWidget {
  final String sessionId;
  final String sessionName;
  InteractiveWhiteBoard({required this.sessionId, required this.sessionName});
  @override
  _InteractiveWhiteBoardState createState() => _InteractiveWhiteBoardState();
}

class _InteractiveWhiteBoardState extends State<InteractiveWhiteBoard> {
  List<Offset?> globalPoints = <Offset>[];
  List<Offset?> localPoints = <Offset>[];
  late String sessionId = '';
  @override
  void initState() {
    sessionId = widget.sessionId;
    TeacherApi().connectToSocket();
    super.initState();
  }

  @override
  void dispose() {
    TeacherApi.socket!.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.sessionName, style: TextStyle(color: Colors.white)),
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
                localPoints = List.from(localPoints)
                  ..add(Offset(
                      details.localPosition.dx, details.localPosition.dy));
                globalPoints = List.from(globalPoints)
                  ..add(Offset(screenSize.width / details.localPosition.dx,
                      screenSize.height / details.localPosition.dy));
              });
            }
          },
          onPanEnd: (DragEndDetails details) {
            if (sessionId.isNotEmpty) {
              localPoints.add(null);
              globalPoints.add(null);
              TeacherApi().emitNewOffsets(globalPoints, sessionId);
            }
          },
          child: CustomPaint(
            painter: WhiteBoard(localPoints),
            size: Size.infinite,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.clear),
        onPressed: () {
          localPoints.clear();
          globalPoints.clear();
          TeacherApi().emitNewOffsets(globalPoints, sessionId);
        },
      ),
    );
  }
}
