class PhoneUtil {
  static const staffAuthDomain = 'spanr.staff';

  static String normalize(String phone) {
    final digits = phone.replaceAll(RegExp(r'\D'), '');
    if (digits.length == 10) return '91$digits';
    if (digits.length == 12 && digits.startsWith('91')) return digits;
    if (digits.length == 11 && digits.startsWith('0')) return '91${digits.substring(1)}';
    return digits;
  }

  static String toAuthEmail(String phone) {
    return '${normalize(phone)}@$staffAuthDomain';
  }

  static String display(String phone) {
    final n = normalize(phone);
    if (n.length == 12 && n.startsWith('91')) {
      return '+91 ${n.substring(2, 7)} ${n.substring(7)}';
    }
    return phone;
  }
}
