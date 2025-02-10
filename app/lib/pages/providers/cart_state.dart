import 'package:app/backend/server_communicator.dart';
import 'package:flutter/foundation.dart';

class CartState extends ChangeNotifier {
  bool isLoading = false;
  String? errorMessage;

  Future<String?> createCart(String name, String description) async {
    isLoading = true;
    notifyListeners();

    try {
      final response = await ServerCommunicator().sendRequest("/add_cart", HTTPMethod.post, {"name": name, "description": description});
      
      if (response.containsKey("statusCode") && response["statusCode"] == 201) {
        errorMessage = null;
      } else {
        return  "Failed to add cart";
      }
    } catch (e) {
      return "An error occurred: $e";
    }

    isLoading = false;
    notifyListeners();
    return null;
  }

  Future<String?> removeUserFromCart(int cartId) async {
    isLoading = true;
    notifyListeners();

    try {
      final response = await ServerCommunicator().sendRequest("/delete_cart", HTTPMethod.delete, {"cart_id": cartId});
      
      if (response.containsKey("statusCode") && response["statusCode"] == 200) {
        errorMessage = null;
      } else {
        return  "Failed to delete cart";
      }
    } catch (e) {
      return "An error occurred: $e";
    }

    isLoading = false;
    notifyListeners();
    return null;
  }
}
