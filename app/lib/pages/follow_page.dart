import 'package:app/backend/server_communicator.dart';
import 'package:app/helper.dart';
import 'package:app/models/user.dart';
import 'package:app/pages/providers/app_state.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FollowPage extends StatefulWidget {
  const FollowPage({super.key});
  
  @override
  State<StatefulWidget> createState() {
    return UserState();
  }
}
class UserState extends State<FollowPage> {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.read<AppState>().users.isEmpty) {
        return;
      }

      context.read<AppState>().clearUsers();
    });
  }

  @override
  Widget build(BuildContext context) {

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextFormField(
              onChanged: (value) {
                context.read<AppState>().searchUsers(value);
              },
              decoration: InputDecoration(
                hintText: "Search for users",
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
                    final username = snapshot.data;

                    if(username == null) {
                      return const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(Icons.error, color: Colors.redAccent, size: 50,),
                          Text("A fatal error occurred, please log out and log back in."),
                        ]
                      );
                    }
                    return  Consumer<AppState>(
                      builder: (context, cartState, child) {
                        final users = cartState.users;
                        return ListView.builder(
                          shrinkWrap: true,
                          itemCount: users.length,
                          itemBuilder: (BuildContext context, int index) {
                            final user = users[index];
                            return UserTile(user: user, username: username);
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


class UserTile extends StatelessWidget {
  final User user;
  final String username;

  const UserTile({super.key, required this.user, required this.username});

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
            user.email,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          IconButton(
            icon: Icon(user.isFollowed ? Icons.remove : Icons.add),
            onPressed: () async {
              final cartState = context.read<AppState>();
              final response = user.isFollowed
                  ? await cartState.unfollowUser(user.email)
                  : await cartState.followUser(user.email);

              if (!context.mounted) return;

              displayMessage(context, response.statusCode == 201 || response.statusCode == 200, response.message);
            },
        ) 
        ],
      ),
    );
  }
}
