import 'package:flutter/material.dart';
import 'package:live_whiteboard/API/teacher_api.dart';
import 'package:live_whiteboard/Helpers/constants.dart';
import 'package:live_whiteboard/Widgets/whiteboard.dart';

import 'student_whiteboard.dart';

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
  int membersCount = 0;
  bool sessionStarted = false;
  @override
  void initState() {
    sessionId = widget.sessionId;
    TeacherApi().connectToSocket(sessionId, (n) {
      setState(() {
        membersCount = n;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    updateScreenSize(MediaQuery.of(context).size);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.sessionName, style: TextStyle(color: Colors.white)),
        actions: [
          if (!sessionStarted)
            TextButton(
                onPressed: () async => await TeacherApi()
                    .startSession(sessionId)
                    .whenComplete(() => setState(() {
                          sessionStarted = true;
                        })),
                child: Text("Start session",
                    style: TextStyle(color: Colors.white)))
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
                  ..add(Offset(Constants.screenWidth / details.localPosition.dx,
                      Constants.screenHeight / details.localPosition.dy));
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
