import 'dart:convert';

class Session {
  Session({
    required this.sessionName,
    required this.sessionId,
  });

  final String sessionName;
  final String sessionId;

  factory Session.fromRawJson(String str) => Session.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Session.fromJson(Map<String, dynamic> json) => Session(
        sessionName: json["sessionName"],
        sessionId: json["sessionId"],
      );

  Map<String, dynamic> toJson() => {
        "sessionName": sessionName,
        "sessionId": sessionId,
      };
}
