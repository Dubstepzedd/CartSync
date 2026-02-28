import 'package:app/models/friend_request.dart';

class User {
  final String email;
  final List<String> friends;
  final List<int> carts;
  final List<String> sentRequests;
  final List<String> receivedRequests;

  User({
    required this.email,
    required this.friends,
    required this.carts,
    required this.sentRequests,
    required this.receivedRequests,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      email: json["username"],
      friends: List<String>.from(json["friends"]),
      carts: List<int>.from(json["carts"]),
      sentRequests: List<String>.from(json["sent_friend_requests"]),
      receivedRequests: List<String>.from(json["received_friend_requests"]),
    );
  }

  FriendshipStatus getFriendshipStatus(String targetUsername) {
    if (friends.contains(targetUsername)) {
      return FriendshipStatus.active;
    }
    if (sentRequests.contains(targetUsername)) {
      return FriendshipStatus.requestSent;
    }
    if (receivedRequests.contains(targetUsername)) {
      return FriendshipStatus.requestReceived;
    }
    return FriendshipStatus.none;
  }
}
