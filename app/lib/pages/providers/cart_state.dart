import 'package:app/backend/server_communicator.dart';
import 'package:app/models/cart.dart';
import 'package:app/models/user.dart';
import 'package:flutter/foundation.dart';

class Response {
  final int? statusCode;
  final String message;

  Response({required this.statusCode, required this.message});
}

class CartState extends ChangeNotifier {
  List<User> _users = [];
  List<User> get users => _users; // directly expose the list
  List<Cart> _carts = [];

  List<Cart> get carts => _carts;

  // Fetch carts from the server
  Future<Response> fetchCarts() async {
    try {
      final response = await ServerCommunicator().sendRequest("/get_carts", HTTPMethod.get, {});
      final cartData = response["data"];
      if (response["statusCode"] == 200) {
        _carts = (cartData as List<dynamic>).map((e) => Cart.fromJson(e as Map<String, dynamic>)).toList();
        notifyListeners();
        return Response(statusCode: 200, message: "Successfully fetched carts");
      } else {
        return Response(statusCode: response["statusCode"], message: "Failed to fetch carts");
      }
    } catch (e) {
      return Response(statusCode: null, message: "Error occurred when fetching carts");
    }
  }

  // Create a new cart
  Future<Response> createCart(String name, String description) async {
    try {
      final response = await ServerCommunicator().sendRequest("/add_cart", HTTPMethod.post, {"name": name, "description": description});
      if (response["statusCode"] == 201) {
        notifyListeners();
        return Response(statusCode: 201, message: "Successfully created cart");
      } else {
        return Response(statusCode: response["statusCode"], message: "Failed to create cart");
      }
    } catch (e) {
      return Response(statusCode: null, message: "Error occurred when creating cart");
    }
  }

  // Remove user from cart
  Future<Response> removeUserFromCart(int cartId) async {
    try {
      final response = await ServerCommunicator().sendRequest("/delete_user_from_cart", HTTPMethod.delete, {"cart_id": cartId});
      if (response["statusCode"] == 200) {
        _carts = _carts.where((cart) => cart.id != cartId).toList();
        notifyListeners();
        return Response(statusCode: 200, message: "Successfully deleted cart");
      } else {
        return Response(statusCode: response["statusCode"], message: "Failed to delete cart");
      }
    } catch (e) {
      return Response(statusCode: null, message: "Error occurred when sending request");
    }
  }

  // User registration
  Future<Response> register(String email, String password) async {
    try {
      final response = await ServerCommunicator().sendRequest(
        "/register",
        HTTPMethod.post,
        {
          "username": email.trim(),
          "password": password.trim(),
        },
      );
      if (response["statusCode"] == 201) {
        return Response(statusCode: 201, message: "Successfully registered");
      } else {
        return Response(statusCode: response["statusCode"], message: "Failed to register");
      }
    } catch (e) {
      return Response(statusCode: null, message: "Error occurred when registering");
    }
  }

  // User login
  Future<Response> login(String email, String password) async {
    try {
      final response = await ServerCommunicator().sendRequest(
        "/login",
        HTTPMethod.post,
        {
          "username": email.trim(),
          "password": password.trim(),
        },
      );

      if (response["statusCode"] == 200) {
        ServerCommunicator().username = email;
        ServerCommunicator().setToken(response["access_token"], response["refresh_token"]);
        return Response(statusCode: 200, message: "Successfully logged in");
      } else {
        return Response(statusCode: response["statusCode"], message: "Failed to log in");
      }
    } catch (e) {
      return Response(statusCode: null, message: "Error occurred when logging in");
    }
  }

  // Search users by name
  Future<void> searchUsers(String name) async {
    if (name.isEmpty) {
      _users = [];
      notifyListeners();  // Notify listeners when the user list is cleared
      return;
    }

    try {
      final response = await ServerCommunicator()
          .sendRequest("/search_user", HTTPMethod.post, {"username": name});

      if (response["statusCode"] == 200) {
        _users = (response["data"] as List<dynamic>)
            .map((e) => User.fromJson(e as Map<String, dynamic>))
            .toList();
        notifyListeners();
      }
    } catch (e) {
      _users = [];
      notifyListeners();
    }
  }

  // Add a friend
  Future<Response> addFriend(String email) async {
    try {
      final response = await ServerCommunicator()
          .sendRequest("/add_friend", HTTPMethod.post, {"username": email});

      if (response["statusCode"] == 201) {
        final username = ServerCommunicator().username;
        _users = _users.map((user) {
          if (user.email == email) {
            user.friends.add(username!);
          }
          return user;
        }).toList();
        notifyListeners();
        return Response(statusCode: 201, message: "Successfully added friend");
      } else {
        return Response(statusCode: response["statusCode"], message: "Failed to add friend");
      }
    } catch (e) {
      return Response(statusCode: null, message: "Error occurred when adding friend");
    }
  }

  // Remove a friend
  Future<Response> removeFriend(String email) async {
    try {
      final response = await ServerCommunicator()
          .sendRequest("/remove_friend", HTTPMethod.delete, {"username": email});

      if (response["statusCode"] == 200) {
         final username = ServerCommunicator().username;
        _users = _users.map((user) {
          if (user.email == email) {
            user.friends.remove(username!);
          }
          return user;
        }).toList();
        notifyListeners();
        return Response(statusCode: 200, message: "Successfully removed friend");
      } else {
        return Response(statusCode: response["statusCode"], message: "Failed to remove friend");
      }
    } catch (e) {
      return Response(statusCode: null, message: "Error occurred when removing friend");
    }
  }
}
