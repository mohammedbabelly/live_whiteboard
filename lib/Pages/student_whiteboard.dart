import 'package:flutter/material.dart';
import 'package:live_whiteboard/API/student_api.dart';
import 'package:live_whiteboard/Helpers/constants.dart';
import 'package:live_whiteboard/Widgets/whiteboard.dart';

class StudentWhiteBoard extends StatefulWidget {
  final String sessionId;
  StudentWhiteBoard(this.sessionId);
  @override
  _StudentWhiteBoardState createState() => _StudentWhiteBoardState();
}

class _StudentWhiteBoardState extends State<StudentWhiteBoard> {
  List<Offset?> _points = <Offset>[];
  late String sessionId = '';
  @override
  void initState() {
    sessionId = widget.sessionId;

    StudentApi().connectToSocket(sessionId, (newPoints) {
      setState(() {
        _points = newPoints;
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    StudentApi.socket!.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    updateScreenSize(MediaQuery.of(context).size);
    return Scaffold(
      appBar:
          AppBar(title: Text(sessionId, style: TextStyle(color: Colors.white))),
      body: Container(
        child: CustomPaint(
          painter: WhiteBoard(_points),
          size: Size.infinite,
        ),
      ),
    );
  }
}

void updateScreenSize(Size size) {
  Constants.screenHeight = size.height;
  Constants.screenWidth = size.width;
}
