class AppUser {
  final String uid;
  final String email;
  final String name;

  AppUser({
    required this.uid,
    required this.email,
    required this.name,
  });

  Map<String, dynamic> tojson() {
    return {
      'id': uid,
      'email': email,
      'name': name,
    };
  }

  factory AppUser.fromJson(Map<String, dynamic> jsonUser) {
    return AppUser(
      uid: jsonUser['id'],
      email: jsonUser['email'],
      name: jsonUser['name'],
    );
  }
}