import 'package:app/backend/server_communicator.dart';
import 'package:app/models/user.dart';
import 'package:app/pages/providers/cart_state.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FriendsPage extends StatefulWidget {
  const FriendsPage({super.key});
  
  @override
  State<StatefulWidget> createState() {
    return FriendState();
  }
}
class FriendState extends State<FriendsPage> {
  final emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              onChanged: (value) {
                context.read<CartState>().searchUsers(value);
              },
              decoration: InputDecoration(
                hintText: "Search for friends",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.blue),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.blueAccent),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: FutureBuilder<String?>(
                future: ServerCommunicator().getUsername(),
                builder: (BuildContext context, AsyncSnapshot<String?> snapshot) {
                  
                  if(snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  }
                  else {
                    final username = snapshot.data!;
                    return  Consumer<CartState>(
                      builder: (context, cartState, child) {
                        final users = cartState.users;
                        return ListView.builder(
                          shrinkWrap: true,
                          itemCount: users.length,
                          itemBuilder: (BuildContext context, int index) {
                            final friend = users[index];
                            return FriendTile(friend: friend, username: username);
                          },
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class FriendTile extends StatelessWidget {
  final User friend;
  final String username;

  const FriendTile({super.key, required this.friend, required this.username});

  @override
  Widget build(BuildContext context) {
    
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(10),
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            friend.email,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          IconButton(
            icon: Icon(friend.isFriend(username) ? Icons.remove : Icons.add),
            onPressed: () async {
              final cartState = context.read<CartState>();
              final response = friend.isFriend(username)
                  ? await cartState.removeFriend(friend.email)
                  : await cartState.addFriend(friend.email);

              if (!context.mounted) return;

              ScaffoldMessenger.of(context).clearSnackBars();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: response.statusCode == 200 || response.statusCode == 201
                      ? Colors.greenAccent
                      : Colors.redAccent,
                  content: Text(
                    response.message,
                    style: const TextStyle(color: Colors.black),
                  ),
                ),
              );
            },
        ) 
        ],
      ),
    );
  }
}
