import 'package:flutter/material.dart';
import 'package:live_whiteboard/API/sessions_api.dart';
import 'package:live_whiteboard/API/student_api.dart';
import 'package:live_whiteboard/API/teacher_api.dart';
import 'package:live_whiteboard/Models/sessions.dart';
import 'package:live_whiteboard/Pages/student_whiteboard.dart';

import 'interactive_session.dart';

class ActiveSessionsPage extends StatefulWidget {
  @override
  _ActiveSessionsPageState createState() => _ActiveSessionsPageState();
}

class _ActiveSessionsPageState extends State<ActiveSessionsPage> {
  List<Session>? data;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: appBarWidget(),
        body: data != null
            ? _buildBody()
            : FutureBuilder<List<Session>>(
                future: SessionsApi.getActiveSessions(),
                builder: (context, _snapshot) {
                  if (_snapshot.data != null) data = _snapshot.data!;
                  return _snapshot.connectionState == ConnectionState.waiting
                      ? Center(child: CircularProgressIndicator())
                      : _snapshot.data!.isNotEmpty
                          ? _snapshot.hasError
                              ? Center(
                                  child: InkWell(
                                      onTap: () {
                                        setState(() {});
                                      },
                                      child: Text("Something went wrong!!")),
                                )
                              : _buildBody()
                          : Center(
                              child: Text(
                                  "No Active Sessions tab + to create one"));
                },
              ));
  }

  _buildBody() {
    return RefreshIndicator(
        child: ListView.builder(
          itemCount: data!.length,
          itemBuilder: (context, index) {
            var session = data![index];
            return ListTile(
              title: Text(session.sessionName),
              subtitle: Text(session.sessionId),
              trailing: TextButton(
                  onPressed: () async {
                    await StudentApi().getSession(session.sessionId);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) =>
                                StudentWhiteBoard(session.sessionId)));
                  },
                  child: Text("Join")),
            );
          },
        ),
        onRefresh: () {
          setState(() {
            data = null;
          });
          return Future.value(true);
        });
  }

  appBarWidget() {
    return AppBar(
        title: FittedBox(
          fit: BoxFit.fitWidth,
          child: Text('Active Sessions'),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => showCreateSessionDialog(context),
          ),
        ]);
  }

  Future<void> showCreateSessionDialog(BuildContext context) async {
    TextEditingController sessionNameController = TextEditingController();
    TextEditingController passwordController = TextEditingController();
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Session Details'),
            content: TextField(
              onChanged: (value) {
                setState(() {});
              },
              controller: sessionNameController,
              decoration: InputDecoration(hintText: "Session Name"),
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
                child: Text('Create'),
                onPressed: () async {
                  if (sessionNameController.text.isNotEmpty)
                    await TeacherApi()
                        .createSession(sessionNameController.text)
                        .then((sessionId) {
                      Navigator.pop(context);
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => InteractiveWhiteBoard(
                                    sessionId: sessionId,
                                    sessionName: sessionNameController.text,
                                  )));
                    });
                },
              ),
            ],
          );
        });
  }
}
