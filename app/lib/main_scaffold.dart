
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MainScaffold extends StatefulWidget {
  final Widget child;
  final List<String> tabs = const ["home", "list_page", "friends", "settings"];
  
  const MainScaffold({super.key, required this.child});

  @override
  State<MainScaffold> createState() => MainScaffoldState();
}

class MainScaffoldState extends State<MainScaffold> {

  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    //TODO Fix so you cant go back
    return Scaffold(
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
          NavigationDestination(icon: Icon(Icons.people_alt), label: 'Add Friends'),
          NavigationDestination(icon: Icon(Icons.settings), label: 'Settings')
        ],
      ),
    );
  }
}