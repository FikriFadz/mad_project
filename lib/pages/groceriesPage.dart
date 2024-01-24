import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class GroceriesPage extends StatefulWidget {
  const GroceriesPage({super.key});

  @override
  State<GroceriesPage> createState() => _GroceriesPageState();
}

class _GroceriesPageState extends State<GroceriesPage> {
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
        .collection('Shopping')
        .snapshots();
  }

  // Function to update quantity in Firestore
  Future<void> _updateQuantity(String groceriesName, int newQuantity) async {
    await FirebaseFirestore.instance
        .collection('Users')
        .doc(userEmail)
        .collection('Shopping')
        .doc(groceriesName)
        .update({'Quantity': newQuantity});
  }

  // Function to delete item from Firestore
  Future<void> _deleteItem(String groceriesName) async {
    await FirebaseFirestore.instance
        .collection('Users')
        .doc(userEmail)
        .collection('Shopping')
        .doc(groceriesName)
        .delete();
  }

  // Function to add a new item to Firestore
  Future<void> _addNewItem(String groceriesName, int quantity) async {
    await FirebaseFirestore.instance
        .collection('Users')
        .doc(userEmail)
        .collection('Shopping')
        .doc(groceriesName)
        .set({
      'Quantity': quantity,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Groceries'),
        backgroundColor: Colors.purple[100],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _itemsStream,
              builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return Text('Something went wrong. Error: ${snapshot.hasError}');
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Text(
                      'No groceries found. Add new groceries!',
                      style: TextStyle(fontSize: 16),
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    final DocumentSnapshot document = snapshot.data!.docs[index];
                    final groceriesName = document.id;
                    int quantity = document['Quantity'] as int; // Replace 'quantity' with your actual field name

                    return ListTile(
                      leading: Icon(Icons.local_grocery_store_sharp),
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(groceriesName),
                          Text('Quantity: $quantity'),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.remove),
                            onPressed: () {
                              if (quantity > 0) {
                                quantity--;
                                _updateQuantity(groceriesName, quantity);
                              }
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.add),
                            onPressed: () {
                              quantity++;
                              _updateQuantity(groceriesName, quantity);
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () {
                              _deleteItem(groceriesName);
                            },
                          ),
                        ],
                      ),
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
                  _showAddGroceriesDialog(context);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 10.0),
                  child: Text('Add Groceries'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Function to show an alert dialog for adding groceries and quantity
  Future<void> _showAddGroceriesDialog(BuildContext context) async {
    String groceriesName = '';
    int quantity = 0;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Groceries'),
          contentPadding: const EdgeInsets.all(16.0),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(labelText: 'Groceries Name'),
                onChanged: (value) {
                  groceriesName = value;
                },
              ),
              SizedBox(height: 10),
              TextField(
                decoration: InputDecoration(labelText: 'Quantity'),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  quantity = int.tryParse(value) ?? 0;
                },
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                _addNewItem(groceriesName, quantity);
                Navigator.of(context).pop();
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

}
