import 'package:flutter/cupertino.dart';
import 'package:flutter_auth_app/provider/session_provider.dart';
import 'package:flutter_auth_app/routes/home_page.dart';
import 'package:flutter_auth_app/routes/login_page.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

Function routerConfig = () => GoRouter(
      initialLocation: "/",
      routes: [
        GoRoute(
          path: "/",
          builder: (context, state) => const HomePage(),
        ),
        GoRoute(
          path: "/login",
          builder: (context, state) => const LoginPage(),
        ),
      ],
      redirect: (context, state) {
        final sessionProvider =
            Provider.of<SessionProvider>(context, listen: false);

        if (sessionProvider.user == null) {
          return "/login";
        } else {
          return null;
        }
      },
    );
