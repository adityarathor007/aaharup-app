class UserProfile {
  final int id;
  final String? username;
  final String? phoneNumber;
  final String? email;

  UserProfile({required this.id, this.username, this.phoneNumber, this.email});

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'],
      username: json['username'],
      phoneNumber: json['phone_number'],
      email: json['email'],
    );
  }
}
