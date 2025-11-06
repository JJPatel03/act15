import 'package:flutter/material.dart';
import 'firestore_service.dart';
import 'item.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final firestoreService = FirestoreService();

    return Scaffold(
      appBar: AppBar(title: const Text('Inventory Dashboard')),
      body: StreamBuilder<List<Item>>(
        stream: firestoreService.getItemsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final items = snapshot.data ?? [];
          final totalItems = items.length;
          final totalValue = items.fold<double>(
              0, (sum, item) => sum + (item.price * item.quantity));
          final outOfStock =
              items.where((item) => item.quantity == 0).toList();

          return Padding(
            padding: const EdgeInsets.all(16),
            child: ListView(
              children: [
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.inventory),
                    title: const Text('Total Items'),
                    trailing: Text('$totalItems'),
                  ),
                ),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.monetization_on),
                    title: const Text('Total Inventory Value'),
                    trailing: Text('\$${totalValue.toStringAsFixed(2)}'),
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Out of Stock Items:',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                if (outOfStock.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('No items are out of stock.'),
                  )
                else
                  ...outOfStock.map((item) => ListTile(
                        title: Text(item.name),
                        subtitle: Text(item.category),
                      )),
              ],
            ),
          );
        },
      ),
    );
  }
}
