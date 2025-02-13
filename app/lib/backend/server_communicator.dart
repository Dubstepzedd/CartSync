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
  String? username;

  factory ServerCommunicator() {
    return _instance;
  }
  
  void setUsername(String username) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', username);
    this.username = username;
  }

  Future<String?> getUsername() async {
    if (username != null) {
      return username;
    }

    final prefs = await SharedPreferences.getInstance();
    if(prefs.containsKey("username")) {
      username = prefs.getString('username');
      return username;
    }

    return null;
  }

  Future<void> setToken(String authToken, String refreshToken) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('authToken', authToken);
    await prefs.setString('refreshToken', refreshToken);
  }

  Future<void> clearStorage() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  Future<Map<String, dynamic>> sendRequest(
      String route, HTTPMethod method, Map<String, dynamic> body) async {
    
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

      if (response.statusCode == 401) {
        // Send request to refresh the token
        String? refreshToken = prefs.getString('refreshToken');

        if (refreshToken == null) {
          return {
            "statusCode": null,
            "msg": "No refresh token found. Please log in again.",
          };
        }

        final refreshResponse = await http.post(
          Uri.parse('$baseUrl/refresh'), // Replace with your actual URL
          headers: {
            'Authorization': 'Bearer $refreshToken', // Send the refresh token in the header
          },
        );

        if (refreshResponse.statusCode == 201) {
          // Parse the new access token from the response
          final newAccessToken = jsonDecode(refreshResponse.body)['access_token'];
          setToken(newAccessToken, refreshToken);
          return sendRequest(route, method, body); // Retry the original request
        } 
        else {
          //TODO: Handle refresh token failure
          return {
            "statusCode": null,
            "msg": "Failed to refresh token. Please log in again.",
          };
        }
      }
      
      return {...jsonDecode(response.body), "statusCode": response.statusCode};
    }
    catch (e) {
      return {
        "statusCode": null,
        'msg': 'An error occurred while sending the request: $e',
      };
    }
  }
}
