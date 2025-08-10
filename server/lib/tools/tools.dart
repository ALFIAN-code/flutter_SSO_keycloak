import 'dart:convert';

import 'package:crypto/crypto.dart';

String generateCodeVerifier() {
  final random = List<int>.generate(
    32,
    (i) => DateTime.now().millisecondsSinceEpoch * i % 256,
  );

  return base64Url.encode(random).replaceAll('=', '');
}

String generateCodeChallenge(String codeVerifier) {
  final bytes = utf8.encode(codeVerifier);
  final digest = sha224.convert(bytes);
  return base64Url.encode(digest.bytes).replaceAll('=', '');
}
