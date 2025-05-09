import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:trucky/models/subscription.dart';
import 'package:trucky/services/subscription_service.dart';

class AddEditSubscriptionScreen extends StatefulWidget {
  const AddEditSubscriptionScreen({super.key});

  @override
  State<AddEditSubscriptionScreen> createState() =>
      _AddEditSubscriptionScreenState();
}

class _AddEditSubscriptionScreenState extends State<AddEditSubscriptionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomServiceController = TextEditingController();
  final _prixController = TextEditingController();
  final _dureeController = TextEditingController();
  DateTime? _selectedDate;

  void _saveSubscription() async {
    if (_formKey.currentState!.validate() && _selectedDate != null) {
      final subscription = Subscription(
        id: const Uuid().v4(),
        nomService: _nomServiceController.text,
        prix: double.parse(_prixController.text),
        dateDebut: _selectedDate!,
        duree: int.parse(_dureeController.text),
      );
      await SubscriptionService().addSubscription(subscription);
      Navigator.pop(context);
    }
  }

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
              TextFormField(
                controller: _dureeController,
                decoration: const InputDecoration(
                  labelText: 'Durée (jours/mois)',
                ),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'Champ requis' : null,
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
