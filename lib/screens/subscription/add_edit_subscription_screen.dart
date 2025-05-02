import 'package:flutter/material.dart';

class AddEditSubscriptionScreen extends StatefulWidget {
  const AddEditSubscriptionScreen({Key? key}) : super(key: key);

  @override
  _AddEditSubscriptionScreenState createState() =>
      _AddEditSubscriptionScreenState();
}

class _AddEditSubscriptionScreenState extends State<AddEditSubscriptionScreen> {
  final TextEditingController _folderNameController = TextEditingController();
  final TextEditingController _prixController = TextEditingController();
  final TextEditingController _billingPeriodController =
      TextEditingController();

  String? _selectedCategory;
  final List<String> _categories = [
    'Entertainment',
    'Utilities',
    'Education',
    'Health',
  ];

  @override
  void dispose() {
    _folderNameController.dispose();
    _prixController.dispose();
    _billingPeriodController.dispose();
    super.dispose();
  }

  void _saveSubscription() {
    // Retrieve input values
    final folderName = _folderNameController.text;
    final prix = _prixController.text;
    final billingPeriod = _billingPeriodController.text;
    final category = _selectedCategory;

    // Implement saving logic here
    print("Folder Name: \$folderName");
    print("Prix: \$prix");
    print("Billing Period: \$billingPeriod");
    print("Categorie: \$category");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add/Edit Subscription')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _folderNameController,
                decoration: const InputDecoration(
                  labelText: 'Folder Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _prixController,
                decoration: const InputDecoration(
                  labelText: 'Prix',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _billingPeriodController,
                decoration: const InputDecoration(
                  labelText: 'Billing Period',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Categorie',
                  border: OutlineInputBorder(),
                ),
                items:
                    _categories.map((String category) {
                      return DropdownMenuItem(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value;
                  });
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _saveSubscription,
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
