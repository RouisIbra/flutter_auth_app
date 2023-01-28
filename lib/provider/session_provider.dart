import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_auth_app/config/config.dart';
import 'package:flutter_auth_app/models/register_result.dart';
import 'package:flutter_auth_app/models/user.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class SessionProvider extends ChangeNotifier {
  User? _user;

  User? get user => _user;

  final storage = const FlutterSecureStorage();
  final String sessionKeyName = "sessionid";

  Future<String?> _getSessionKey() async {
    return await storage.read(key: sessionKeyName);
  }

  Future<void> _saveSessionKey(String key) async {
    await storage.write(key: sessionKeyName, value: key);
  }

  Future<void> _clearSessionKey() async {
    await storage.delete(key: sessionKeyName);
  }

  Future<String> _sessionKeyToCookie() async {
    final sessionKey = await _getSessionKey();
    final cookie = Cookie(sessionKeyName, sessionKey ?? "");
    return cookie.toString();
  }

  Future<http.Response> _get(String path) async {
    final cookie = await _sessionKeyToCookie();
    return http.get(Uri.parse("$apiUrl$path"), headers: {
      HttpHeaders.acceptHeader: "application/json",
      HttpHeaders.cookieHeader: cookie
    });
  }

  Future<http.Response> _post(String path, {Map<String, dynamic>? body}) async {
    final cookie = await _sessionKeyToCookie();
    return http.post(
      Uri.parse("$apiUrl$path"),
      headers: {
        HttpHeaders.acceptHeader: "application/json",
        HttpHeaders.contentTypeHeader: "application/json",
        HttpHeaders.cookieHeader: cookie
      },
      body: body != null ? jsonEncode(body) : null,
    );
  }

  Future<User?> _getUserSession() async {
    final response = await _get("/user");

    if (response.statusCode == 200) {
      final user = User.fromJson(jsonDecode(response.body));
      return user;
    } else {
      return null;
    }
  }

  Future<void> refreshSession() async {
    _user = await _getUserSession();
    notifyListeners();
  }

  Future<void> _saveSession(http.Response response) async {
    if (response.statusCode == 200) {
      final String? rawCookie = response.headers[HttpHeaders.setCookieHeader];
      if (rawCookie != null) {
        final cookie = Cookie.fromSetCookieValue(rawCookie);
        if (cookie.name == "sessionid") {
          await _saveSessionKey(cookie.value);
        }
      }
    } else {
      throw Exception("You cannot save session from invalid response");
    }
  }

  Future<bool> login(String username, String password) async {
    final response = await _post("/login", body: <String, dynamic>{
      "username": username,
      "password": password,
    });

    if (response.statusCode == 200) {
      await _saveSession(response);
      await refreshSession();
      return true;
    } else {
      return false;
    }
  }

  Future<RegisterResult> register(
      String username, String email, String password) async {
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

  Future<bool> logout() async {
    final response = await _post("/logout");

    if (response.statusCode == 200) {
      await _saveSession(response);
      await refreshSession();
      return true;
    } else {
      return false;
    }
  }
}
