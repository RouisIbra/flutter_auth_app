import 'dart:io';

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
      TestWidgetsFlutterBinding.ensureInitialized();
      final client = MockClient();
      final storage = MockFlutterSecureStorage();
      final sessionProvider = SessionProvider(client, storage: storage);
      when(
        client.get(
          Uri.parse("$apiUrl/user"),
          headers: {
            HttpHeaders.acceptHeader: "application/json",
          },
        ),
      ).thenAnswer(
        (_) async => http.Response(
          "You are not logged in",
          401,
        ),
      );

      when(
        storage.read(key: sessionProvider.sessionKeyName),
      ).thenAnswer((_) async => null);

      await sessionProvider.refreshSession();

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
        ),
      );

      when(
        storage.read(key: sessionProvider.sessionKeyName),
      ).thenAnswer((_) async => fakeSessionKey);

      await sessionProvider.refreshSession();

      expect(sessionProvider.user, isA<User>());
    });
  });
}
