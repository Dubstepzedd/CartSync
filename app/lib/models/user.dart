
class User {
  final String email;
  final List<String> following;

  User({
    required this.email,
    required this.following,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      email: json["username"], // Mapping "username" from Flask JSON to "email"
      following: (json["following"]).cast<String>(), // Ensure it's always a List<String>
    );
  }

  bool isFollowing(String username) {
    return following.contains(username);
  }
}
