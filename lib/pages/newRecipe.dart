import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class NewRecipePage extends StatefulWidget {
  const NewRecipePage({Key? key});

  @override
  State<NewRecipePage> createState() => _NewRecipePageState();
}

class _NewRecipePageState extends State<NewRecipePage> {
  final _recipeNameController = TextEditingController();
  final _ingredientsController = TextEditingController();
  final _instructionsController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Recipe'),
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
                maxLines: null, // Allow multiple lines for ingredients
                keyboardType: TextInputType.multiline, // Adjust keyboard type
              ),
              const SizedBox(height: 16.0),
              TextField(
                controller: _instructionsController,
                decoration: const InputDecoration(
                  labelText: 'Instructions',
                  border: OutlineInputBorder(),
                ),
                maxLines: null, // Allow multiple lines for instructions
                keyboardType: TextInputType.multiline, // Adjust keyboard type
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
                  addRecipe();
                },
                child: const Text('Add Recipe'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> addRecipe() async {
    final recipeName = _recipeNameController.text;
    final ingredients = _ingredientsController.text;
    final instructions = _instructionsController.text;
    final firstWord = recipeName.split(' ').first;

    if (recipeName.isEmpty || ingredients.isEmpty || instructions.isEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Incomplete Recipe'),
          content: const Text('Please fill in all fields.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    try {
      // Get the current user
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        // Get the user's email
        String userEmail = user.email!;

        // Create a document reference using the user's email
        final userDocRef = FirebaseFirestore.instance.collection('Users').doc(userEmail);

        // Check if a recipe with the same name already exists under the user's email
        final existingRecipe = await userDocRef.collection('Recipes').doc(recipeName).get();

        if (existingRecipe.exists) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Duplicate Recipe Name'),
              content: const Text('A recipe with the same name already exists. Please choose a different name.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
          return;
        }

        // Create a subcollection reference under the user's email
        final recipeDocRef = userDocRef.collection('Recipes').doc(recipeName);

        await recipeDocRef.set({
          'Ingredient': ingredients,
          'Instruction': instructions,
          'Favorite': false,
          'Type': firstWord,
          'Timestamp': FieldValue.serverTimestamp(),
        });

        _recipeNameController.clear();
        _ingredientsController.clear();
        _instructionsController.clear();
        Navigator.pop(context);
      }
    } catch (error) {
      print("Error: $error");
    }
  }
}