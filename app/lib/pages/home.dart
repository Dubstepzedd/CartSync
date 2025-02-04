import 'package:app/backend/server_communicator.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

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
              lists = snapshot.data["carts"] ?? [];
          }

          return ListView.builder(
            itemCount: lists.length,
            itemBuilder: (BuildContext context, int index) {
              final name = lists[index]["name"];
              final description = lists[index]["description"];
              final count = lists[index]["count"];
              return buildCard(name,description,count);
            },
          );
        }
      )
    );
  }

  Widget buildCard(String name, String description, int count) {
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
          Text(
            name,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
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
                "$count items in the list",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}