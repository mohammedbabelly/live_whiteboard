import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:live_whiteboard/API/teacher_api.dart';
import 'package:live_whiteboard/Helpers/constants.dart';
import 'package:live_whiteboard/Models/my_offset.dart';
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
  List<MyOffset?> globalPoints = <MyOffset>[];
  late String sessionId = '';
  int membersCount = 0;
  bool sessionStarted = false;
  Color selectedColor = Colors.blueAccent;
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
      body: Stack(
        children: [
          Container(
            child: GestureDetector(
              onPanUpdate: (DragUpdateDetails details) {
                if (sessionId.isNotEmpty) {
                  setState(() {
                    globalPoints = List.from(globalPoints)
                      ..add(MyOffset(
                          Constants.screenWidth / details.localPosition.dx,
                          Constants.screenHeight / details.localPosition.dy,
                          selectedColor));
                  });
                }
              },
              onPanEnd: (DragEndDetails details) {
                if (sessionId.isNotEmpty) {
                  globalPoints.add(null);
                  TeacherApi().emitNewOffsets(globalPoints, sessionId);
                }
              },
              child: CustomPaint(
                painter: WhiteBoard(globalPoints),
                size: Size.infinite,
              ),
            ),
          ),
          currentColorWidget()
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.clear),
        onPressed: () {
          globalPoints.clear();
          TeacherApi().emitNewOffsets(globalPoints, sessionId);
        },
      ),
    );
  }

  Future<void> showColorPicker(BuildContext context) async {
    Color pickerColor = selectedColor;
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Pick a pen color'),
            content: ColorPicker(
              pickerColor: pickerColor,
              onColorChanged: (c) => pickerColor = c,
            ),
            actions: <Widget>[
              FlatButton(
                color: Colors.red,
                textColor: Colors.white,
                child: Text('Cancel'),
                onPressed: () {
                  setState(() {
                    Navigator.pop(context);
                  });
                },
              ),
              FlatButton(
                color: Colors.green,
                textColor: Colors.white,
                child: Text('Pick this'),
                onPressed: () {
                  setState(() {
                    selectedColor = pickerColor;
                    Navigator.pop(context);
                  });
                },
              ),
            ],
          );
        });
  }

  Widget currentColorWidget() {
    return Positioned(
        top: 40.0,
        right: 10.0,
        child: InkWell(
          child: CircleAvatar(backgroundColor: selectedColor, radius: 15),
          onTap: () {
            showColorPicker(context);
          },
        ));
  }
}
