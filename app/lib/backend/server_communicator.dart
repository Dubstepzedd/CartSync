import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

enum HTTPMethod {
  get,
  post,
  put,
  delete,
  patch,
}

// Singleton class for communicating with the server
class ServerCommunicator {
  ServerCommunicator._privateConstructor();
  static const String baseUrl = 'http://127.0.0.1:5000';
  static final ServerCommunicator _instance = ServerCommunicator._privateConstructor();

  factory ServerCommunicator() {
    return _instance;
  }

  Future<void> setToken(String authToken, String refreshToken) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('authToken', authToken);
    await prefs.setString('refreshToken', refreshToken);
  }

  Future<Map<String, dynamic>> sendRequest(
      String route, HTTPMethod method, Map<String, dynamic> body) async {
    
    // TODO Create logic for the refresh token
    // GET and DELETE can't have a body according to the HTTP standard
    var params = "";
    if ((method == HTTPMethod.get || method == HTTPMethod.delete) && body.isNotEmpty) {
       params = "/${body.keys.map((key) => '${body[key]}').join('/')}";
    }

    final prefs = await SharedPreferences.getInstance();
    String? authToken;
    if(prefs.containsKey("authToken")) {
      authToken = prefs.getString('authToken');
    }

    print(authToken);
   
    final url = Uri.parse('$baseUrl$route$params');

    // Set up headers
    final headers = {
      'Content-Type': 'application/json',
      if (authToken != null) 'Authorization': 'Bearer $authToken',
    };

    // Perform the HTTP request
    try {
      late http.Response response;

      switch (method) {
        case HTTPMethod.get:
          response = await http.get(url, headers: headers);
          break;
        case HTTPMethod.post:
          response = await http.post(url, headers: headers, body: jsonEncode(body));
          break;
        case HTTPMethod.put:
          response = await http.put(url, headers: headers, body: jsonEncode(body));
          break;
        case HTTPMethod.delete:
          response = await http.delete(url, headers: headers);
          break;
        case HTTPMethod.patch:
          response = await http.patch(url, headers: headers, body: jsonEncode(body));
          break;
      }

      return jsonDecode(response.body);
    }
    catch (e) {
      return {
        "success": false,
        'msg': 'An error occurred while sending the request: $e',
      };
    }
  }
}
