class AuthResponse {
  final String accessToken;
  final String refreshToken;
  final bool isOnboarded;

  AuthResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.isOnboarded,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      accessToken: json['access_token'] ?? '',
      refreshToken: json['refresh_token'] ?? '',
      isOnboarded: json['is_onboarded'] ?? false,
    );
  }
}
