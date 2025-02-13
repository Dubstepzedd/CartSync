
import 'package:app/helper.dart';
import 'package:app/pages/providers/app_state.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class MainScaffold extends StatefulWidget {
  final Widget child;
  final List<String> tabs = const ["home", "list_page", "follow"];
  
  const MainScaffold({super.key, required this.child});

  @override
  State<MainScaffold> createState() => MainScaffoldState();
}

class MainScaffoldState extends State<MainScaffold> {

  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4.0),
          child: Container(
              color: Colors.grey[300],
              height: 2.0,
          )
        ),
        backgroundColor: Colors.white,
        actions: <Widget>[
          IconButton(
            icon: const Icon(
              Icons.exit_to_app_outlined,
              color: Colors.black,
            ),
            onPressed: () {
              context.read<AppState>().logout().then((response) {
                if (!context.mounted) return;

                displayMessage(context, response.statusCode == 200, response.message);

                if(response.statusCode == 200) {
                  context.replace('/login');
                }
              });
            },
          )
        ],
      ),
      backgroundColor: Colors.white,
      body: widget.child,
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          if(index >= 0 && index < widget.tabs.length) {
            context.go('/${widget.tabs[index]}');
          }

          setState(() {
            selectedIndex = index;
          });
        },
        selectedIndex: selectedIndex,
        backgroundColor: Colors.white,
        indicatorColor: Colors.amber,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.add), label: 'Add List'),
          NavigationDestination(icon: Icon(Icons.people_alt), label: 'Find users'),
        ],
      ),
    );
  }
}