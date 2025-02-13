import 'package:app/helper.dart';
import 'package:app/pages/providers/app_state.dart';
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
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: Form(
          key: formKey,
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
                  
                  if(formKey.currentState!.validate()) {
                    final name = nameController.text;
                    final description = descriptionController.text;
          
                    context.read<AppState>().createCart(name, description).then((response) {
                    
                      if(!context.mounted) {
                        return;
                      }

                      displayMessage(context, response.statusCode == 201, response.message);

                      if (response.statusCode == 201) {
                        formKey.currentState!.reset();
                      } 
                    });
                  }
                  else {
                    displayMessage(context, false, "Please fill in all the fields");
                  }
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
      ),
    );
  }
}
