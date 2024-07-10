import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/food_item.dart';
import '../providers/food_provider.dart';

class FoodListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Food Reminder App',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: Consumer<FoodProvider>(
                builder: (context, foodProvider, child) {
                  return ListView.builder(
                    itemCount: foodProvider.foodItems.length,
                    itemBuilder: (context, index) {
                      final item = foodProvider.foodItems[index];
                      return _buildFoodItemCard(context, item, foodProvider);
                    },
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: () => _showAddFoodItemDialog(context),
              child: Text('Add Food Item'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                textStyle: TextStyle(fontSize: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFoodItemCard(BuildContext context, FoodItem item, FoodProvider provider) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        contentPadding: EdgeInsets.all(16),
        leading: item.imageUrl != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(item.imageUrl!, width: 50, height: 50, fit: BoxFit.cover),
              )
            : Icon(Icons.fastfood, size: 50, color: Colors.orange),
        title: Text(
          item.name,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          'Expiring on: ${item.expiryDate.toString().split(' ')[0]}',
          style: TextStyle(color: Colors.redAccent),
        ),
        trailing: IconButton(
          icon: Icon(Icons.delete, color: Colors.red),
          onPressed: () => _removeFoodItem(context, provider, item),
        ),
        onTap: () => _pickImage(context, provider, item),
      ),
    );
  }

  void _showAddFoodItemDialog(BuildContext context) {
    String name = '';
    DateTime? expiryDate;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text('Add Food Item'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(labelText: 'Name', border: OutlineInputBorder()),
                onChanged: (value) {
                  name = value;
                },
              ),
              SizedBox(height: 20),
              TextButton(
                onPressed: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101),
                  );
                  if (pickedDate != null) {
                    expiryDate = pickedDate;
                  }
                },
                child: Text(
                  expiryDate == null ? 'Select Expiry Date' : 'Expiry Date: ${expiryDate.toString().split(' ')[0]}',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (name.isNotEmpty && expiryDate != null) {
                  Provider.of<FoodProvider>(context, listen: false).addFoodItem(
                    FoodItem(name: name, expiryDate: expiryDate!),
                  );
                  Navigator.of(context).pop();
                }
              },
              child: Text('Add', style: TextStyle(color: Colors.blue)),
            ),
          ],
        );
      },
    );
  }

  void _removeFoodItem(BuildContext context, FoodProvider provider, FoodItem item) {
    try {
      provider.removeFoodItem(item);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error removing item: $e')),
      );
    }
  }

  void _pickImage(BuildContext context, FoodProvider provider, FoodItem item) async {
    try {
      await provider.pickImage(item);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }
}
