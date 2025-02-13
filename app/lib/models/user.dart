
class User {
  final String email;
  final List<String> friends;

  User({
    required this.email,
    required this.friends,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      email: json["username"], // Mapping "username" from Flask JSON to "email"
      friends: (json["friends"]).cast<String>(), // Ensure it's always a List<String>
    );
  }

  bool isFriend(String username) {
    return friends.contains(username);
  }
}
