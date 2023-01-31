import 'package:flutter/material.dart';
import 'package:flutter_auth_app/provider/session_provider.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  // Logout action handler
  _handleLogout(BuildContext context) {
    // get session provider
    final sessionProvider =
        Provider.of<SessionProvider>(context, listen: false);

    // logout
    sessionProvider.logout().then((success) {
      if (success) {
        context.go("/login");
      } else {
        throw Exception("Failed to logout");
      }
    }).catchError((error) {
      // if an error occurs show it to user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString()),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home Page"),
        actions: [
          // logout action button
          IconButton(
            onPressed: () {
              _handleLogout(context);
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: const Center(
        child: Text("Welcome!"),
      ),
    );
  }
}
