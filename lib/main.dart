import 'package:flutter/material.dart';
import 'package:flutter_auth_app/config/router_config.dart';
import 'package:flutter_auth_app/provider/session_provider.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(ChangeNotifierProvider(
    create: (context) => SessionProvider(),
    builder: (context, child) => const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Flutter Auth App',
      routerConfig: routerConfig(),
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
    );
  }
}
