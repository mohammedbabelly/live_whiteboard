import 'package:flutter/material.dart';
import 'package:live_whiteboard/API/sessions_api.dart';
import 'package:live_whiteboard/Models/sessions.dart';

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
              trailing: TextButton(onPressed: () {}, child: Text("Join")),
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
            onPressed: () {
              // setState(() {});
            },
          ),
        ]);
  }
}
