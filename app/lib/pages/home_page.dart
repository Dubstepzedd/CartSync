import 'package:app/backend/server_communicator.dart';
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
    final carts = context
        .watch<AppState>()
        .carts; // Listen to all changes. Not the best but works.
    if (carts.isEmpty) {
      return const Center(child: Text("You have no carts yet!"));
    }

    return Center(
      child: ListView.builder(
        itemCount: carts.length,
        itemBuilder: (BuildContext context, int index) {
          return buildCard(context, carts[index]);
        },
      ),
    );
  }

  Widget _buildSharingChip(Cart cart) {
    final me = ServerCommunicator().username;
    final others = cart.usernames.length - 1;

    if (cart.usernames.length <= 1) return const SizedBox.shrink();

    final isInvited = cart.usernames.isNotEmpty && cart.usernames.first != me;

    if (isInvited) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.mail_outline, size: 13, color: Colors.blue.shade700),
                const SizedBox(width: 4),
                Text(
                  "Invited",
                  style: TextStyle(
                      fontSize: 13,
                      color: Colors.blue.shade700,
                      fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          const SizedBox(height: 3),
          Text(
            "Shared with $others other user${others == 1 ? '' : 's'}",
            style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
          ),
        ],
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.group_outlined, size: 13, color: Colors.green.shade700),
          const SizedBox(width: 4),
          Text(
            "Shared with $others user${others == 1 ? '' : 's'}",
            style: TextStyle(
                fontSize: 13,
                color: Colors.green.shade700,
                fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget buildCard(BuildContext context, Cart cart) {
    return GestureDetector(
      onTap: () => context.push('/cart', extra: cart.id),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade200),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade100,
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
                    context
                        .read<AppState>()
                        .removeUserFromCart(cart.id)
                        .then((response) {
                      if (!context.mounted) return;
                      displayMessage(context, response.statusCode == 200,
                          response.message);
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "${cart.items.length} item${cart.items.length == 1 ? '' : 's'}",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade700,
                  ),
                ),
                _buildSharingChip(cart),
              ],
            )
          ],
        ),
      ),
    );
  }
}
