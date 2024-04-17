import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login_screen.dart';
import 'favorites_screen.dart';
import 'saved_lists_screen.dart'; // Import your SavedListsScreen here

class ProfileTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<DocumentSnapshot>>(
      future: _fetchLists(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          List<DocumentSnapshot> lists = snapshot.data ?? [];
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    // Navigate to the SavedListsScreen and pass the user's lists
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SavedListsScreen(lists: lists),
                      ),
                    
                    );
                  },
                  child: const Text('Saved Lists'),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Navigate to the Favorites screen
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => FavoritesScreen()),
                    );
                  },
                  child: const Text('Favorites'),
                  
                ),
            
                ElevatedButton(
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => LoginScreen()),
                    );
                  },
                  child: const Text('Logout')
                ),
              ],
            ),
          );
        }
      },
    );
  }

  Future<List<DocumentSnapshot>> _fetchLists() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('lists')
          .doc(user.uid)
          .collection('user_lists')
          .get();
      List<DocumentSnapshot> lists = querySnapshot.docs;
      print('Lists: $lists');
      return lists;
    } else {
      print('User is null');
      return [];
    }
  }
}
