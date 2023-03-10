import 'package:flutter/material.dart';
import 'package:flutter_auth_app/config/router_config.dart';
import 'package:flutter_auth_app/provider/session_provider.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final sessionProvider = SessionProvider(http.Client());
  await sessionProvider.refreshSession();

  runApp(
    ChangeNotifierProvider(
      create: (context) => sessionProvider,
      builder: (context, child) => const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Flutter Auth App',
      routerConfig: routerConfig,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark().copyWith(
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue[900],
          ),
        ),
      ),
      themeMode: ThemeMode.dark,
    );
  }
}
