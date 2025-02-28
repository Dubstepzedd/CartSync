import 'package:app/helper.dart';
import 'package:app/models/cart.dart';
import 'package:app/models/item.dart';
import 'package:app/pages/providers/app_state.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class CartPage extends StatefulWidget {
  final Cart cart;

  const CartPage({required this.cart, super.key});

  @override
  State<StatefulWidget> createState() {
    return CartPageState();
  }
}

class CartPageState extends State<CartPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.add,
              color: Colors.black,
            ),
            onPressed: () {
              context.push('/add_item', extra: widget.cart);
            },
          )
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4.0),
          child: Container(
              color: Colors.grey[300],
              height: 2.0,
          )
        ),
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back)
        ),
      ),
      body: Center(
        child: ListView.separated(
          itemCount: widget.cart.items.length,
          itemBuilder: (BuildContext context, int index) {
            Item item = widget.cart.items[index];
            return ListTile(
              tileColor: Colors.grey[200],
              title: Text(item.name),
              trailing: SizedBox(
                width: 100,
                child: Row(
                  children: [
                    IconButton(
                      icon: item.isChecked ? const Icon(Icons.radio_button_on) : const Icon(Icons.radio_button_off),
                      onPressed: () {
                        context.read<AppState>().toggleItem(item).then((response) {
                          if (!context.mounted) {
                            return;
                          }
                    
                          displayMessage(context, response.statusCode == 200, response.message);
                    
                        });
                      }
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        context.read<AppState>().removeItem(item).then((response) {
                          if (!context.mounted) {
                            return;
                          }
                    
                          displayMessage(context, response.statusCode == 200, response.message);
                    
                        });
                      }
                    )
                  ],
                ),
              ),
            );
          }, 
          separatorBuilder: (BuildContext context, int index) {
            return const SizedBox(height: 5);
          },
        )
      ),
    );
  }
}