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
      final state = context.read<AppState>();
      state.fetchFriends();
      state.fetchFriendRequests();
      if (state.users.isNotEmpty) state.clearUsers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionHeader("Incoming Requests", icon: Icons.mail_outline),
          const SizedBox(height: 12),
          Consumer<AppState>(
            builder: (context, cartState, child) {
              final requests = cartState.incomingRequests;
              if (requests.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    "No pending requests",
                    style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                  ),
                );
              }
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: requests.length,
                itemBuilder: (BuildContext context, int index) {
                  return UserTile(user: requests[index], isIncomingRequest: true);
                },
              );
            },
          ),
          const SizedBox(height: 24),
          const _SectionHeader("Find Users", icon: Icons.people_outline),
          const SizedBox(height: 12),
          TextFormField(
            onChanged: (value) => context.read<AppState>().searchUsers(value),
            decoration: const InputDecoration(
              hintText: "Search by username",
              prefixIcon: Icon(Icons.search),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Consumer<AppState>(
              builder: (context, cartState, child) {
                final users = cartState.users;
                if (users.isEmpty) return const SizedBox.shrink();
                return ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (BuildContext context, int index) {
                    return UserTile(user: users[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}


class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;

  const _SectionHeader(this.title, {required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.black54),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}

class UserTile extends StatelessWidget {
  final User user;
  final bool isActionable;
  final bool isIncomingRequest;

  const UserTile({
    super.key,
    required this.user,
    this.isActionable = true,
    this.isIncomingRequest = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade100,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: CircleAvatar(
          backgroundColor: Colors.blueAccent.withValues(alpha: 0.12),
          child: Text(
            user.email[0].toUpperCase(),
            style: const TextStyle(
              color: Colors.blueAccent,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          user.email,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black87),
        ),
        trailing: isIncomingRequest
            ? buildIncomingRequestButtons(context, user)
            : isActionable
                ? buildFriendActionButton(context, user)
                : null,
      ),
    );
  }

  Widget buildIncomingRequestButtons(BuildContext context, User target) {
    final appState = context.read<AppState>();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.check_circle_outline, color: Colors.green),
          tooltip: "Accept",
          onPressed: () async {
            final response = await appState.acceptFriendRequest(target.email);
            if (!context.mounted) return;
            displayMessage(context, response.statusCode == 200, response.message);
          },
        ),
        IconButton(
          icon: const Icon(Icons.cancel_outlined, color: Colors.red),
          tooltip: "Decline",
          onPressed: () async {
            final response = await appState.removeFriendRequest(target.email);
            if (!context.mounted) return;
            displayMessage(context, response.statusCode == 200, response.message);
          },
        ),
      ],
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
        action = () async => await appState.removeFriendRequest(target.email);
        break;

      case FriendshipStatus.requestReceived:
        icon = Icons.check_circle_outline;
        color = Colors.green;
        action = () async => await appState.acceptFriendRequest(target.email);
        break;

      case FriendshipStatus.none:
        icon = Icons.group_add;
        color = Colors.blue;
        action = () async => await appState.sendFriendRequest(target.email);
        break;
    }

    return IconButton(
      icon: Icon(icon, color: color),
      tooltip: status.toString().split('.').last,
      onPressed: () async {
        final response = await action();
        if (!context.mounted) return;
        displayMessage(context, response.statusCode == 200 || response.statusCode == 201, response.message);
      },
    );
  }
}
