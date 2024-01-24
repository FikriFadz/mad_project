import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:recipes_app/pages/viewRecipe.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  String _searchQuery = '';
  late User user;
  late String userEmail;
  late CollectionReference _recipesCollection;

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser!;
    userEmail = user.email!;
    _recipesCollection = FirebaseFirestore.instance
        .collection('Users')
        .doc(userEmail)
        .collection('Recipes');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          onChanged: (value) {
            setState(() {
              _searchQuery = value.trim();
            });
          },
          decoration: InputDecoration(
            hintText: 'Search for Recipes',
            hintStyle: TextStyle(color: Colors.white54),
            border: InputBorder.none,
          ),
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.purple[100],
      ),
      body: _buildSearchResults(),
    );
  }

  Widget _buildSearchResults() {
    Query query = _recipesCollection;

    if (_searchQuery.isNotEmpty) {
      // Filter based on recipe name with case sensitivity
      query = query.where(FieldPath.documentId, isGreaterThanOrEqualTo: _searchQuery)
          .where(FieldPath.documentId, isLessThan: _searchQuery + '\uf8ff');
    }

    return StreamBuilder<QuerySnapshot>(
      stream: query.snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text('Something went wrong. Error: ${snapshot.error}');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        List<DocumentSnapshot> filteredDocs = snapshot.data!.docs
            .where((document) => document.id.contains(_searchQuery))
            .toList();

        if (filteredDocs.isEmpty) {
          return Center(
            child: Text(
              'No recipes found.',
              style: TextStyle(fontSize: 16),
            ),
          );
        }

        return ListView.builder(
          itemCount: filteredDocs.length,
          itemBuilder: (context, index) {
            final DocumentSnapshot document = filteredDocs[index];
            final recipeName = document.id; // Use document.id to get the document ID

            return ListTile(
              title: Text(recipeName),
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
    );
  }
}
