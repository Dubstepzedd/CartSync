import 'package:flutter/material.dart';

class FriendsPage extends StatefulWidget {
  const FriendsPage({super.key});
  
  @override
  State<StatefulWidget> createState() {
    return FriendState();
  }

 
}

class FriendState extends State<FriendsPage> {
  
  final emailController = TextEditingController();
  List<Map<String, dynamic>> friends = [];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0,16,0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              onChanged: (value) => {
                setState(() {
                  friends = [
                    {"name": "Friend 1", "email": "test@gmail.com"},
                    {"name": "Friend 1", "email": "test@gmail.com"},
                    {"name": "Friend 1", "email": "test@gmail.com"}
                  ];
                })
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
            ListView.builder(
              shrinkWrap: true,
              itemCount: friends.length,
              itemBuilder: (BuildContext context, int index) {

                final friend = friends[index];
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        friend["name"],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        friend["email"],
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                    ]
                  )
                );
              },
            )
          ],
        ),
      ),
    );
  }
}
