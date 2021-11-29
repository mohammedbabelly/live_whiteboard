import 'dart:convert';
import 'package:live_whiteboard/Helpers/constants.dart';
import 'package:live_whiteboard/Models/sessions.dart';
import 'package:http/http.dart' as http;

class SessionsApi {
  static Future<List<Session>> getActiveSessions() async {
    try {
      var url = Uri.parse('${Constants.baseUrl}/api/session');
      print(url);
      var response = await http.get(url);
      print('Response status: ${response.statusCode}');
      if (Constants.successStatusCodes.contains(response.statusCode)) {
        var result = <Session>[];
        for (var session in json.decode(response.body)) {
          result.add(Session.fromJson(session));
        }
        return result;
      } else
        throw Exception();
    } catch (_) {
      print("Could not get the sessions.");
      return [];
    }
  }
}
