import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'list_detail_screen.dart'; // Import your ListDetailScreen here

class SavedListsScreen extends StatelessWidget {
  final List<DocumentSnapshot> lists;

  SavedListsScreen({required this.lists});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Saved Lists'),
        backgroundColor: Color.fromRGBO(255,242,147,0.7)
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: lists.length,
              itemBuilder: (context, index) {
                return Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Color.fromRGBO(236, 243, 245, 1)),
                  ),
                  child: ListTile(
                    title: Text(lists[index].id),
                    subtitle: Text('Total: \$${lists[index]['total']}'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ListDetailScreen(list: lists[index]),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
