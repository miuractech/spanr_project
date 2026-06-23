String formatAuthError(Object error) {
  final message = error.toString();

  if (message.contains('host lookup') ||
      message.contains('SocketException') ||
      message.contains('Failed host lookup') ||
      message.contains('Network is unreachable') ||
      message.contains('Connection refused')) {
    return 'Cannot reach server. Check your internet connection and try again.';
  }

  if (message.contains('Invalid login credentials') ||
      message.contains('Invalid mobile number or password')) {
    return 'Invalid mobile number or password';
  }

  return message
      .replaceFirst('AuthRetryableFetchException(message: ', '')
      .replaceFirst('AuthApiException(message: ', '')
      .replaceFirst('Exception: ', '')
      .replaceAll(RegExp(r'\), statusCode:.*$'), '')
      .replaceAll(RegExp(r'\)$'), '')
      .trim();
}
