import 'dart:io';
import 'dart:convert';

import 'package:flutter_auth_app/config/config.dart';
import 'package:flutter_auth_app/models/user.dart';
import 'package:flutter_auth_app/provider/session_provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'session_provider_test.mocks.dart';

@GenerateMocks([http.Client, FlutterSecureStorage])
void main() {
  group("Session Provider", () {
    test("Get null user session when user is not logged in", () async {
      // ensureInitialized is required in async test
      TestWidgetsFlutterBinding.ensureInitialized();

      // Mocked client
      final client = MockClient();

      // Mocked Flutter Secure Storage
      final storage = MockFlutterSecureStorage();

      // Session provider
      final sessionProvider = SessionProvider(client, storage: storage);

      // Mock /user api request
      when(
        client.get(
          Uri.parse("$apiUrl/user"),
          headers: {
            HttpHeaders.acceptHeader: "application/json",
          },
        ),
      ).thenAnswer(
        (_) async => http.Response(
          '{ "message": "You are not logged in" }',
          401,
          headers: {
            HttpHeaders.contentTypeHeader: "application/json",
          },
        ),
      );

      // Mock secure storage read
      when(
        storage.read(key: sessionProvider.sessionKeyName),
      ).thenAnswer((_) async => null);

      await sessionProvider.refreshSession();

      // User session must return null
      expect(sessionProvider.user, isNull);
    });

    test("Get user session when user is logged in", () async {
      TestWidgetsFlutterBinding.ensureInitialized();
      const fakeSessionKey = "secretcookievalue";
      final client = MockClient();
      final storage = MockFlutterSecureStorage();
      final sessionProvider = SessionProvider(client, storage: storage);
      when(
        client.get(
          Uri.parse("$apiUrl/user"),
          headers: {
            HttpHeaders.acceptHeader: "application/json",
            HttpHeaders.cookieHeader:
                "${sessionProvider.sessionKeyName}=$fakeSessionKey; HttpOnly"
          },
        ),
      ).thenAnswer(
        (_) async => http.Response(
          '{"id": 1,"username": "test1", "email": "test1@example.com"}',
          200,
          headers: {
            HttpHeaders.contentTypeHeader: "application/json",
          },
        ),
      );

      when(
        storage.read(key: sessionProvider.sessionKeyName),
      ).thenAnswer((_) async => fakeSessionKey);

      await sessionProvider.refreshSession();

      // User session must return an instance of User class
      expect(sessionProvider.user, isA<User>());
    });

    test("Login success test", () async {
      TestWidgetsFlutterBinding.ensureInitialized();
      const fakeSessionKey = "secretcookievalue";
      final client = MockClient();
      final storage = MockFlutterSecureStorage();
      final sessionProvider = SessionProvider(client, storage: storage);
      bool loginRequestRan = false;

      // fake login request
      when(
        client.post(
          Uri.parse("$apiUrl/login"),
          headers: {
            HttpHeaders.acceptHeader: "application/json",
            HttpHeaders.contentTypeHeader: "application/json",
          },
          body: jsonEncode(
            <String, String>{"username": "test", "password": "test"},
          ),
        ),
      ).thenAnswer((_) async {
        loginRequestRan = true;
        return http.Response(
          '{"message": "Successfully logged in"}',
          200,
          headers: {
            HttpHeaders.contentTypeHeader: "application/json",
            HttpHeaders.setCookieHeader:
                "${sessionProvider.sessionKeyName}=$fakeSessionKey; Path=/; HttpOnly"
          },
        );
      });

      // Mock /user GET request
      when(
        client.get(
          Uri.parse("$apiUrl/user"),
          headers: {
            HttpHeaders.acceptHeader: "application/json",
            HttpHeaders.cookieHeader:
                "${sessionProvider.sessionKeyName}=$fakeSessionKey; HttpOnly"
          },
        ),
      ).thenAnswer(
        (_) async => http.Response(
          '{"id": 1,"username": "test", "email": "test@example.com"}',
          200,
          headers: {
            HttpHeaders.contentTypeHeader: "application/json",
          },
        ),
      );

      // mock secure storage write
      when(
        storage.write(
          key: sessionProvider.sessionKeyName,
          value: fakeSessionKey,
        ),
      ).thenAnswer((_) async {
        return;
      });

      // fake secure storage read
      when(
        storage.read(key: sessionProvider.sessionKeyName),
      ).thenAnswer((_) async => loginRequestRan ? fakeSessionKey : null);

      await sessionProvider.login("test", "test");

      expect(sessionProvider.user, isA<User>());
    });

    test("Login failure test", () async {
      TestWidgetsFlutterBinding.ensureInitialized();
      final client = MockClient();
      final storage = MockFlutterSecureStorage();
      final sessionProvider = SessionProvider(client, storage: storage);
      // fake login request
      when(
        client.post(
          Uri.parse("$apiUrl/login"),
          headers: {
            HttpHeaders.acceptHeader: "application/json",
            HttpHeaders.contentTypeHeader: "application/json",
          },
          body: jsonEncode(
            <String, String>{"username": "test", "password": "wrongpassword"},
          ),
        ),
      ).thenAnswer((_) async {
        return http.Response(
          '{"message": "Incorrect passsword"}',
          403,
          headers: {
            HttpHeaders.contentTypeHeader: "application/json",
          },
        );
      });

      // Mock /user GET request
      when(
        client.get(
          Uri.parse("$apiUrl/user"),
          headers: {
            HttpHeaders.acceptHeader: "application/json",
          },
        ),
      ).thenAnswer(
        (_) async => http.Response(
          '{"message": "You are not logged in"}',
          401,
        ),
      );

      // fake secure storage read
      when(
        storage.read(key: sessionProvider.sessionKeyName),
      ).thenAnswer((_) async => null);

      await sessionProvider.login("test", "test");

      expect(sessionProvider.user, isNull);
    });

    test("Register test", () async {
      TestWidgetsFlutterBinding.ensureInitialized();
      final client = MockClient();
      final storage = MockFlutterSecureStorage();
      final sessionProvider = SessionProvider(client, storage: storage);

      // fake register request
      when(
        client.post(
          Uri.parse("$apiUrl/register"),
          headers: {
            HttpHeaders.acceptHeader: "application/json",
            HttpHeaders.contentTypeHeader: "application/json",
          },
          body: jsonEncode(
            <String, String>{
              "username": "test",
              "email": "test@example.com",
              "password": "testpass"
            },
          ),
        ),
      ).thenAnswer((_) async {
        return http.Response(
          '{"message": "Registration successfull"}',
          200,
          headers: {
            HttpHeaders.contentTypeHeader: "application/json",
          },
        );
      });

      // Mock /user GET request
      when(
        client.get(
          Uri.parse("$apiUrl/user"),
          headers: {
            HttpHeaders.acceptHeader: "application/json",
          },
        ),
      ).thenAnswer(
        (_) async => http.Response(
          '{"message": "You are not logged in"}',
          401,
        ),
      );

      // fake secure storage read
      when(
        storage.read(key: sessionProvider.sessionKeyName),
      ).thenAnswer((_) async => null);

      final registerResult = await sessionProvider.register(
        "test",
        "test@example.com",
        "testpass",
      );

      expect(registerResult.success, true);
    });
  });
}
