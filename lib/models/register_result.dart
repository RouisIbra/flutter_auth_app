/// RegisterResult returned from register promise in session provider
class RegisterResult {
  const RegisterResult({required this.success, this.message});
  final bool success;
  final String? message;
}
