import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'Pages/active_sessions.dart';

void main() => runApp(MaterialApp(
      home: ActiveSessionsPage(),
      debugShowCheckedModeBanner: false,
      // builder: BotToastInit(),
      navigatorObservers: [BotToastNavigatorObserver()],
    ));
