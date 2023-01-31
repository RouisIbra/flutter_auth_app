import 'package:flutter_auth_app/provider/session_provider.dart';
import 'package:flutter_auth_app/routes/home_page.dart';
import 'package:flutter_auth_app/routes/login_page.dart';
import 'package:flutter_auth_app/routes/register_page.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

// Router configuration
final routerConfig = GoRouter(
  initialLocation: "/",
  routes: [
    GoRoute(
      path: "/",
      builder: (context, state) => const HomePage(),
      redirect: (context, state) {
        // get session provider
        final sessionProvider =
            Provider.of<SessionProvider>(context, listen: false);

        // if user is not logged in redirect to login page
        if (sessionProvider.user == null) {
          return "/login";
        } else {
          return null;
        }
      },
    ),
    GoRoute(
      path: "/login",
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: "/register",
      builder: (context, state) => const RegisterPage(),
    )
  ],
);
