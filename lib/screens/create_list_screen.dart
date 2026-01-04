// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import '../widgets/custom_textfield.dart';
import '../widgets/custom_button.dart';
import '../database/db_helper.dart';
import '../models/shopping_list.dart';

class CreateListScreen extends StatelessWidget {
  CreateListScreen({super.key});

  final TextEditingController listNameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // Get the userId passed from HomeScreen
    final int userId = ModalRoute.of(context)!.settings.arguments as int;

    return Scaffold(
      appBar: AppBar(title: const Text('Create List')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            CustomTextField(
              hintText: 'List Name',
              controller: listNameController,
            ),
            const SizedBox(height: 20),
            CustomButton(
              text: 'Save',
              onPressed: () async {
                if (listNameController.text.isNotEmpty) {
                  await DBHelper().insertList(
                    ShoppingList(
                      name: listNameController.text,
                      userId: userId, // ✅ IMPORTANT
                    ),
                  );
                  Navigator.pop(context); // Return to HomeScreen
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
