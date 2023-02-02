import 'package:flutter/material.dart';
import 'package:flutter_auth_app/provider/session_provider.dart';
import 'package:flutter_auth_app/validations/form_validations.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  /// Form's global key
  final _formkey = GlobalKey<FormState>();

  /// Username input controller
  final usernameTextInput = TextEditingController();

  /// Password input controller
  final passwordTextInput = TextEditingController();

  /// Form submitting state
  bool isSubmitting = false;

  /// Login handler
  _hanldeLogin() {
    /// validate form
    if (_formkey.currentState!.validate()) {
      // disable submit button
      setState(() {
        isSubmitting = true;
      });

      final sessionProvider =
          Provider.of<SessionProvider>(context, listen: false);

      // login
      sessionProvider
          .login(usernameTextInput.text, passwordTextInput.text)
          .then((result) {
        if (result.success) {
          // if login is successful replace to home page
          context.pushReplacement("/");
        } else {
          debugPrint("Login failed");

          if (result.message != null) {
            // Show login failed message as snackbar
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(result.message!),
              ),
            );
          }
        }
      }).onError((error, stackTrace) {
        // Show error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to login. Reason: ${error.toString()}"),
          ),
        );
        debugPrintStack(stackTrace: stackTrace);
      }).whenComplete(
        () => setState(() {
          // re-enable submit button
          isSubmitting = false;
        }),
      );
    }
  }

  _handleGoToRegisterPage() {
    context.go("/register");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Login Page"),
      ),
      body: Center(
        // put the whole form in a SingleChildScrollView to avoid RenderFlex overflow
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(30.0),
            child: Form(
              key: _formkey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Username input field
                  TextFormField(
                    validator: validateUserName,
                    controller: usernameTextInput,
                    decoration: const InputDecoration(hintText: "Username"),
                  ),
                  const SizedBox(
                    height: 20.0,
                  ),
                  // Password input field
                  TextFormField(
                    validator: validatePassword,
                    controller: passwordTextInput,
                    decoration: const InputDecoration(hintText: "Password"),
                    // Set text to obscure to hide password
                    obscureText: true,
                    // disable autocorrect and suggestions
                    autocorrect: false,
                    enableSuggestions: false,
                  ),
                  const SizedBox(
                    height: 20.0,
                  ),
                  // Login button
                  ElevatedButton(
                    onPressed: isSubmitting ? null : _hanldeLogin,
                    child: isSubmitting
                        ? const CircularProgressIndicator(
                            strokeWidth: 3.0,
                          )
                        : const Text("Login"),
                  ),
                  const SizedBox(
                    height: 20.0,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Don't have an account?"),
                      TextButton(
                        onPressed: _handleGoToRegisterPage,
                        child: const Text("Register"),
                      )
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
