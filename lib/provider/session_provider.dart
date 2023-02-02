import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_auth_app/config/config.dart';
import 'package:flutter_auth_app/models/login_result.dart';
import 'package:flutter_auth_app/models/register_result.dart';
import 'package:flutter_auth_app/models/user.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class SessionProvider extends ChangeNotifier {
  SessionProvider(this.client, {this.storage = const FlutterSecureStorage()});

  // http client
  final http.Client client;

  // Current User object
  User? _user;

  // HTTP request timeout
  final int responseTimeoutSeconds = 10;

  // HTTP request timout response
  http.Response _timeoutRespone() {
    debugPrint("Request timeout");
    return http.Response("Error: Server not responsing", 500);
  }

  // user getter
  User? get user => _user;

  // Secure flutter storage for session secret key
  final FlutterSecureStorage storage;
  // Session key name (the same as cookie name sent by server)
  final String sessionKeyName = "sessionid";

  /// Get session key from secure storage
  Future<String?> _getSessionKey() async {
    return await storage.read(key: sessionKeyName);
  }

  /// Save new session secret key
  Future<void> _saveSessionKey(String key) async {
    await storage.write(key: sessionKeyName, value: key);
  }

  /// Clear session key from secure storage
  Future<void> _clearSessionKey() async {
    await storage.delete(key: sessionKeyName);
  }

  /// Convert session key to a cookie string to be sent over HTTP
  Future<String?> _sessionKeyToCookie() async {
    final sessionKey = await _getSessionKey();

    if (sessionKey == null) {
      return null;
    }

    final cookie = Cookie(sessionKeyName, sessionKey);
    return cookie.toString();
  }

  /// Get method that automatically adds session key as cookie to the request
  Future<http.Response> _get(String path) async {
    final cookie = await _sessionKeyToCookie();
    return client.get(
      Uri.parse("$apiUrl$path"),
      headers: {
        HttpHeaders.acceptHeader: "application/json",
        if (cookie != null) HttpHeaders.cookieHeader: cookie
      },
    ).timeout(
      // set server response timeout
      Duration(seconds: responseTimeoutSeconds),
      onTimeout: _timeoutRespone,
    );
  }

  /// Post method that automatically adds session key as cookie to the request
  Future<http.Response> _post(String path, {Map<String, dynamic>? body}) async {
    final cookie = await _sessionKeyToCookie();
    return client
        .post(
          Uri.parse("$apiUrl$path"),
          headers: {
            HttpHeaders.acceptHeader: "application/json",
            HttpHeaders.contentTypeHeader: "application/json",
            if (cookie != null) HttpHeaders.cookieHeader: cookie
          },
          body: body != null ? jsonEncode(body) : null,
        )
        // set server response timeout
        .timeout(
          const Duration(seconds: 10),
          onTimeout: _timeoutRespone,
        );
  }

  /// Get user session info
  Future<User?> _getUserSession() async {
    final response = await _get("/user");

    if (response.statusCode == 200) {
      final user = User.fromJson(jsonDecode(response.body));
      return user;
    } else {
      return null;
    }
  }

  /// Refresh user session
  Future<void> refreshSession() async {
    _user = await _getUserSession();
    notifyListeners();
  }

  /// Save user session from response
  ///
  /// If the session's secret key was sent with the response on Set-Cookie header
  /// it will save in the secure storage
  Future<void> _saveSession(http.Response response) async {
    if (response.statusCode == 200) {
      final String? rawCookie = response.headers[HttpHeaders.setCookieHeader];
      if (rawCookie != null) {
        final cookie = Cookie.fromSetCookieValue(rawCookie);
        if (cookie.name == sessionKeyName) {
          await _saveSessionKey(cookie.value);
        }
      }
    } else {
      throw Exception("You cannot save session from invalid response");
    }
  }

  // Login promise
  Future<LoginResult> login(String username, String password) async {
    final response = await _post(
      "/login",
      body: <String, dynamic>{
        "username": username,
        "password": password,
      },
    );

    if (response.statusCode == 200) {
      await _saveSession(response);
      await refreshSession();
      return LoginResult(success: true);
    } else if (response.statusCode == 500) {
      return LoginResult(success: false, message: response.body.toString());
    } else {
      return LoginResult(
        success: false,
        message: "Incorrect Username or Password",
      );
    }
  }

  // Register promise
  Future<RegisterResult> register(
    String username,
    String email,
    String password,
  ) async {
    final response = await _post(
      "/register",
      body: <String, dynamic>{
        "username": username,
        "email": email,
        "password": password
      },
    );

    if (response.statusCode == 200) {
      return const RegisterResult(success: true);
    } else {
      Map<String, dynamic> responseBody = jsonDecode(response.body);
      String message = responseBody["message"];
      return RegisterResult(success: false, message: message);
    }
  }

  // Logout promise
  Future<bool> logout() async {
    final response = await _post("/logout");

    if (response.statusCode == 200) {
      await _clearSessionKey();
      // set user to null
      _user = null;
      return true;
    } else {
      return false;
    }
  }
}
