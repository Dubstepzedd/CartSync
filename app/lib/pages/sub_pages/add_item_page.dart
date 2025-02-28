import 'package:app/helper.dart';
import 'package:app/models/cart.dart';
import 'package:app/pages/providers/app_state.dart';
import 'package:app/widget_helper.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class AddItemPage extends StatefulWidget {
  final Cart cart;

  const AddItemPage({super.key, required this.cart});

  @override
  AddItemPageState createState() => AddItemPageState();
}

class AddItemPageState extends State<AddItemPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      context.read<AppState>().addItem(widget.cart, _nameController.text, _descriptionController.text).then((response) {
          
        if(!mounted) {
          return;
        }

        displayMessage(context, response.statusCode == 201, response.message);

        if(response.statusCode == 201) {
          context.pop();
        }

      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.pop();
          },
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4.0),
          child: Container(
              color: Colors.grey[300],
              height: 2.0,
          )
        )
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              getTextField("Name", _nameController),
              const SizedBox(height: 20),
              getTextField("Description", _descriptionController),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: Colors.grey[300],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text('Add item', style: TextStyle(fontSize: 16, color: Colors.grey[800]))
              ),
            ],
          ),
        ),
      ),
    );
  }
}