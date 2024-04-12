import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeTab extends StatefulWidget {
  @override
  _HomeTabState createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  List<String> storeOptions = [];
  String selectedStore1 = '';
  String selectedStore2 = '';
  String selectedItem = '';
  List<double> prices1 = [];
  List<double> prices2 = [];
  List<double> totals = [0.0, 0.0];
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
  List<String> storeFoodItems = [];

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
      // Extract food items from each store
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      data['items'].keys.forEach((key) {
        allFoodItems.add(key);
        storeFoodItems.add('${doc.id}-$key');
      });
    });
    setState(() {
      storeOptions = stores.map((store) => store['name'] as String).toList();
    });
  }

Future<double> getPrice(String store, String item) async {
  try {
    // Query the specified store document
    DocumentSnapshot storeSnapshot = await FirebaseFirestore.instance
        .collection('stores')
        .doc(store)
        .get();

    // If the store document exists, search for the item within the "items" object
    if (storeSnapshot.exists) {
      // Cast the data to the expected type
      Map<String, dynamic>? data = storeSnapshot.data() as Map<String, dynamic>?;

      // Check if data is not null and contains the "items" field
      if (data != null && data.containsKey('items')) {
        Map<String, dynamic> items = data['items'];

        // Search for the item in the "items" object
        if (items.containsKey(item)) {
          // Convert the item price to double before returning
          return items[item].toDouble();
        }
      }
      print('Price not found for $item in $store');
      return 0.0;
    }
    // Return a default value if the store document does not exist
    return 0.0;
  } catch (e) {
    print('Error getting price: $e');
    return 0.0; // or any default value you prefer
  }
}


  void addItem() async {
    if (selectedStore1.isNotEmpty && selectedItem.isNotEmpty) {
      double price = await getPrice(selectedStore1, selectedItem);
      if (price != 0.0) {
        setState(() {
          int index = prices1.indexWhere((element) => element == 0);
          if (index != -1) {
            prices1[index] = price;
          } else {
            prices1.add(price);
          }
          totals[0] = prices1.fold(0, (sum, price) => sum + price);
        });
      } else {
        print('Price not found for $selectedItem in $selectedStore1');
      }
    }

    if (selectedStore2.isNotEmpty && selectedItem.isNotEmpty) {
      double price = await getPrice(selectedStore2, selectedItem);
      if (price != 0.0) {
        setState(() {
          int index = prices2.indexWhere((element) => element == 0);
          if (index != -1) {
            prices2[index] = price;
          } else {
            prices2.add(price);
          }
          totals[1] = prices2.fold(0, (sum, price) => sum + price);
        });
      } else {
        print('Price not found for $selectedItem in $selectedStore2');
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
                items: storeOptions.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                    key: Key(value),
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
                items: storeOptions.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                    key: Key(value),
                  );
                }).toList(),
              ),
            ],
          ),
          ElevatedButton(
            onPressed: addItem,
            child: Text('Add'),
          ),
          Flexible(
            child: Row(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: prices1.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text('\$${prices1[index]}'),
                      );
                    },
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: prices2.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text('\$${prices2[index]}'),
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
              Text('Total: \$${totals[0]}'),
              Text('Total: \$${totals[1]}'),
            ],
          ),
        ],
      ),
    );
  }
}
