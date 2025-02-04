import 'package:app/widget_helper.dart';
import 'package:flutter/material.dart';

class ListPage extends StatefulWidget {
  const ListPage({super.key});
  
  @override
  State<StatefulWidget> createState() {
    return ListState();
  }
}

class ListState extends State<ListPage> {

  final nameController = TextEditingController();
  final descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Create a new cart",
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16.0),
              getTextField("Name", nameController),
              const SizedBox(height: 16.0),
              getTextField("Description", descriptionController, maxLines: 3),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),  
                  backgroundColor: Colors.grey[300],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),  
                  ),
                ),
                child: Text('Create cart', style: TextStyle(fontSize: 18, color: Colors.grey[800])),
              ),
            ],
          ),
        ),
      ),
    );
  }

}
