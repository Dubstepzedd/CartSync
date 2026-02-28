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

  List<Cart> get carts => _carts;

  void clearUsers() {
    _searchedUsers = [];
    notifyListeners();
  }

  Future<Response> fetchFriends() async {
    try {
        final response = await ServerCommunicator().sendRequest("/user/friends", HTTPMethod.get, {});
        final data = response["data"];
        if (response["statusCode"] == 200) {
          _friends = (data as List<dynamic>).map((e) => User.fromJson(e as Map<String, dynamic>)).toList();
          notifyListeners();
          return Response(statusCode: 200, message: "Successfully fetched friends");
        }
        else {
          return Response(statusCode: response["statusCode"], message: "Failed to fetch friends");
        }
    }
    catch(e) {
        return Response(statusCode: null, message: "Error occurred when creating cart");
    }
  }
  Future<Response> fetchCarts() async {
    try {
      final response = await ServerCommunicator().sendRequest("/carts", HTTPMethod.get, {});
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

  Future<Response> createCart(String name, String description) async {
    try {
      final response = await ServerCommunicator().sendRequest("/cart/create", HTTPMethod.post, {"name": name, "description": description});
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

  Future<Response> removeUserFromCart(int cartId) async {
    try {
      final response = await ServerCommunicator().sendRequest("/cart/remove", HTTPMethod.delete, {"cart_id": cartId});
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
        ServerCommunicator().setUsername(email);
        ServerCommunicator().setToken(response["access_token"], response["refresh_token"]);
        return Response(statusCode: 200, message: "Successfully logged in");
      } else {
        return Response(statusCode: response["statusCode"], message: "Failed to log in");
      }
    } catch (e) {
      return Response(statusCode: null, message: "Error occurred when logging in");
    }
  }

  Future<Response> logout() async {
    try {
      final response = await ServerCommunicator().sendRequest("/logout", HTTPMethod.delete, {});

      if(response["statusCode"] == 200) {
        ServerCommunicator().clearStorage();
        return Response(statusCode: 200, message: "Successfully logged out");
      }
      else {
        return Response(statusCode: response["statusCode"], message: "Failed to log out");
      }
    }
    catch (e) {
      return Future.value(Response(statusCode: null, message: "Error occurred when logging out"));
    }
  }

  Cart? getCart(int id) {
    try {
      return carts.firstWhere((c) => c.id == id);
    }
    catch (e) {
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

  Future<Response> addFriend(final String email) async {
    try {
      final response = await ServerCommunicator()
          .sendRequest("/user/befriend", HTTPMethod.post, {"username": email});

      if (response["statusCode"] == 201) {
        _searchedUsers = _searchedUsers.map((user) {
          if (user.email == email) {
            user.friends.add(ServerCommunicator().username as String);
          }
          return user;
        }).toList();
        notifyListeners();
        return Response(statusCode: 201, message: "Successfully followed $email");
      } else {
        return Response(statusCode: response["statusCode"], message: "Failed to follow user");
      }
    } catch (e) {
      return Response(statusCode: null, message: "Error occurred when adding friend");
    }
  }

  Future<Response> removeFriend(String email) async {
    try {
      final response = await ServerCommunicator()
          .sendRequest("/user/unfriend", HTTPMethod.post, {"username": email});

      if (response["statusCode"] == 200) {
        _searchedUsers = _searchedUsers.map((user) {
          if (user.email == email) {
            user.friends.remove(ServerCommunicator().username as String);
          }
          return user;
        }).toList();
        notifyListeners();
        return Response(statusCode: 200, message: "Successfully unfollowed $email");
      }
      else {
        return Response(statusCode: response["statusCode"], message: "Failed to unfollow user");
      }
    } catch (e) {
      return Response(statusCode: null, message: "Error occurred when removing friend");
    }
  }

  Future<Response> addItem(int cartId, String name, String description) async {
    try {
      final response = await ServerCommunicator()
          .sendRequest("/cart/item/add", HTTPMethod.post, {"cart_id": cartId, "item_name": name, "item_description": description});

      if (response["statusCode"] == 201) {
        final item = Item.fromJson(response["data"] as Map<String, dynamic>);

        final cartIndex = _carts.indexWhere((c) => c.id == cartId);

        if (cartIndex != -1) {
          final oldCart = _carts[cartIndex];
          final newItems = List<Item>.from(oldCart.items)..add(item);

          final newCart = Cart(
            id: oldCart.id,
            name: oldCart.name,
            description: oldCart.description,
            usernames: oldCart.usernames,
            items: newItems,
          );

          _carts[cartIndex] = newCart;
          notifyListeners();
        }

        return Response(statusCode: 201, message: "Successfully added item");
      }
      else {
        return Response(statusCode: response["statusCode"], message: "Failed to add item");
      }
    }
    catch (e) {
      return Response(statusCode: null, message: "Error occurred when adding item");
    }
  }

  Future<Response> toggleItem(Item item) async {
    try {
      final response = await ServerCommunicator().sendRequest("/cart/item/toggle", HTTPMethod.post, {"item_id": item.id});
      if (response["statusCode"] == 200) {
        final newItemData = response["data"];

        final cartIndex = _carts.indexWhere((c) => c.items.any((i) => i.id == item.id));

        if (cartIndex != -1) {
          final oldCart = _carts[cartIndex];

          final newItems = oldCart.items.map((i) {
            if (i.id == item.id) {
              i.isChecked = newItemData["is_checked"];
              return i;
            }
            return i;
          }).toList();

          final newCart = Cart(
            id: oldCart.id,
            name: oldCart.name,
            description: oldCart.description,
            usernames: oldCart.usernames,
            items: newItems,
          );

          _carts[cartIndex] = newCart;
          notifyListeners();
        }
        return Response(statusCode: 200, message: "Successfully toggled item");
      }
      else {
        return Response(statusCode: response["statusCode"], message: "Failed to toggle item");
      }
    } catch (e) {
      return Response(statusCode: null, message: "Error occurred when toggling item");
    }
  }

  Future<Response> removeItem(Item item) async {
    try {
      final response = await ServerCommunicator().sendRequest("/cart/item/remove", HTTPMethod.delete, {"item_id": item.id});
      if (response["statusCode"] == 200) {

        final cartIndex = _carts.indexWhere((c) => c.items.any((i) => i.id == item.id));

        if (cartIndex != -1) {
          final oldCart = _carts[cartIndex];
          final newItems = oldCart.items.where((i) => i.id != item.id).toList();

          final newCart = Cart(
            id: oldCart.id,
            name: oldCart.name,
            description: oldCart.description,
            usernames: oldCart.usernames,
            items: newItems,
          );

          _carts[cartIndex] = newCart;
          notifyListeners();
        }

        return Response(statusCode: 200, message: "Successfully toggled item");
      }
      else {
        return Response(statusCode: response["statusCode"], message: "Failed to toggle item");
      }
    } catch (e) {
      return Response(statusCode: null, message: "Error occurred when toggling item");
    }
  }
}