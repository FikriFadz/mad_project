import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EditRecipe extends StatefulWidget {
  final String passedName;

  const EditRecipe({super.key, required this.passedName});

  @override
  State<EditRecipe> createState() => _EditRecipeState();
}

class _EditRecipeState extends State<EditRecipe> {
  final _recipeNameController = TextEditingController();
  final _ingredientsController = TextEditingController();
  final _instructionsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchRecipeDetails();
  }

  Future<void> fetchRecipeDetails() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        final userEmail = user.email;

        final recipeDoc = await FirebaseFirestore.instance
            .collection('Users')
            .doc(userEmail)
            .collection('Recipes')
            .doc(widget.passedName)
            .get();

        setState(() {
          _recipeNameController.text = recipeDoc.id;
          _ingredientsController.text = recipeDoc['Ingredient'] as String;
          _instructionsController.text = recipeDoc['Instruction'] as String;
        });
      }
    } catch (error) {
      print("Error fetching recipe: ${error}");
    }
  }

  Future<void> editRecipe() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        final userEmail = user.email;

        // Fetch the old recipe details
        final oldRecipeDoc = await FirebaseFirestore.instance
            .collection('Users')
            .doc(userEmail)
            .collection('Recipes')
            .doc(widget.passedName)
            .get();

        // Save the old details
        final Map<String, dynamic> oldDetails = {
          'Ingredient': oldRecipeDoc['Ingredient'],
          'Instruction': oldRecipeDoc['Instruction'],
          'Favorite': oldRecipeDoc['Favorite'] ?? false,
          'Timestamp': oldRecipeDoc['Timestamp'],
          'Type': oldRecipeDoc['Type'],
        };

        // Delete the old document
        await FirebaseFirestore.instance
            .collection('Users')
            .doc(userEmail)
            .collection('Recipes')
            .doc(widget.passedName)
            .delete();

        // Extract the first word from the new recipe name as the type
        List<String> words = _recipeNameController.text.split(' ');
        String newType = words.isNotEmpty ? words[0] : '';

        // Create a new document with the updated recipe name and type
        await FirebaseFirestore.instance
            .collection('Users')
            .doc(userEmail)
            .collection('Recipes')
            .doc(_recipeNameController.text)
            .set({
          'Ingredient': _ingredientsController.text,
          'Instruction': _instructionsController.text,
          'Favorite': oldDetails['Favorite'],
          'Timestamp': oldRecipeDoc['Timestamp'],
          'Type': newType, // Set the type based on the first word of the new recipe name
        });

        Navigator.pop(context); // Navigate back to the previous screen
        Navigator.pop(context); // Navigate back to the previous screen
      }
    } catch (error) {
      print("Error updating recipe: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Recipe'),
        backgroundColor: Colors.purple[100],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _recipeNameController,
                decoration: const InputDecoration(
                  labelText: 'Recipe Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16.0),
              TextField(
                controller: _ingredientsController,
                decoration: const InputDecoration(
                  labelText: 'Ingredients',
                  border: OutlineInputBorder(),
                ),
                maxLines: 5, // Allow multiple lines for ingredients
              ),
              const SizedBox(height: 16.0),
              TextField(
                controller: _instructionsController,
                decoration: const InputDecoration(
                  labelText: 'Instructions',
                  border: OutlineInputBorder(),
                ),
                maxLines: 8, // Allow multiple lines for instructions
              ),
              const SizedBox(height: 50),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple[100],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                ),
                onPressed: () {
                  editRecipe();
                },
                child: const Text('Edit Recipe'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
