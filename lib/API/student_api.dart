import 'package:live_whiteboard/Helpers/constants.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:socket_io_client/socket_io_client.dart';

class StudentApi {
  static late IO.Socket? socket;
  IO.Socket connectToSocket() {
    final socketUrl = '${Constants.baseUrl}';
    socket = IO.io(
      socketUrl,
      OptionBuilder()
          .setTransports(['websocket'])
          .enableAutoConnect()
          .enableReconnection()
          .build(),
    );

    socket!.onConnect((_) {
      print('Student socket connected on $socketUrl');
    });
    socket!.onDisconnect((_) => print('Student socket is disconnect!'));
    socket!.onConnectError(
        (data) => print('Error connecting to Student socket: $data'));
    socket!.onConnectTimeout(
        (data) => 'Timout connecting to Student socket: $data');
    socket!.onConnecting((data) => "Connecting to $socketUrl...");

    return socket!;
  }

  void listenOnSession(String sessionId, Function onChanged) {
    if (socket != null && socket!.connected) {
      socket!.on(sessionId, (data) => onChanged(data));
    }
  }
}
