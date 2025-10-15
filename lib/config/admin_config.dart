/// Admin configuration
class AdminConfig {
  // Admin email addresses
  static const List<String> adminEmails = [
    'admin@norden.com',
    'aliabouali2005@gmail.com',
  ];

  /// Check if email is admin
  static bool isAdmin(String? email) {
    if (email == null) return false;
    return adminEmails.contains(email.toLowerCase().trim());
  }
}
