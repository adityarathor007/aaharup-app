class AuthResponse {
  final String phoneNumber;
  final String accessToken;
  final String refreshToken;
  final bool isOnboarded;

  AuthResponse({
    required this.phoneNumber,
    required this.accessToken,
    required this.refreshToken,
    required this.isOnboarded,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      phoneNumber: json['phone_number'] ?? '',
      accessToken: json['access_token'] ?? '',
      refreshToken: json['refresh_token'] ?? '',
      isOnboarded: json['is_onboarded'] ?? false,
    );
  }
}
