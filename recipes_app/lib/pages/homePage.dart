import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:recipes_app/pages/collectionPage.dart';
import 'package:recipes_app/pages/groceriesPage.dart';
import 'package:recipes_app/pages/loginPage.dart';
import 'package:recipes_app/pages/searchPage.dart';
import 'package:recipes_app/pages/viewRecipe.dart';
import 'package:recipes_app/pages/newRecipe.dart';
import 'package:recipes_app/pages/favPage.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late String userName = '';

  @override
  void initState() {
    super.initState();
    fetchUserName();
  }

  Future<void> fetchUserName() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        String userEmail = user.email!;
        final userData =
        await FirebaseFirestore.instance.collection('Users').doc('$userEmail').get();
        setState(() {
          userName = userData['Display Name'];
        });
      }
    } catch (error) {
      print("Error fetching user data: $error");
    }
  }

  Future<void> _changeNameDialog() async {
    TextEditingController _newNameController = TextEditingController();

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Change Display Name'),
          content: TextField(
            controller: _newNameController,
            decoration: InputDecoration(labelText: 'New Display Name'),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                String newName = _newNameController.text.trim();
                if (newName.isNotEmpty) {
                  // Update the display name in Firestore
                  await updateDisplayName(newName);

                  // Update the displayed name in the UI
                  setState(() {
                    userName = newName;
                  });

                  Navigator.of(context).pop(); // Close the dialog
                }
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> updateDisplayName(String newName) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        String userEmail = user.email!;
        await FirebaseFirestore.instance
            .collection('Users')
            .doc('$userEmail')
            .update({'Display Name': newName});
      }
    } catch (error) {
      print("Error updating display name: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Recipes'),
        backgroundColor: Colors.purple[100],
      ),
      drawer: buildDrawer(), // Add drawer here
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('Users')
                  .doc(FirebaseAuth.instance.currentUser!.email)
                  .collection('Recipes')
                  .snapshots(),
              builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return Text('Something went wrong. Error: ${snapshot.error}');
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Text(
                      'No recipes found. Add a new recipe!',
                      style: TextStyle(fontSize: 16),
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    final DocumentSnapshot document = snapshot.data!.docs[index];
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
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple[100],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => NewRecipePage()),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 10.0),
                  child: Text('Add New Recipe'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Drawer buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.purple[100],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.restaurant_menu,
                  color: Colors.black,
                  size: 60,
                ),
                SizedBox(height: 10),
                Text(
                  userName.isNotEmpty ? 'Hello, $userName!' : 'Hello!',
                  style: TextStyle(fontSize: 18, color: Colors.black),
                ),
              ],
            ),
          ),
          const SizedBox(height: 5),
          ListTile(
            leading: Icon(Icons.favorite),
            title: Text(
              'F A V O R I T E S',
              style: TextStyle(fontSize: 18),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => FavoritePage()),
              );
            },
          ),
          const SizedBox(height: 5),
          const Divider(),
          const SizedBox(height: 5),
          ListTile(
            leading: Icon(Icons.collections_bookmark),
            title: Text(
              'C O L L E C T I O N',
              style: TextStyle(fontSize: 18),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CollectionPage()),
              );
            },
          ),
          const SizedBox(height: 5),
          const Divider(),
          const SizedBox(height: 5),
          ListTile(
            leading: Icon(Icons.local_grocery_store_rounded),
            title: Text(
              'G R O C E R I E S',
              style: TextStyle(fontSize: 18),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => GroceriesPage()),
              );
            },
          ),
          const SizedBox(height: 5),
          const Divider(),
          const SizedBox(height: 5),
          ListTile(
            leading: Icon(Icons.search),
            title: Text(
              'S E A R C H',
              style: TextStyle(fontSize: 18),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SearchPage()),
              );
            },
          ),
          const SizedBox(height: 5),
          const Divider(),
          const SizedBox(height: 5),
          ListTile(
            leading: Icon(Icons.person),
            title: Text(
              'C H A N G E  N A M E',
              style: TextStyle(fontSize: 18),
            ),
            onTap: () {
              _changeNameDialog();
            },
          ),
          const SizedBox(height: 5),
          const Divider(),
          const SizedBox(height: 5),
          ListTile(
            leading: Icon(Icons.logout),
            title: Text(
              'L O G  O U T',
              style: TextStyle(fontSize: 18),
            ),
            onTap: () async {
              await FirebaseAuth.instance.signOut(); // Perform Firebase logout

              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()),
              );
            },
          ),
        ],
      ),
    );
  }
}
