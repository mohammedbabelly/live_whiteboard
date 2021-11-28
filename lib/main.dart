import 'package:flutter/material.dart';
import 'Pages/active_sessions.dart';
import 'Pages/interactive_session.dart';

void main() => runApp(MaterialApp(
      home: ActiveSessionsPage(),
      debugShowCheckedModeBanner: false,
    ));

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TextButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => InteractiveWhiteBoard()));
                },
                child: Text("Teacher"))
          ],
        ),
      ),
    );
  }
}
