import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/subscription.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddSubscriptionDialog extends StatefulWidget {
  final Function(Subscription) onAdd;
  final Subscription? existingSubscription;
  final bool isEditing;

  const AddSubscriptionDialog({
    Key? key,
    required this.onAdd,
    this.existingSubscription,
    this.isEditing = false,
  }) : super(key: key);

  @override
  _AddSubscriptionDialogState createState() => _AddSubscriptionDialogState();
}

class _AddSubscriptionDialogState extends State<AddSubscriptionDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _categoryController;
  DateTime? _startDate;
  String _paymentDuration = 'Daily';

  final List<String> _durations = ['Daily', 'Weekly', 'Monthly', 'Yearly'];
  final List<String> _defaultCategories = [
    'Food',
    'Entertainment',
    'Utilities',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.isEditing && widget.existingSubscription != null) {
      final s = widget.existingSubscription!;
      _nameController = TextEditingController(text: s.name);
      _priceController = TextEditingController(
        text: s.price.toStringAsFixed(2),
      );
      _categoryController = TextEditingController(text: s.category);
      _startDate = s.startDate;
      _paymentDuration = s.paymentDuration;
    } else {
      _nameController = TextEditingController();
      _priceController = TextEditingController();
      _categoryController = TextEditingController(
        text: _defaultCategories.first,
      );
    }
  }

  Future<void> _pickStartDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? now,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 5),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.lightBlue,
              onPrimary: Colors.white,
              onSurface: Colors.black87,
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _startDate = picked;
      });
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate() && _startDate != null) {
      String name = _nameController.text.trim();
      double price = double.parse(_priceController.text.trim());
      String category = _categoryController.text.trim();
      String paymentDuration = _paymentDuration;
      final startDate = _startDate!;

      try {
        Subscription subscription = Subscription(
          id: widget.isEditing ? widget.existingSubscription!.id : null,
          name: name,
          price: price,
          startDate: startDate,
          category: category.isEmpty ? 'Other' : category,
          paymentDuration: paymentDuration,
        );

        // Store data in Firestore through the onAdd callback
        widget.onAdd(subscription);

        Navigator.of(context).pop(subscription);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.isEditing
                  ? 'Subscription modified!'
                  : 'Subscription "$name" added!',
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      } catch (e) {
        print('Error creating subscription: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else if (_startDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a start date.')),
      );
    }
  }

  Widget _buildCategoryField() {
    return Autocomplete<String>(
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text.isEmpty) {
          return _defaultCategories;
        }
        return _defaultCategories.where((String option) {
          return option.toLowerCase().contains(
            textEditingValue.text.toLowerCase(),
          );
        });
      },
      fieldViewBuilder: (context, controller, focusNode, onEditingComplete) {
        controller.text = _categoryController.text;
        controller.selection = TextSelection.fromPosition(
          TextPosition(offset: controller.text.length),
        );
        controller.addListener(() {
          _categoryController.text = controller.text;
          _categoryController.selection = controller.selection;
        });
        return TextFormField(
          controller: controller,
          focusNode: focusNode,
          decoration: InputDecoration(
            labelText: 'Catégorie',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            prefixIcon: Icon(Icons.category, color: Colors.lightBlue),
          ),
          validator:
              (val) =>
                  val == null || val.isEmpty ? 'Entrez une catégorie' : null,
          onEditingComplete: onEditingComplete,
        );
      },
      onSelected: (selection) {
        _categoryController.text = selection;
      },
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 12,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.isEditing
                      ? 'Modifier Subscription'
                      : 'Add Subscription',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.lightBlue,
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Nom d\'abonnement',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    prefixIcon: Icon(
                      Icons.subscriptions,
                      color: Colors.lightBlue,
                    ),
                  ),
                  validator:
                      (val) =>
                          val == null || val.isEmpty ? 'Entrez un nom' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _priceController,
                  decoration: InputDecoration(
                    labelText: 'Prix de l\'abonnement',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    prefixIcon: Icon(
                      Icons.attach_money,
                      color: Colors.lightBlue,
                    ),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                  ],
                  validator: (val) {
                    if (val == null || val.isEmpty) return 'Entrez un prix';
                    final parsed = double.tryParse(val);
                    if (parsed == null || parsed < 0) {
                      return 'Entrez un prix valide';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: _pickStartDate,
                  child: AbsorbPointer(
                    child: TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Date de payment',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        prefixIcon: Icon(
                          Icons.calendar_today,
                          color: Colors.lightBlue,
                        ),
                        suffixIcon: Icon(
                          Icons.arrow_drop_down,
                          color: Colors.lightBlue,
                        ),
                      ),
                      controller: TextEditingController(
                        text:
                            _startDate == null
                                ? ''
                                : '${_startDate!.day}/${_startDate!.month}/${_startDate!.year}',
                      ),
                      validator:
                          (val) =>
                              (val == null || val.isEmpty)
                                  ? 'Choisissez une date'
                                  : null,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _paymentDuration,
                  decoration: InputDecoration(
                    labelText: 'Durée du paiement',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    prefixIcon: Icon(Icons.timer, color: Colors.lightBlue),
                  ),
                  items:
                      _durations
                          .map(
                            (d) => DropdownMenuItem<String>(
                              value: d,
                              child: Text(d),
                            ),
                          )
                          .toList(),
                  onChanged: (value) {
                    setState(() {
                      _paymentDuration = value ?? 'Daily';
                    });
                  },
                ),
                const SizedBox(height: 16),
                _buildCategoryField(),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.lightBlue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 6,
                    ),
                    onPressed: _submit,
                    child: Text(
                      widget.isEditing ? 'Modifier' : 'Ajouter',
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
