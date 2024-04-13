import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Class to represent an item in the ListView
class ShoppingListItem {
  final String selectedItem;
  final String selectedStore;
  final double price;

  ShoppingListItem({
    required this.selectedItem,
    required this.selectedStore,
    required this.price,
  });
}

class HomeTab extends StatefulWidget {
  @override
  _HomeTabState createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  List<String> storeOptions = ['']; // Added blank option
  String selectedStore1 = '';
  String selectedStore2 = '';
  String selectedItem = '';
  List<ShoppingListItem> items1 = []; // List to store ShoppingListItem objects for store 1
  List<ShoppingListItem> items2 = []; // List to store ShoppingListItem objects for store 2
  double total1 = 0.0; // Total for store 1
  double total2 = 0.0; // Total for store 2
  Set<String> allFoodItems = {
    'milk',
    'bread',
    'eggs',
    'orange juice',
    'chicken',
    'broccoli',
    'lettuce',
    'bananas',
    'apples',
    'oranges',
    'flour',
    'sugar',
    'ice cream',
    'soda',
    'beer',
    'wine',
    'chips',
  };

  @override
  void initState() {
    super.initState();
    fetchStoreNames();
  }

  void fetchStoreNames() async {
    QuerySnapshot storeSnapshot =
        await FirebaseFirestore.instance.collection('stores').get();
    List<Map<String, dynamic>> stores = [];
    storeSnapshot.docs.forEach((doc) {
      Map<String, dynamic> store = {
        'id': doc.id,
        'name': doc.id,
        'data': doc.data(),
      };
      stores.add(store);
    });
    setState(() {
      storeOptions.addAll(stores.map((store) => store['name'] as String));
    });
  }

Future<double> getPrice(String store, String item) async {
  try {
    DocumentSnapshot storeSnapshot = await FirebaseFirestore.instance
        .collection('stores')
        .doc(store)
        .get();

    if (storeSnapshot.exists) {
      Map<String, dynamic>? data =
          storeSnapshot.data() as Map<String, dynamic>?;

      if (data != null && data.containsKey('items')) {
        Map<String, dynamic> items = data['items'];

        if (items.containsKey(item)) {
          return items[item]['price'].toDouble();
        }
      }
      print('Price not found for $item in $store');
      return 0.0;
    }
    return 0.0;
  } catch (e) {
    print('Error getting price: $e');
    return 0.0;
  }
}

  void addItemToList1() async {
    if (selectedStore1.isNotEmpty && selectedItem.isNotEmpty) {
      double price = await getPrice(selectedStore1, selectedItem);
      if (price != 0.0) {
        setState(() {
          items1.add(ShoppingListItem(
            selectedItem: selectedItem,
            selectedStore: selectedStore1,
            price: price,
          ));
          total1 += price;
        });
      } else {
        print('Price not found for $selectedItem in $selectedStore1');
      }
    }
  }

  void addItemToList2() async {
    if (selectedStore2.isNotEmpty && selectedItem.isNotEmpty) {
      double price = await getPrice(selectedStore2, selectedItem);
      if (price != 0.0) {
        setState(() {
          items2.add(ShoppingListItem(
            selectedItem: selectedItem,
            selectedStore: selectedStore2,
            price: price,
          ));
          total2 += price;
        });
      } else {
        print('Price not found for $selectedItem in $selectedStore2');
      }
    }
  }

  void clearList(int listNumber) {
    setState(() {
      if (listNumber == 1) {
        items1.clear();
        total1 = 0.0;
      } else if (listNumber == 2) {
        items2.clear();
        total2 = 0.0;
      }
    });
  }

  Future<void> saveListToFirestore(int listNumber) async {
    List<ShoppingListItem> itemsToSave = [];
    double totalToSave = 0.0;

    if (listNumber == 1) {
      itemsToSave = List.from(items1);
      totalToSave = total1;
    } else if (listNumber == 2) {
      itemsToSave = List.from(items2);
      totalToSave = total2;
    }

    String? listName = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        TextEditingController controller = TextEditingController();
        return AlertDialog(
          title: Text('Save List'),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(labelText: 'Enter list name'),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  Navigator.pop(context, controller.text);
                }
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );

    if (listName != null) {
      // Save list to Firestore
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        CollectionReference listsRef = FirebaseFirestore.instance.collection('lists');
        await listsRef.doc(user.uid).collection('user_lists').doc(listName).set({
          'items': itemsToSave.map((item) => {
            'selectedItem': item.selectedItem,
            'selectedStore': item.selectedStore,
            'price': item.price,
          }).toList(),
          'total': totalToSave,
        });

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('List saved successfully'),
          duration: Duration(seconds: 2),
        ));
      } else {
        // Handle case where user is null
        print('User is null');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Shopping List')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              DropdownButton<String>(
                value: selectedStore1.isNotEmpty ? selectedStore1 : null,
                onChanged: (String? newValue) {
                  setState(() {
                    selectedStore1 = newValue!;
                  });
                },
                items: storeOptions.map<DropdownMenuItem<String>>((String? value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value ?? 'Blank'),
                    key: Key(value ?? 'Blank'),
                  );
                }).toList(),
              ),
              DropdownButton<String>(
                value: selectedItem.isNotEmpty ? selectedItem : null,
                onChanged: (String? newValue) {
                  setState(() {
                    selectedItem = newValue!;
                  });
                },
                items: allFoodItems.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                    key: Key(value),
                  );
                }).toList(),
              ),
               DropdownButton<String>(
                value: selectedStore2.isNotEmpty ? selectedStore2 : null,
                onChanged: (String? newValue) {
                  setState(() {
                    selectedStore2 = newValue!;
                  });
                },
                items: storeOptions.map<DropdownMenuItem<String>>((String? value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value ?? 'Blank'),
                    key: Key(value ?? 'Blank'),
                  );
                }).toList(),
              ),
            ],
          ),
          Flexible(
            child: Row(
              children: [
                Expanded(
                  child: ListView.builder(
                    scrollDirection: Axis.vertical,
                    itemCount: items1.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text('${items1[index].selectedItem} - ${items1[index].selectedStore}: \$${items1[index].price}'),
                      );
                    },
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    scrollDirection: Axis.vertical,
                    itemCount: items2.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text('${items2[index].selectedItem} - ${items2[index].selectedStore}: \$${items2[index].price}'),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
           Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: addItemToList1,
                child: Text('+'),
              ),
              ElevatedButton(
                onPressed: addItemToList2,
                child: Text('+'),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () => clearList(1),
                child: Text('Clear'),
              ),
              ElevatedButton(
                onPressed: () => clearList(2),
                child: Text('Clear'),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () => saveListToFirestore(1),
                child: Text('Save'),
              ),
              ElevatedButton(
                onPressed: () => saveListToFirestore(2),
                child: Text('Save'),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text('Total: \$${total1.toStringAsFixed(2)}'),
              Text('Total: \$${total2.toStringAsFixed(2)}'),
            ],
          ),
        ],
      ),
    );
  }
}
