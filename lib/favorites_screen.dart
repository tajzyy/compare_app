import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

enum SearchType {
  Store,
  Food,
}

class FavoritesScreen extends StatefulWidget {

  @override
  _FavoritesScreenState createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  late Future<List<Map<String, dynamic>>> _favoritesFuture;
  SearchType _searchType = SearchType.Store;
  List<Map<String, dynamic>> _listResults = [];

  @override
  void initState() {
    super.initState();
    _favoritesFuture = _fetchFavorites();
  }

  Future<List<Map<String, dynamic>>> _fetchFavorites() async {
    // Replace this with your own logic to fetch user's favorite items from Firestore
    // For demonstration purposes, returning a hardcoded list of favorite items
    //line 19 in saved_lists_screen
    _switchList();
    return Future.delayed(const Duration(seconds: 5), () => _listResults);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorites'),
        backgroundColor: const Color.fromRGBO(216,230,235,0.7),
        actions: [DropdownButton<SearchType>(
                  value: _searchType,
                  onChanged: (value) {
                    setState(() {
                      _searchType = value!;
                      // _listResults.clear();
                      _switchList();
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
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
      future: null,
      initialData: [],
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          return ListView.builder(
            itemCount: _listResults.length,
            itemBuilder: (context, index) {
              var result = _listResults[index];
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
                        children: result['featuredDiscounts']?.map<Widget>((discount) {
                          return Text(discount);
                        }).toList(),
                      ),
                    ),
                    const Divider(),
                    ListTile(
                      title: const Text('Item Prices:'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: result['itemPrices']?.map<Widget>((item) {
                          return Text('${item['name']}: \$${item['price']}');
                        }).toList(),
                      ),
                    ),
                    const Divider(),
                    ListTile(
                      title: const Text('Total Price:'),
                      subtitle: Text('\$${result['totalPrice']?.toStringAsFixed(2)}'),
                    ),
                  ],
                ),
              )
              : Card(
                margin: const EdgeInsets.symmetric(vertical: 4),
                child: ExpansionTile(
                  leading: const Icon(Icons.store),
                  title: Text(result['name']),
                  subtitle: Text('${result['featuredDiscounts'].length} Discounts'),
                  children: [
                    ListTile(
                      title: const Text('Featured Discounts:'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: result['featuredDiscounts']?.map<Widget>((discount) {
                          return Text(discount);
                        }).toList(),
                      ),
                    ),
                    const Divider(),
                    ListTile(
                      title: const Text('Item Prices:'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: result['itemPrices']?.map<Widget>((item) {
                          return Text('${item['name']}: \$${item['price']}');
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        }
      },
    ),
    );
  }

  void _switchList() async {
    CollectionReference collectionRef = FirebaseFirestore.instance
              .collection(_searchType == SearchType.Store?'stores':'foods');
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) { // if user exists
      DocumentReference userDoc = FirebaseFirestore.instance
          .collection('lists')
          .doc(user.uid);
      print('User path: ${userDoc.path}');
      DocumentSnapshot userDocSnap = await userDoc.get();
      print(userDocSnap.data());
      String favList = _searchType == SearchType.Store? 'fav_stores': 'fav_foods';
      if(userDocSnap.data() != null && (userDocSnap.data() as Map<String, dynamic>?)![favList] != null){ // document is null/empty
        (userDocSnap.data() as Map<String, dynamic>?)![favList].forEach((itemName) async{
          DocumentSnapshot docSnapshot = await collectionRef.doc(itemName).get();
          if (docSnapshot.exists){
            Map<String, dynamic>? itemData = docSnapshot.data() as Map<String, dynamic>?;
            if(itemData != null){
              setState(() {
                _listResults.clear();
                _listResults.add(_searchType == SearchType.Store?
                  {
                    'name': itemName.toLowerCase(),
                    'rank': itemData['rank'],
                    'featuredDiscounts': _extractFeaturedStoreDiscounts(itemData['items']),
                    'itemPrices': _extractItemPrices(itemData['items']),
                    'totalPrice': _calculateTotalPrice(itemData['items']),
                  }:{
                  'name': itemName.toLowerCase(),                
                  'featuredDiscounts': _extractFeaturedItemDiscounts(itemData['items']),
                  'itemPrices': _extractStorePrices(itemData['items']),
                  }
                );
              });
              return;
            }
          } 
        });
      }
    }
    // If document doesn't exist or items are missing, clear search results
    setState(() {
      _listResults.clear();
    });
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
}
