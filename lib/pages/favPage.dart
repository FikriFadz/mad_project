import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:recipes_app/pages/viewRecipe.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FavoritePage extends StatefulWidget {
  const FavoritePage({Key? key});

  @override
  State<FavoritePage> createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  late User user;
  late String userEmail;
  late Stream<QuerySnapshot> _itemsStream;

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser!;
    userEmail = user.email!;
    _itemsStream = FirebaseFirestore.instance
        .collection('Users')
        .doc(userEmail)
        .collection('Recipes')
        .where('Favorite', isEqualTo: true)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorite Recipe'),
        backgroundColor: Colors.purple[100],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _itemsStream,
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text('Something went wrong. Error: ${snapshot.hasError}');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final favoriteRecipes = snapshot.data!.docs;

          if (favoriteRecipes.isEmpty) {
            return Center(
              child: Text(
                'No favorite recipes found.',
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          return ListView.builder(
            itemCount: favoriteRecipes.length,
            itemBuilder: (context, index) {
              final DocumentSnapshot document = favoriteRecipes[index];
              final recipeName = document.id;
              return ListTile(
                leading: Icon(Icons.restaurant_menu),
                title: Text(recipeName),
                trailing: Icon(Icons.arrow_forward_ios),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RecipeDetail(passedName: recipeName),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
