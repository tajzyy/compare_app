import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FavoritesScreen extends StatefulWidget {
  @override
  _FavoritesScreenState createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  late Future<List<String>> _favoritesFuture;

  @override
  void initState() {
    super.initState();
    _favoritesFuture = _fetchFavorites();
  }

  Future<List<String>> _fetchFavorites() async {
    // Replace this with your own logic to fetch user's favorite items from Firestore
    // For demonstration purposes, returning a hardcoded list of favorite items
    return Future.delayed(Duration(seconds: 2), () => ['Item 1', 'Item 2', 'Item 3']);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Favorites'),
        backgroundColor: Color.fromRGBO(255,242,147,0.7)
      ),
      body: FutureBuilder<List<String>>(
        future: _favoritesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            List<String> favorites = snapshot.data ?? [];
            if (favorites.isEmpty) {
              return Center(child: Text('No favorites found.'));
            } else {
              return ListView.builder(
                itemCount: favorites.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(favorites[index]),
                    // Implement onTap to navigate to the detail screen of the selected favorite item
                    onTap: () {
                      // Replace this with navigation logic to detail screen
                    },
                  );
                },
              );
            }
          }
        },
      ),
    );
  }
}
