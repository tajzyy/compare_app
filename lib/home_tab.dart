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
            onPressed: null,
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
                        title: Text('Price: \$${prices1[index]}'),
                      );
                    },
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: prices2.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text('Price: \$${prices2[index]}'),
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
// void addItem() {
//   if (selectedStore1.isNotEmpty && selectedItem.isNotEmpty) {
//     // Check if the selected item already exists in the prices1 list
//     int index = prices1.indexWhere((element) => element == 0);
//     if (index != -1) {
//       setState(() {
//         prices1[index] = getPrice(selectedStore1, selectedItem);
//         totals[0] = prices1.fold(0, (sum, price) => sum + price);
//       });
//     } else {
//       setState(() {
//         prices1.add(getPrice(selectedStore1, selectedItem));
//         totals[0] = prices1.fold(0, (sum, price) => sum + price);
//       });
//     }
//   }
//   if (selectedStore2.isNotEmpty && selectedItem.isNotEmpty) {
//     // Check if the selected item already exists in the prices2 list
//     int index = prices2.indexWhere((element) => element == 0);
//     if (index != -1) {
//       setState(() {
//         prices2[index] = getPrice(selectedStore2, selectedItem);
//         totals[1] = prices2.fold(0, (sum, price) => sum + price);
//       });
//     } else {
//       setState(() {
//         prices2.add(getPrice(selectedStore2, selectedItem));
//         totals[1] = prices2.fold(0, (sum, price) => sum + price);
//       });
//     }
//   }
// }

// double getPrice(String store, String item) {
//   // Use the document ID as the store name and the food item name as the value
//   QuerySnapshot itemSnapshot = FirebaseFirestore.instance
//       .collection('stores')
//       .doc(store)
//       .collection('items')
//       .where('name', isEqualTo: item.split('-').last)
//       .get();
//   return itemSnapshot.docs.first['price'];
// }
