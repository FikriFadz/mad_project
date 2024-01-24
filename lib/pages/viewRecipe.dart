import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:recipes_app/pages/editRecipe.dart';

class RecipeDetail extends StatefulWidget {
  final String passedName;

  const RecipeDetail({Key? key, required this.passedName}) : super(key: key);

  @override
  State<RecipeDetail> createState() => _RecipeDetailState();
}

class _RecipeDetailState extends State<RecipeDetail> {
  late String recipeName = widget.passedName;
  String ingredientsText = '';
  String instructionText = '';
  bool Favorite = false;
  Timestamp? timestamp;

  @override
  void initState() {
    super.initState();
    fetchRecipeIngredient();
  }

  Future<void> fetchRecipeIngredient() async {
    try {
      // Get the current user
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        // Get the user's email
        String userEmail = user.email!;

        final recipeDoc = await FirebaseFirestore.instance
            .collection('Users')
            .doc(userEmail)
            .collection('Recipes')
            .doc(recipeName)
            .get();

        setState(() {
          ingredientsText = recipeDoc['Ingredient'] as String;
          instructionText = recipeDoc['Instruction'] as String;
          Favorite = recipeDoc['Favorite'] ?? false;
          timestamp = recipeDoc['Timestamp'] as Timestamp?;
        });
      }
    } catch (error) {
      print("Error fetching recipe: ${error}");
    }
  }

  Future<void> deleteRecipe() async {
    try {
      // Get the current user
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        // Get the user's email
        String userEmail = user.email!;

        await FirebaseFirestore.instance
            .collection('Users')
            .doc(userEmail)
            .collection('Recipes')
            .doc(recipeName)
            .delete();

        Navigator.pop(context);
      }
    } catch (error) {
      print("Error deleting recipe: $error");
    }
  }

  Future<void> toggleFavorite() async {
    setState(() {
      Favorite = !Favorite;
    });
    try {
      // Get the current user
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        // Get the user's email
        String userEmail = user.email!;

        await FirebaseFirestore.instance
            .collection('Users')
            .doc(userEmail)
            .collection('Recipes')
            .doc(recipeName)
            .update({'Favorite': Favorite});
      }
    } catch (error) {
      print("Error updating favorite status: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(recipeName),
            if (timestamp != null)
              Text(
                'Created: ${timestamp!.toDate().toString()}',
                style: TextStyle(fontSize: 12),
              ),
          ],
        ),
        backgroundColor: Colors.purple[100],
        actions: [
          IconButton(
            icon: Icon(
              Favorite ? Icons.favorite : Icons.favorite_border,
              color: Colors.white,
            ),
            onPressed: toggleFavorite,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Text(
                "Ingredient",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 15),
              Text(
                ingredientsText,
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 15),
              Text(
                "Instruction",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 15),
              Text(
                instructionText,
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple[100],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditRecipe(passedName: recipeName),
                        ),
                      );
                    },
                    child: Text('Edit this recipe'),
                  ),
                  SizedBox(width: 10),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[200],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                    ),
                    onPressed: deleteRecipe,
                    child: Text(
                      'Delete this recipe',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
