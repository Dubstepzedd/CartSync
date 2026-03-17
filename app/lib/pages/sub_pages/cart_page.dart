import 'package:app/helper.dart';
import 'package:app/models/cart.dart';
import 'package:app/models/item.dart';
import 'package:app/models/user.dart';
import 'package:app/pages/providers/app_state.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class CartPage extends StatefulWidget {
  final int id;

  const CartPage({required this.id, super.key});

  @override
  State<StatefulWidget> createState() {
    return CartPageState();
  }
}

class CartPageState extends State<CartPage> {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppState>().fetchFriends();
    });
  }

  void _showShareSheet(BuildContext context, Cart cart) {
    final appState = context.read<AppState>();
    final shareable = appState.friends
        .where((f) => !cart.usernames.contains(f.email))
        .toList();

    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        if (shareable.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(24),
            child: Text("No friends to share with — either all are already in this cart or you have no friends yet."),
          );
        }
        return ListView.builder(
          itemCount: shareable.length,
          itemBuilder: (ctx, index) {
            final User friend = shareable[index];
            return ListTile(
              leading: const Icon(Icons.person_outline),
              title: Text(friend.email),
              trailing: const Icon(Icons.share_outlined),
              onTap: () async {
                Navigator.pop(ctx);
                final response = await appState.shareCart(cart.id, friend.email);
                if (!context.mounted) return;
                displayMessage(context, response.statusCode == 200, response.message);
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {

    final Cart? cart = context.select<AppState, Cart?>(
      (state) => state.getCart(widget.id)
    );

    if (cart == null) {
      return const Scaffold(
        body: Center(child: Text("Cart not found")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(cart.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_outlined),
            tooltip: "Share cart",
            onPressed: () => _showShareSheet(context, cart),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.push('/add_item', extra: widget.id),
          ),
        ],
      ),
      body: cart.items.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.shopping_basket_outlined, size: 64, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text("No items yet", style: TextStyle(fontSize: 16, color: Colors.grey.shade500)),
                  const SizedBox(height: 4),
                  Text("Tap + to add one", style: TextStyle(fontSize: 14, color: Colors.grey.shade400)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: cart.items.length,
              itemBuilder: (context, index) => _buildItemTile(context, cart.items[index]),
            ),
    );
  }

  Widget _buildItemTile(BuildContext context, Item item) {
    final checked = item.isChecked;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(color: Colors.grey.shade100, blurRadius: 4, offset: const Offset(0, 2)),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: GestureDetector(
          onTap: () {
            context.read<AppState>().toggleItem(item).then((response) {
              if (!context.mounted) return;
              if (response.statusCode != 200) {
                displayMessage(context, false, response.message);
              }
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: checked ? Colors.blueAccent : Colors.transparent,
              border: Border.all(
                color: checked ? Colors.blueAccent : Colors.grey.shade400,
                width: 2,
              ),
            ),
            child: checked
                ? const Icon(Icons.check, size: 14, color: Colors.white)
                : null,
          ),
        ),
        title: Text(
          item.name,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: checked ? Colors.grey.shade400 : Colors.black87,
            decoration: checked ? TextDecoration.lineThrough : null,
            decorationColor: Colors.grey.shade400,
          ),
        ),
        trailing: IconButton(
          icon: Icon(Icons.delete_outline, color: Colors.grey.shade400),
          onPressed: () {
            context.read<AppState>().removeItem(item).then((response) {
              if (!context.mounted) return;
              displayMessage(context, response.statusCode == 200, response.message);
            });
          },
        ),
      ),
    );
  }
}