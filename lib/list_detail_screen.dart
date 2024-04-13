import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ListDetailScreen extends StatelessWidget {
  final DocumentSnapshot list;

  const ListDetailScreen({Key? key, required this.list}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(list.id),
        backgroundColor: Color.fromRGBO(255,242,147,0.7)
      ),
      body: ListView(
        children: [
          ListTile(
            title: Text('Total: \$${list['total']}'),
          ),
          ListTile(
            title: Text('Items:'),
          ),
          ..._buildItemList(list['items']),
        ],
      ),
    );
  }

  List<Widget> _buildItemList(List<dynamic> items) {
    return items.map((item) {
      return ListTile(
        title: Text(item['selectedItem']),
        subtitle: Text('${item['selectedStore']} - \$${item['price']}'),
      );
    }).toList();
  }
}