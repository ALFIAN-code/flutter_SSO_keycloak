class AuthSession {
  final String accessToken;
  final String tokenType;
  final DateTime? expiresIn;
  final String? sessionId;

  AuthSession({
    required this.accessToken,
    required this.tokenType,
    required this.sessionId,
    this.expiresIn,
  });

  // Dari JSON ke model
  factory AuthSession.fromJson(Map<String, dynamic> json) {
    return AuthSession(
      sessionId: json['session_id'] ?? '',
      accessToken: json['access_token'] ?? '',
      tokenType: json['token_type'] ?? '',
      expiresIn: json['expires_in'] != null
          ? DateTime.tryParse(json['expires_in'])
          : null,
    );
  }

  handleCallback() {}

  // Dari model ke JSON
  Map<String, dynamic> toJson() {
    return {
      'access_token': accessToken,
      'token_type': tokenType,
      'expires_in': expiresIn?.toIso8601String(),
      'session_id': sessionId,
    };
  }
}
