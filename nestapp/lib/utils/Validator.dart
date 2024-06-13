class Validator {
  static bool validateEmail(String email) {
    String emailPattern = r'^[^@]+@[^@]+\.[^@]+';
    RegExp regex = RegExp(emailPattern);
    return regex.hasMatch(email);
  }

  static bool validatePassword(String password) {
    String pattern = r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[.\-_$#@!])[a-zA-Z\d.\-_$#@!]{10,}$';
    RegExp regex = RegExp(pattern);
    return regex.hasMatch(password);
  }
}
