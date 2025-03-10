import 'package:app/helper.dart';
import 'package:app/models/cart.dart';
import 'package:app/pages/providers/app_state.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  
  @override
  State<StatefulWidget> createState() {
    return HomePageState();
  }
}

class HomePageState extends State<HomePage> {

  @override 
  void initState() {
    super.initState();
    context.read<AppState>().fetchCarts();
  }
  @override
  Widget build(BuildContext context) {

    final carts = context.select((AppState s) => s.carts);
    return Center(
      child:
        ListView.builder(
          itemCount: carts.length,
          itemBuilder: (BuildContext context, int index) {
            Cart cart = carts[index];
            return buildCard(context, cart);
          }
        )
    );
  }

  Widget buildCard(BuildContext context, Cart cart) { 
    return GestureDetector(
      onTap: () => context.push('/cart', extra: cart),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white10,
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade200,
              blurRadius: 6,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.fromLTRB(20, 10, 20, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  cart.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                IconButton(
                  onPressed: () async {
                    context.read<AppState>().removeUserFromCart(cart.id).then((response) {
                      if (!context.mounted) return;
                      displayMessage(context, response.statusCode == 200, response.message);
                    });
                  },
                  icon: const Icon(Icons.cancel),
                  color: Colors.redAccent,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              cart.description,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  "${cart.items.length} items in the list",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  "${cart.usernames.length} users have access",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade700,
                  ),
                ),
              ]
            )
          ],
        ),
      ),
    );
  }
}