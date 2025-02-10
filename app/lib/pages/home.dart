import 'package:app/backend/server_communicator.dart';
import 'package:app/pages/providers/cart_state.dart';
import 'package:flutter/material.dart';
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
  Widget build(BuildContext context) {
    return  Center(
      child: FutureBuilder(
        future: ServerCommunicator().sendRequest("/get_carts", HTTPMethod.get, {}),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          } 
          else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }

          var lists = [];
          
          if (snapshot.data != null) {
              lists = snapshot.data["data"] ?? [];
          }

          if (lists.isEmpty) {
            return const Text("You have no carts yet");
          }

          return ListView.builder(
            itemCount: lists.length,
            itemBuilder: (BuildContext context, int index) {
              final listItem = lists[index] as Map<String, dynamic>; 
              final name = listItem["name"] as String;
              final description = listItem["description"] as String;
              final id = listItem["id"] as int;
              final usernames = List<String>.from(listItem["users"]); 
              final items = List<Map<String, dynamic>>.from(listItem["items"]); 

              return buildCard(id, name,description,items, usernames);
            },
          );
        }
      )
    );
  }

  Widget buildCard(int id, String name, String description, List<Map<String, dynamic>> items, List<String> usernames) {
    return Container(
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
                name,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              IconButton(
                onPressed: () async {
                  final errorMessage = await context.read<CartState>().removeUserFromCart(id);
                  if (!mounted) return;
                  if (errorMessage == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        backgroundColor: Colors.greenAccent,
                        content: Text(
                          'User removed successfully',
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: Colors.redAccent,
                        content: Text(
                          errorMessage,
                          style: const TextStyle(color: Colors.black),
                        ),
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.cancel),
                color: Colors.redAccent,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            description,
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
                "${items.length} items in the list",
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
                "${usernames.length} users have access",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}