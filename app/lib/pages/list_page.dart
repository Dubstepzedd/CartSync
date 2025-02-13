import 'package:app/pages/providers/cart_state.dart';
import 'package:app/widget_helper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
    return Padding(
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
                final name = nameController.text;
                final description = descriptionController.text;

                if (name.isEmpty || description.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please fill in all fields")));
                  return;
                }

                context.read<CartState>().createCart(name, description).then((response) {
                  
                  if(!context.mounted) {
                    return;
                  }

                  if (response.statusCode == 201) {
                    nameController.clear();
                    descriptionController.clear();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: Colors.greenAccent,
                        content: Text(
                          style: const TextStyle(color: Colors.black),
                          response.message
                        )
                      )
                    );
                  } 
                  else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: Colors.redAccent,
                        content: Text(
                          style: const TextStyle(color: Colors.black),
                          response.message
                        )
                      )
                    );
                  }
                });
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: Colors.grey[300],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text('Create cart', style: TextStyle(fontSize: 18, color: Colors.grey[800])),
            )
          ],
        ),
      ),
    );
  }
}
