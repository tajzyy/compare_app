import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

enum SearchType {
  Store,
  Food,
}

class SearchTab extends StatefulWidget {
  @override
  _SearchTabState createState() => _SearchTabState();
}

class _SearchTabState extends State<SearchTab> {
  TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];
  SearchType _searchType = SearchType.Store;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 56,
          child: Container(
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 187, 209, 251),
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                DropdownButton<SearchType>(
                  value: _searchType,
                  onChanged: (value) {
                    setState(() {
                      _searchType = value!;
                      _searchController.clear();
                      _searchResults.clear();
                    });
                  },
                  items: [
                    const DropdownMenuItem(
                      value: SearchType.Store,
                      child: Text('Store'),
                    ),
                    const DropdownMenuItem(
                      value: SearchType.Food,
                      child: Text('Food'),
                    ),
                  ],
                ),
                const SizedBox(width: 8.0),
                Expanded(
                  child: TextFormField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      labelText: _searchType == SearchType.Store ? 'Search for a store' : 'Search for food',
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.search),
                        onPressed: () {
                          _search();
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: Scrollbar(
            child: ListView.builder(
              itemCount: _searchResults.length,
              itemBuilder: (context, index) {
                var result = _searchResults[index];
                return _searchType == SearchType.Store? Card(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  child: ExpansionTile(
                    leading: const Icon(Icons.store),
                    title: Text(result['name']),
                    subtitle: Text('Price Rank: ${result['rank']}'),
                    children: [
                      ListTile(
                        title: const Text('Featured Discounts:'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: result['featuredDiscounts'].map<Widget>((discount) {
                            return Text(discount);
                          }).toList(),
                        ),
                      ),
                      const Divider(),
                      ListTile(
                        title: const Text('Item Prices:'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: result['itemPrices'].map<Widget>((item) {
                            return Text('${item['name']}: \$${item['price']}');
                          }).toList(),
                        ),
                      ),
                      const Divider(),
                      ListTile(
                        title: const Text('Total Price:'),
                        subtitle: Text('\$${result['totalPrice'].toStringAsFixed(2)}'),
                      ),
                      TextButton(
                        onPressed: () {
                          _toggleFavorite(result['name']);
                        },
                        child: const Text('Toggle Favorite'),
                      ),
                    ],
                  ),
                )
                : Card(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  child: ExpansionTile(
                    leading: const Icon(Icons.fastfood),
                    title: Text(result['name']),
                    subtitle: Text('${result['featuredDiscounts'].length} Discounts'),
                    children: [
                      ListTile(
                        title: const Text('Featured Discounts:'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: result['featuredDiscounts'].map<Widget>((discount) {
                            return Text(discount);
                          }).toList(),
                        ),
                      ),
                      const Divider(),
                      ListTile(
                        title: const Text('Item Prices:'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: result['storePrices'].map<Widget>((item) {
                            return Text('${item['name']}: \$${item['price']}');
                          }).toList(),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          _toggleFavorite(result['name']);
                        },
                        child: const Text('Toggle Favorite'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  void _search() async {
    String searchTerm = _searchController.text.trim().toLowerCase();
    print('Search term: $searchTerm'); // Print the search term
    if (searchTerm.isNotEmpty) {
      CollectionReference collectionRef = _searchType == SearchType.Store
          ? FirebaseFirestore.instance.collection('stores')
          : FirebaseFirestore.instance.collection('foods');
      DocumentSnapshot docSnapshot = await collectionRef.doc(searchTerm).get();
      if (docSnapshot.exists) {
        var searchData = docSnapshot.data() as Map<String, dynamic>?; // Explicitly cast to Map<String, dynamic> or null
        if (searchData != null) {
          // Add your search result processing logic here
          // For now, just print the data
          print('Search data: $searchData');
          setState(() {
            _searchResults.clear();
            if(_searchType == SearchType.Store){
              _searchResults.add({
                'name': searchTerm.toLowerCase(),
                'rank': searchData['rank'],
                'featuredDiscounts': _extractFeaturedStoreDiscounts(searchData['items']),
                'itemPrices': _extractItemPrices(searchData['items']),
                'totalPrice': _calculateTotalPrice(searchData['items']),
              });
            } else {
              _searchResults.add({
                'name': searchTerm.toLowerCase(),                
                'featuredDiscounts': _extractFeaturedItemDiscounts(searchData['items']),
                'storePrices': _extractStorePrices(searchData['items']),
              });
            }
          });
          return;
        }
      }
      // If document doesn't exist or items are missing, clear search results
      setState(() {
        _searchResults.clear();
      });
    }
  }

  List<String> _extractFeaturedStoreDiscounts(Map<String, dynamic> items) {
    List<String> featuredDiscounts = [];
    items.forEach((itemName, itemData) {
      if (itemData['price'] != null && itemData['discount'] != null) {
        int discountPercentage = (itemData['discount'] * 100).toInt();
        featuredDiscounts.add('$itemName - $discountPercentage%');
      }
    });
    return featuredDiscounts;
  }

  List<String> _extractFeaturedItemDiscounts(Map<String, dynamic> stores) {
    List<String> featuredDiscounts = [];
    stores.forEach((itemName, itemData) {
      if (itemData['price'] != null && itemData['discount'] != null) {
        int discountPercentage = (itemData['discount'] * 100).toInt();
        featuredDiscounts.add('$itemName - $discountPercentage%');
      }
    });
    return featuredDiscounts;
  }

  List<Map<String, dynamic>> _extractItemPrices(Map<String, dynamic> items) {
    List<Map<String, dynamic>> itemPrices = [];
    items.forEach((itemName, itemData) {
      if (itemData['price'] != null) {
        double price = (itemData['price'] as num).toDouble();
        itemPrices.add({'name': itemName, 'price': price});
      }
    });
    return itemPrices;
  }

  List<Map<String, dynamic>> _extractStorePrices(Map<String, dynamic> stores) {
    List<Map<String, dynamic>> itemPrices = [];
    stores.forEach((storeName, storeData) {
      if (storeData['price'] != null) {
        double price = (storeData['price'] as num).toDouble();
        itemPrices.add({'name': storeName, 'price': price});
      }
    });
    return itemPrices;
  }

  double _calculateTotalPrice(Map<String, dynamic> items) {
    double totalPrice = 0.0;
    items.forEach((itemName, itemData) {
      if (itemData['price'] != null) {
        double price = (itemData['price'] as num).toDouble();
        totalPrice += price;
      }
    });
    return totalPrice;
  }

  void _toggleFavorite(String item) async {
    print('Favorite Thing: $item'); // Print the item name
    item = item.toLowerCase();
    CollectionReference collectionRef = _searchType == SearchType.Store
        ? FirebaseFirestore.instance.collection('stores')
        : FirebaseFirestore.instance.collection('foods');
    DocumentSnapshot docSnapshot = await collectionRef.doc(item).get();
    print('exists ${docSnapshot.exists.toString()}');
    if (docSnapshot.exists) {
      var searchData = docSnapshot.data() as Map<String, dynamic>?; // Explicitly cast to Map<String, dynamic> or null
      if (searchData != null) {
        print('Search data: $searchData');
        // Add thing to favorites list
        User? user = FirebaseAuth.instance.currentUser;
        if (user != null) { // if user exists
          DocumentReference userDoc = FirebaseFirestore.instance
              .collection('lists')
              .doc(user.uid);
          print('User path: ${userDoc.path}');
          DocumentSnapshot userDocSnap = await userDoc.get();
          print(userDocSnap.data());
          String favList = _searchType == SearchType.Store? 'fav_stores': 'fav_foods';
          if(userDocSnap.data() == null && (userDocSnap.data() as Map<String, dynamic>?)![favList] == null){ // document is null/empty
            userDoc.set(Map<String, dynamic>
              .from({
                favList: FieldValue.arrayUnion([item])
              })
            );
          }else if((userDocSnap.data() as Map<String, dynamic>?)![favList] != null && (userDocSnap.data() as Map<String, dynamic>?)![favList]!.contains(item)) { // if item is already in list
            // remove item from list
            userDoc.update(Map<String, dynamic>
              .from({
                favList: FieldValue.arrayRemove([item])
              })
            );
          } else { // item is not in the list
            // add item to list
            userDoc.update(Map<String, dynamic>
              .from({
                favList: FieldValue.arrayUnion([item])
              })
            );
          }
        }
        return;
      }
    }
    // If document doesn't exist or items are missing, clear search results
    setState(() {
      _searchResults.clear();
    });
  }
}
