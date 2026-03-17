import 'package:app/backend/server_communicator.dart';
import 'package:app/models/cart.dart';
import 'package:app/models/item.dart';
import 'package:app/models/user.dart';
import 'package:flutter/foundation.dart';

class Response {
  final int? statusCode;
  final String message;

  Response({required this.statusCode, required this.message});
}

class AppState extends ChangeNotifier {
  List<User> _searchedUsers = [];
  List<User> get users => _searchedUsers;
  List<Cart> _carts = [];
  List<User> _friends = [];
  List<User> get friends => _friends;
  List<User> _incomingRequests = [];
  List<User> get incomingRequests => _incomingRequests;

  List<Cart> get carts => _carts;

  void clearUsers() {
    _searchedUsers = [];
    notifyListeners();
  }

  Future<Response> fetchFriends() async {
    try {
      final response = await ServerCommunicator()
          .sendRequest("/user/friends", HTTPMethod.get, {});
      if (response["statusCode"] == 200) {
        _friends = (response["data"] as List<dynamic>)
            .map((e) => User.fromJson(e as Map<String, dynamic>))
            .toList();
        notifyListeners();
        return Response(
          statusCode: 200,
          message: "Successfully fetched friends",
        );
      }
      return Response(
        statusCode: response["statusCode"],
        message: "Failed to fetch friends",
      );
    } catch (e) {
      return Response(
        statusCode: null,
        message: "Error occurred when fetching friends",
      );
    }
  }

  Future<Response> fetchFriendRequests() async {
    try {
      final response = await ServerCommunicator()
          .sendRequest("/user/requests", HTTPMethod.get, {});
      if (response["statusCode"] == 200) {
        _incomingRequests = (response["data"] as List<dynamic>)
            .map((e) => User.fromJson(e as Map<String, dynamic>))
            .toList();
        notifyListeners();
        return Response(
          statusCode: 200,
          message: "Successfully fetched requests",
        );
      }
      return Response(
        statusCode: response["statusCode"],
        message: "Failed to fetch requests",
      );
    } catch (e) {
      return Response(
        statusCode: null,
        message: "Error occurred when fetching requests",
      );
    }
  }

  Future<Response> fetchCarts() async {
    try {
      final response = await ServerCommunicator()
          .sendRequest("/carts", HTTPMethod.get, {});
      if (response["statusCode"] == 200) {
        _carts = (response["data"] as List<dynamic>)
            .map((e) => Cart.fromJson(e as Map<String, dynamic>))
            .toList();
        notifyListeners();
        return Response(
          statusCode: 200,
          message: "Successfully fetched carts",
        );
      }
      return Response(
        statusCode: response["statusCode"],
        message: "Failed to fetch carts",
      );
    } catch (e) {
      return Response(
        statusCode: null,
        message: "Error occurred when fetching carts",
      );
    }
  }

  Future<Response> createCart(String name, String description) async {
    try {
      final response = await ServerCommunicator().sendRequest(
        "/cart/create",
        HTTPMethod.post,
        {"name": name, "description": description},
      );
      if (response["statusCode"] == 201) {
        notifyListeners();
        return Response(
          statusCode: 201,
          message: "Successfully created cart",
        );
      }
      return Response(
        statusCode: response["statusCode"],
        message: "Failed to create cart",
      );
    } catch (e) {
      return Response(
        statusCode: null,
        message: "Error occurred when creating cart",
      );
    }
  }

  Future<Response> removeUserFromCart(int cartId) async {
    try {
      final response = await ServerCommunicator()
          .sendRequest("/cart/remove", HTTPMethod.delete, {"cart_id": cartId});
      if (response["statusCode"] == 200) {
        _carts = _carts.where((cart) => cart.id != cartId).toList();
        notifyListeners();
        return Response(
          statusCode: 200,
          message: "Successfully removed from cart",
        );
      }
      return Response(
        statusCode: response["statusCode"],
        message: "Failed to remove from cart",
      );
    } catch (e) {
      return Response(
        statusCode: null,
        message: "Error occurred when removing from cart",
      );
    }
  }

  Future<Response> register(String email, String password) async {
    try {
      final response = await ServerCommunicator().sendRequest(
        "/register",
        HTTPMethod.post,
        {"username": email.trim(), "password": password.trim()},
      );
      if (response["statusCode"] == 201) {
        return Response(
          statusCode: 201,
          message: "Successfully registered",
        );
      }
      return Response(
        statusCode: response["statusCode"],
        message: "Failed to register",
      );
    } catch (e) {
      return Response(
        statusCode: null,
        message: "Error occurred when registering",
      );
    }
  }

  Future<Response> login(String email, String password) async {
    try {
      final response = await ServerCommunicator().sendRequest(
        "/login",
        HTTPMethod.post,
        {"username": email.trim(), "password": password.trim()},
      );
      if (response["statusCode"] == 200) {
        ServerCommunicator().setUsername(email);
        ServerCommunicator()
            .setToken(response["access_token"], response["refresh_token"]);
        return Response(
          statusCode: 200,
          message: "Successfully logged in",
        );
      }
      return Response(
        statusCode: response["statusCode"],
        message: "Failed to log in",
      );
    } catch (e) {
      return Response(
        statusCode: null,
        message: "Error occurred when logging in",
      );
    }
  }

  Future<Response> logout() async {
    try {
      final response = await ServerCommunicator()
          .sendRequest("/logout", HTTPMethod.delete, {});
      if (response["statusCode"] == 200) {
        ServerCommunicator().clearStorage();
        return Response(
          statusCode: 200,
          message: "Successfully logged out",
        );
      }
      return Response(
        statusCode: response["statusCode"],
        message: "Failed to log out",
      );
    } catch (e) {
      return Response(
        statusCode: null,
        message: "Error occurred when logging out",
      );
    }
  }

  Cart? getCart(int id) {
    try {
      return carts.firstWhere((c) => c.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<void> searchUsers(String name) async {
    if (name.isEmpty) {
      _searchedUsers = [];
      notifyListeners();
      return;
    }
    try {
      final response = await ServerCommunicator()
          .sendRequest("/user/search", HTTPMethod.post, {"username": name});
      if (response["statusCode"] == 200) {
        _searchedUsers = (response["data"] as List<dynamic>)
            .map((e) => User.fromJson(e as Map<String, dynamic>))
            .toList();
        notifyListeners();
      }
    } catch (e) {
      _searchedUsers = [];
      notifyListeners();
    }
  }

  Future<Response> sendFriendRequest(String email) async {
    try {
      final response = await ServerCommunicator()
          .sendRequest("/user/request", HTTPMethod.post, {"username": email});
      if (response["statusCode"] == 201) {
        final me = ServerCommunicator().username!;
        for (final user in _searchedUsers) {
          if (user.email == email) {
            user.receivedRequests.add(me);
            break;
          }
        }
        notifyListeners();
        return Response(
          statusCode: 201,
          message: "Friend request sent to $email.",
        );
      }
      return Response(
        statusCode: response["statusCode"],
        message: response["msg"] ?? "Failed to send request.",
      );
    } catch (e) {
      return Response(
        statusCode: null,
        message: "Error occurred when sending friend request.",
      );
    }
  }

  Future<Response> acceptFriendRequest(String email) async {
    try {
      final response = await ServerCommunicator()
          .sendRequest("/user/accept", HTTPMethod.post, {"username": email});
      if (response["statusCode"] == 200) {
        final me = ServerCommunicator().username!;
        final accepted = _incomingRequests.firstWhere(
          (u) => u.email == email,
          orElse: () => _searchedUsers.firstWhere((u) => u.email == email),
        );
        _incomingRequests.removeWhere((u) => u.email == email);
        if (!_friends.any((u) => u.email == email)) {
          _friends.add(accepted);
        }
        for (final user in _searchedUsers) {
          if (user.email == email) {
            user.sentRequests.remove(me);
            user.friends.add(me);
            break;
          }
        }
        notifyListeners();
        return Response(
          statusCode: 200,
          message: "Friend request from $email accepted.",
        );
      }
      return Response(
        statusCode: response["statusCode"],
        message: response["msg"] ?? "Failed to accept request.",
      );
    } catch (e) {
      return Response(
        statusCode: null,
        message: "Error occurred when accepting friend request.",
      );
    }
  }

  Future<Response> removeFriendRequest(String email) async {
    try {
      final response = await ServerCommunicator().sendRequest(
        "/user/remove/request",
        HTTPMethod.delete,
        {"username": email},
      );
      if (response["statusCode"] == 200) {
        final me = ServerCommunicator().username!;
        _incomingRequests.removeWhere((u) => u.email == email);
        for (final user in _searchedUsers) {
          if (user.email == email) {
            user.receivedRequests.remove(me);
            user.sentRequests.remove(me);
            break;
          }
        }
        notifyListeners();
        return Response(
          statusCode: 200,
          message: "Friend request removed.",
        );
      }
      return Response(
        statusCode: response["statusCode"],
        message: response["msg"] ?? "Failed to remove request.",
      );
    } catch (e) {
      return Response(
        statusCode: null,
        message: "Error occurred when removing friend request.",
      );
    }
  }

  Future<Response> removeFriend(String email) async {
    try {
      final response = await ServerCommunicator().sendRequest(
        "/user/remove/friend",
        HTTPMethod.delete,
        {"username": email},
      );
      if (response["statusCode"] == 200) {
        final me = ServerCommunicator().username!;
        _friends.removeWhere((u) => u.email == email);
        for (final user in _searchedUsers) {
          if (user.email == email) {
            user.friends.remove(me);
            break;
          }
        }
        notifyListeners();
        return Response(
          statusCode: 200,
          message: "Friend removed.",
        );
      }
      return Response(
        statusCode: response["statusCode"],
        message: response["msg"] ?? "Failed to remove friend.",
      );
    } catch (e) {
      return Response(
        statusCode: null,
        message: "Error occurred when removing friend.",
      );
    }
  }

  Future<Response> shareCart(int cartId, String username) async {
    try {
      final response = await ServerCommunicator().sendRequest(
        "/cart/share",
        HTTPMethod.post,
        {"cart_id": cartId, "username": username},
      );
      if (response["statusCode"] == 200) {
        final cartIndex = _carts.indexWhere((c) => c.id == cartId);
        if (cartIndex != -1) {
          final old = _carts[cartIndex];
          _carts[cartIndex] = old.copyWith(usernames: [...old.usernames, username]);
        }
        notifyListeners();
        return Response(
          statusCode: 200,
          message: "Cart shared with $username.",
        );
      }
      return Response(
        statusCode: response["statusCode"],
        message: response["msg"] ?? "Failed to share cart.",
      );
    } catch (e) {
      return Response(
        statusCode: null,
        message: "Error occurred when sharing cart.",
      );
    }
  }

  Future<Response> addItem(int cartId, String name) async {
    try {
      final response = await ServerCommunicator().sendRequest(
        "/cart/item/add",
        HTTPMethod.post,
        {"cart_id": cartId, "item_name": name},
      );
      if (response["statusCode"] == 201) {
        final item = Item.fromJson(response["data"] as Map<String, dynamic>);
        final cartIndex = _carts.indexWhere((c) => c.id == cartId);
        if (cartIndex != -1) {
          final oldCart = _carts[cartIndex];
          final newCart = Cart(
            id: oldCart.id,
            name: oldCart.name,
            description: oldCart.description,
            usernames: oldCart.usernames,
            items: List<Item>.from(oldCart.items)..add(item),
          );
          _carts[cartIndex] = newCart;
          notifyListeners();
        }
        return Response(
          statusCode: 201,
          message: "Successfully added item",
        );
      }
      return Response(
        statusCode: response["statusCode"],
        message: "Failed to add item",
      );
    } catch (e) {
      return Response(
        statusCode: null,
        message: "Error occurred when adding item",
      );
    }
  }

  Future<Response> toggleItem(Item item) async {
    try {
      final response = await ServerCommunicator().sendRequest(
        "/cart/item/toggle",
        HTTPMethod.post,
        {"item_id": item.id},
      );
      if (response["statusCode"] == 200) {
        final newItemData = response["data"];
        final cartIndex =
            _carts.indexWhere((c) => c.items.any((i) => i.id == item.id));
        if (cartIndex != -1) {
          final oldCart = _carts[cartIndex];
          final newCart = Cart(
            id: oldCart.id,
            name: oldCart.name,
            description: oldCart.description,
            usernames: oldCart.usernames,
            items: oldCart.items.map((i) {
              if (i.id == item.id) i.isChecked = newItemData["is_checked"];
              return i;
            }).toList(),
          );
          _carts[cartIndex] = newCart;
          notifyListeners();
        }
        return Response(
          statusCode: 200,
          message: "Successfully toggled item",
        );
      }
      return Response(
        statusCode: response["statusCode"],
        message: "Failed to toggle item",
      );
    } catch (e) {
      return Response(
        statusCode: null,
        message: "Error occurred when toggling item",
      );
    }
  }

  Future<Response> removeItem(Item item) async {
    try {
      final response = await ServerCommunicator().sendRequest(
        "/cart/item/remove",
        HTTPMethod.delete,
        {"item_id": item.id},
      );
      if (response["statusCode"] == 200) {
        final cartIndex =
            _carts.indexWhere((c) => c.items.any((i) => i.id == item.id));
        if (cartIndex != -1) {
          final oldCart = _carts[cartIndex];
          final newCart = Cart(
            id: oldCart.id,
            name: oldCart.name,
            description: oldCart.description,
            usernames: oldCart.usernames,
            items: oldCart.items.where((i) => i.id != item.id).toList(),
          );
          _carts[cartIndex] = newCart;
          notifyListeners();
        }
        return Response(
          statusCode: 200,
          message: "Successfully removed item",
        );
      }
      return Response(
        statusCode: response["statusCode"],
        message: "Failed to remove item",
      );
    } catch (e) {
      return Response(
        statusCode: null,
        message: "Error occurred when removing item",
      );
    }
  }
}
