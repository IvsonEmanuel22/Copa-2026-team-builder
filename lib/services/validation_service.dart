class ValidationService {
  static const validDomains = ['gmail.com', 'hotmail.com', 'outlook.com', 'live.com', 'yahoo.com', 'icloud.com', 'proton.me', 'protonmail.com', 'uol.com.br', 'bol.com.br'];

  static bool isValidEmail(String email) {
    final regex = RegExp(r'^[\w\.\-]+@([\w\-]+\.)+[\w]{2,}$');
    if (!regex.hasMatch(email)) return false;
    return validDomains.contains(email.split('@').last.toLowerCase());
  }
}
