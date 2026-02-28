import 'package:app/backend/server_communicator.dart';
import 'package:app/helper.dart';
import 'package:app/models/friend_request.dart';
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
            const Text(textAlign: TextAlign.left, "Incoming Friend Requests"),
            const SizedBox(height: 20),
            Consumer<AppState>(
              builder: (context, cartState, child) {
                final users = cartState.friends;
                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: users.length,
                  itemBuilder: (BuildContext context, int index) {
                    final user = users[index];
                    return UserTile(user: user, isActionable: false);
                  },
                );
              },
            ),
            const SizedBox(height: 20),
            const Text(textAlign: TextAlign.left, "Add New Friends"),
            const SizedBox(height: 20),
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
              child: Consumer<AppState>(
                builder: (context, cartState, child) {
                  final users = cartState.users;
                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: users.length,
                    itemBuilder: (BuildContext context, int index) {
                      final user = users[index];
                      return UserTile(user: user);
                    },
                  );
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
  final bool isActionable;

  const UserTile({super.key, required this.user, this.isActionable = true});

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
          isActionable ? buildFriendActionButton(context, user) : const SizedBox()
        ],
      ),
    );
  }

  Widget buildFriendActionButton(BuildContext context, User target) {
    final appState = context.read<AppState>();
    final currentUsername = ServerCommunicator().username!;
    final status = target.getFriendshipStatus(currentUsername);

    IconData icon;
    Future<Response> Function() action;
    Color? color;

    switch (status) {
      case FriendshipStatus.active:
        icon = Icons.group_remove;
        color = Colors.red;
        action = () async => await appState.removeFriend(target.email);
        break;

      case FriendshipStatus.requestSent:
        icon = Icons.cancel_outlined;
        color = Colors.grey;
        action = () async => await appState.removeFriend(target.email);
        break;

      case FriendshipStatus.requestReceived:
        icon = Icons.check_circle_outline;
        color = Colors.green;
        action = () async => await appState.addFriend(target.email);
        break;

      case FriendshipStatus.none:
      default:
        icon = Icons.group_add;
        color = Colors.blue;
        action = () async => await appState.addFriend(target.email);
        break;
    }

    return IconButton(
      icon: Icon(icon, color: color),
      tooltip: status.toString().split('.').last,
      onPressed: () async {
        final response = await action();
        if (!context.mounted) return;

        displayMessage(context, response.statusCode == 201 || response.statusCode == 200, response.message);
      },
    );
  }
}
