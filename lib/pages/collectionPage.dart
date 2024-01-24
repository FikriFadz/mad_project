import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:recipes_app/pages/viewRecipe.dart';

class CollectionPage extends StatefulWidget {
  const CollectionPage({super.key});

  @override
  State<CollectionPage> createState() => _CollectionPageState();
}

class _CollectionPageState extends State<CollectionPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Collection'),
        backgroundColor: Colors.purple[100],
      ),
      body: _buildCollectionList(),
    );
  }

  Widget _buildCollectionList() {
    // Get the current user's email
    String userEmail = FirebaseAuth.instance.currentUser!.email!;

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('Users')
          .doc(userEmail)
          .collection('Recipes')
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text('Something went wrong. Error: ${snapshot.error}');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final List<DocumentSnapshot> recipes = snapshot.data!.docs;

        if (recipes.isEmpty) {
          return Center(
            child: Text(
              'No recipes found.',
              style: TextStyle(fontSize: 16),
            ),
          );
        }

        // Sort recipes based on recipe type (case-insensitive)
        recipes.sort((a, b) {
          final String typeA = (a['Type'] ?? '').toLowerCase();
          final String typeB = (b['Type'] ?? '').toLowerCase();
          return typeA.compareTo(typeB);
        });

        return ListView.builder(
          itemCount: recipes.length,
          itemBuilder: (context, index) {
            final DocumentSnapshot document = recipes[index];
            final String recipeName = document.id;
            final String recipeType = document['Type'] ?? '';

            // Check if this is the first item in the list or a new recipe type
            final bool isFirstItemOrNewType =
                index == 0 || (recipeType.toLowerCase() != (recipes[index - 1]['Type'] ?? '').toLowerCase());

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isFirstItemOrNewType)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0,vertical: 10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 1.0),
                            child: Text(
                              recipeType,
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        Divider(
                          color: Colors.black,
                          thickness: 1.0,
                        ),
                      ],
                    ),
                  ),
                ListTile(
                  title: Text(recipeName),
                  onTap: (){
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RecipeDetail(passedName: recipeName),
                      ),
                    );
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }
}
