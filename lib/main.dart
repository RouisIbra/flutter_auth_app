import 'package:flutter/material.dart';
import 'package:flutter_auth_app/config/router_config.dart';
import 'package:flutter_auth_app/provider/session_provider.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final sessionProvider = SessionProvider(http.Client());
  try {
    await sessionProvider.refreshSession();
  } catch (error) {
    debugPrint("Failed to refresh session on app start");
    debugPrintStack();
  }

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
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
    );
  }
}
