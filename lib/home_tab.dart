import 'package:flutter/material.dart';

class HomeTab extends StatefulWidget {
  @override
  _HomeTabState createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  List<String> storeOptions = ['Store 1', 'Store 2', 'Store 3'];
  String selectedStore1 = 'Store 1';
  String selectedStore2 = 'Store 2';
  String selectedItem = 'Item 1';

  List<double> prices1 = [];
  List<double> prices2 = [];
  List<double> totals = [0.0, 0.0];

  void addItem() {
    setState(() {
      prices1.add(getPrice(selectedStore1, selectedItem));
      prices2.add(getPrice(selectedStore2, selectedItem));
      totals[0] += getPrice(selectedStore1, selectedItem);
      totals[1] += getPrice(selectedStore2, selectedItem);
    });
  }

  double getPrice(String store, String item) {
    if (store == 'Store 1') {
      if (item == 'Item 1') {
        return 1.00;
      } else if (item == 'Item 2') {
        return 0.50;
      } else if (item == 'Item 3') {
        return 0.75;
      }
    } else if (store == 'Store 2') {
      if (item == 'Item 1') {
        return 1.50;
      } else if (item == 'Item 2') {
        return 0.75;
      } else if (item == 'Item 3') {
        return 1.00;
      }
    } else if (store == 'Store 3') {
      if (item == 'Item 1') {
        return 2.00;
      } else if (item == 'Item 2') {
        return 1.00;
      } else if (item == 'Item 3') {
        return 1.50;
      }
    }
    return 0.0;
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
                value: selectedStore1,
                onChanged: (String? newValue) {
                  setState(() {
                    selectedStore1 = newValue!;
                  });
                },
                items: storeOptions.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
              DropdownButton<String>(
                value: selectedItem,
                onChanged: (String? newValue) {
                  setState(() {
                    selectedItem = newValue!;
                  });
                },
                items: ['Item 1', 'Item 2', 'Item 3'].map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
              DropdownButton<String>(
                value: selectedStore2,
                onChanged: (String? newValue) {
                  setState(() {
                    selectedStore2 = newValue!;
                  });
                },
                items: storeOptions.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
              ElevatedButton(
                onPressed: addItem,
                child: Text('Add'),
              ),
            ],
          ),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: prices1.length,
                    itemBuilder: (BuildContext context, int index) {
                      return ListTile(
                        title: Text('Price: \$${prices1[index]}'),
                      );
                    },
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: prices2.length,
                    itemBuilder: (BuildContext context, int index) {
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
