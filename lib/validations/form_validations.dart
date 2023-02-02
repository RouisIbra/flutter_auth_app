/// Username validator
String? validateUserName(String? value) {
  if (value == null || value == "") {
    return "Username is required";
  }
  if (value.length < 4 || value.length > 25) {
    return "Username length must be between 4 and 25 characters";
  }

  return null;
}

/// Email validator
String? validateEmail(String? value) {
  if (value == null || value == "") {
    return "Email is required";
  }
  if (value.length > 254) {
    return "Email must not exceed 254 characters long";
  }

  // validate email using regulat expression
  if (!RegExp(
    r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
  ).hasMatch(value)) {
    return "Invalid email format";
  }

  return null;
}

/// Password validator
String? validatePassword(String? value) {
  if (value == null || value == "") {
    return "Password is required";
  }
  if (value.length < 6 || value.length > 40) {
    return "Password length must be between 6 and 40 characters";
  }

  return null;
}
