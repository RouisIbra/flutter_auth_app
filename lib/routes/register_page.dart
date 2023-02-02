import 'package:flutter/material.dart';
import 'package:flutter_auth_app/provider/session_provider.dart';
import 'package:flutter_auth_app/validations/form_validations.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // Form's global key
  final _formkey = GlobalKey<FormState>();

  // form input controllers
  final usernameTextInput = TextEditingController();
  final passwordTextInput = TextEditingController();
  final emailTextInput = TextEditingController();

  // form submitting state
  bool isSubmitting = false;

  // register action handler
  _hanldeRegister() {
    // validate form
    if (_formkey.currentState!.validate()) {
      // disable submit button
      setState(() {
        isSubmitting = true;
      });
      // get session provider
      final sessionProvider =
          Provider.of<SessionProvider>(context, listen: false);

      // register user
      sessionProvider
          .register(
        usernameTextInput.text,
        emailTextInput.text,
        passwordTextInput.text,
      )
          // post reigster actions
          .then((result) {
        if (result.success) {
          context.pushReplacement("/login");
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Failed to register. Reason: ${result.message}"),
            ),
          );
        }
      }).onError((error, stackTrace) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to register. Reason: ${error.toString()}"),
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

  _handleGoToLoginPage() {
    context.go("/login");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Register Page"),
      ),
      body: Center(
        // put all form into SingleChildScrollView to avoid RenderFlex overflow
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
                  // Email input field
                  TextFormField(
                    validator: validateEmail,
                    controller: emailTextInput,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(hintText: "Email"),
                  ),
                  const SizedBox(
                    height: 20.0,
                  ),
                  // Password input field
                  TextFormField(
                    validator: validatePassword,
                    controller: passwordTextInput,
                    decoration: const InputDecoration(hintText: "Password"),
                    obscureText: true,
                    autocorrect: false,
                    enableSuggestions: false,
                  ),
                  const SizedBox(
                    height: 20.0,
                  ),
                  // Submit button
                  ElevatedButton(
                    onPressed: isSubmitting ? null : _hanldeRegister,
                    child: const Text("Register"),
                  ),
                  const SizedBox(
                    height: 20.0,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Already have an account?"),
                      TextButton(
                        onPressed: _handleGoToLoginPage,
                        child: const Text("Login"),
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
