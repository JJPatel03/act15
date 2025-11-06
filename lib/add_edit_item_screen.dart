import 'package:flutter/material.dart';
import 'firestore_service.dart';
import 'item.dart';

class AddEditItemScreen extends StatefulWidget {
  final Item? item;
  const AddEditItemScreen({super.key, this.item});

  @override
  State<AddEditItemScreen> createState() => _AddEditItemScreenState();
}

class _AddEditItemScreenState extends State<AddEditItemScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _quantityController;
  late TextEditingController _priceController;
  late TextEditingController _categoryController;
  final FirestoreService _firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.item?.name ?? '');
    _quantityController =
        TextEditingController(text: widget.item?.quantity.toString() ?? '');
    _priceController =
        TextEditingController(text: widget.item?.price.toString() ?? '');
    _categoryController =
        TextEditingController(text: widget.item?.category ?? '');
  }

  void _saveItem() async {
    if (_formKey.currentState!.validate()) {
      final newItem = Item(
        id: widget.item?.id,
        name: _nameController.text,
        quantity: int.parse(_quantityController.text),
        price: double.parse(_priceController.text),
        category: _categoryController.text,
        createdAt: widget.item?.createdAt ?? DateTime.now(),
      );

      if (widget.item == null) {
        await _firestoreService.addItem(newItem);
      } else {
        await _firestoreService.updateItem(newItem);
      }
      Navigator.pop(context);
    }
  }

  void _deleteItem() async {
    if (widget.item != null) {
      await _firestoreService.deleteItem(widget.item!.id!);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.item != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Edit Item' : 'Add Item')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Item Name'),
                validator: (v) => v!.isEmpty ? 'Enter item name' : null,
              ),
              TextFormField(
                controller: _quantityController,
                decoration: const InputDecoration(labelText: 'Quantity'),
                keyboardType: TextInputType.number,
                validator: (v) =>
                    v!.isEmpty ? 'Enter quantity' : null,
              ),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty ? 'Enter price' : null,
              ),
              TextFormField(
                controller: _categoryController,
                decoration: const InputDecoration(labelText: 'Category'),
                validator: (v) => v!.isEmpty ? 'Enter category' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveItem,
                child: Text(isEditing ? 'Update' : 'Save'),
              ),
              if (isEditing)
                TextButton(
                  onPressed: _deleteItem,
                  child: const Text('Delete', style: TextStyle(color: Colors.red)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
