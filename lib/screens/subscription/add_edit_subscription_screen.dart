import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:trucky/models/subscription.dart';
import 'package:trucky/services/subscription_service.dart';

class AddEditSubscriptionScreen extends StatefulWidget {
  final String userId; // إرسال userId مع الشاشة

  const AddEditSubscriptionScreen({super.key, required this.userId});

  @override
  State<AddEditSubscriptionScreen> createState() =>
      _AddEditSubscriptionScreenState();
}

class _AddEditSubscriptionScreenState extends State<AddEditSubscriptionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomServiceController = TextEditingController();
  final _prixController = TextEditingController();
  String? _selectedDuration;
  DateTime? _selectedDate;

  // إضافة الاشتراك مع userId إلى Firebase
  void _saveSubscription() async {
    if (_formKey.currentState!.validate() && _selectedDate != null) {
      final subscription = Subscription(
        id: const Uuid().v4(),
        nomService: _nomServiceController.text,
        prix: double.parse(_prixController.text),
        dateDebut: _selectedDate!,
        duree:
            {
              'Daily': 1,
              'Weekly': 7,
              'Bi-Weekly': 14,
              'Monthly': 30,
              'Semi-Annually': 180,
              'Annually': 365,
            }[_selectedDuration]!,
      );
      // تم إرسال userId مع الاشتراك إلى Firebase
      await SubscriptionService().addSubscription(widget.userId, subscription);
      Navigator.pop(context);
    }
  }

  // اختيار تاريخ الاشتراك
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Ajouter un abonnement")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nomServiceController,
                decoration: const InputDecoration(labelText: 'Nom du service'),
                validator: (value) => value!.isEmpty ? 'Champ requis' : null,
              ),
              TextFormField(
                controller: _prixController,
                decoration: const InputDecoration(labelText: 'Prix'),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'Champ requis' : null,
              ),
              DropdownButtonFormField<String>(
                value: _selectedDuration,
                decoration: const InputDecoration(labelText: 'Durée'),
                items: const [
                  DropdownMenuItem(value: 'Daily', child: Text('Daily')),
                  DropdownMenuItem(value: 'Weekly', child: Text('Weekly')),
                  DropdownMenuItem(
                    value: 'Bi-Weekly',
                    child: Text('Bi-Weekly'),
                  ),
                  DropdownMenuItem(value: 'Monthly', child: Text('Monthly')),
                  DropdownMenuItem(
                    value: 'Semi-Annually',
                    child: Text('Semi-Annually'),
                  ),
                  DropdownMenuItem(value: 'Annually', child: Text('Annually')),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedDuration = value;
                  });
                },
                validator: (value) => value == null ? 'Champ requis' : null,
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => _selectDate(context),
                child: Text(
                  _selectedDate == null
                      ? 'Choisir la date de début'
                      : 'Date: ${_selectedDate!.toLocal()}'.split(' ')[0],
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveSubscription,
                child: const Text('Enregistrer'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
