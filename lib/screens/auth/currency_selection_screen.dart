import 'package:flutter/material.dart';
import 'package:trucky/services/currency_service.dart';
import 'package:trucky/screens/home_screen.dart';
import 'package:trucky/config/colors.dart'; // Added for custom colors

class CurrencySelectionScreen extends StatefulWidget {
  @override
  _CurrencySelectionScreenState createState() =>
      _CurrencySelectionScreenState();
}

class _CurrencySelectionScreenState extends State<CurrencySelectionScreen> {
  String _selectedCurrency = 'MAD';

  final Map<String, String> _currencyOptions = {
    'MAD': 'Moroccan Dirham (DH)',
    'EUR': 'Euro (€)',
    'USD': 'US Dollar (\$)',
    'GBP': 'British Pound (£)',
    'CAD': 'Canadian Dollar (C\$)',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Sélectionnez la devise',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: BTN700,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [BTN700.withOpacity(0.1), BTN500.withOpacity(0.05)],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Sélectionnez votre devise préférée :',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey[800],
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Cela sera utilisé dans toute l\'application pour tous les affichages de montants',
                style: TextStyle(color: Colors.grey[600]),
              ),
              SizedBox(height: 30),
              Expanded(
                child: ListView.separated(
                  itemCount: _currencyOptions.length,
                  separatorBuilder: (context, index) => Divider(height: 1),
                  itemBuilder: (context, index) {
                    final key = _currencyOptions.keys.elementAt(index);
                    final value = _currencyOptions[key]!;
                    return Card(
                      elevation: 2,
                      margin: EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: RadioListTile<String>(
                        title: Text(
                          value,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        value: key,
                        groupValue: _selectedCurrency,
                        onChanged: (value) {
                          setState(() {
                            _selectedCurrency = value!;
                          });
                        },
                        activeColor: BTN700,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 8,
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: () async {
                    await CurrencyService.setCurrency(_selectedCurrency);
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => HomePage()),
                      (route) => false,
                    );
                  },
                  child: Text(
                    'Enregistrer et continuer',
                    style: TextStyle(fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: BTN700,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 5,
                  ),
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
