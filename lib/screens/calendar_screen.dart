import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarScreen extends StatefulWidget {
  @override
  _CalendrierPageState createState() => _CalendrierPageState();
}

class _CalendrierPageState extends State<CalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  // Exemple d'abonnements (à remplacer par tes données Firebase)
  // Clés créées à minuit pour une correspondance précise
  Map<DateTime, List<Map<String, dynamic>>> abonnements = {
    DateTime(2025, 5, 20): [
      {'name': 'YouTube Premium', 'recurring': false},
    ],
  };

  @override
  void initState() {
    super.initState();
    // Pré-sélectionner la date avec Netflix pour afficher l'exemple
    _selectedDay = DateTime(2025, 5, 16);
    _focusedDay = _selectedDay!;
  }

  // Normalise la date: fixe l'heure à minuit
  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  // Renvoie la liste des abonnements pour une date donnée en normalisant
  List<Map<String, dynamic>> _getAbonnementsForDay(DateTime day) {
    final normalizedDay = _normalizeDate(day);
    List<Map<String, dynamic>> events = [];
    abonnements.forEach((key, value) {
      for (var event in value) {
        if (!event['recurring'] &&
            isSameDay(_normalizeDate(key), normalizedDay)) {
          events.add(event);
        } else if (event['recurring'] && key.day == normalizedDay.day) {
          events.add(event);
        }
      }
    });
    return events;
  }

  // Fonction pour ajouter un abonnement pour une date spécifiée
  void _addAbonnementForDate(
    String abonnement,
    DateTime chosenDate,
    bool recurring,
  ) {
    final DateTime day = _normalizeDate(chosenDate);
    setState(() {
      bool added = false;
      if (abonnements.containsKey(day)) {
        abonnements[day]!.add({'name': abonnement, 'recurring': recurring});
        added = true;
      }
      if (!added) {
        abonnements[day] = [
          {'name': abonnement, 'recurring': recurring},
        ];
      }
    });
  }

  // Affiche les abonnements en appliquant un style particulier pour 'Netflix'
  Widget _buildAbonnementWidget(Map<String, dynamic> abonnement) {
    final name = abonnement['name'];
    if (name == 'Netflix') {
      return Card(
        color: Colors.black,
        margin: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        child: ListTile(
          leading: Icon(Icons.movie, color: Colors.redAccent),
          title: Text(
            name,
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      );
    } else {
      return ListTile(leading: Icon(Icons.subscriptions), title: Text(name));
    }
  }

  // Affiche une boîte de dialogue pour ajouter un abonnement avec date spécifique
  Future<void> _showAddSubscriptionDialog() async {
    final TextEditingController _controller = TextEditingController();
    // Par défaut, utilise la date actuellement sélectionnée ou le jour en focus
    DateTime selectedDate = _selectedDay ?? _focusedDay;
    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            bool recurring = false;
            return AlertDialog(
              title: Text('Ajouter un abonnement'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      labelText: 'Nom de l\'abonnement',
                    ),
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Checkbox(
                        value: recurring,
                        onChanged: (newValue) {
                          setStateDialog(() {
                            recurring = newValue!;
                          });
                        },
                      ),
                      Text('Recurring'),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        'Date: ${selectedDate.toLocal().toString().split(" ")[0]}',
                      ),
                      Spacer(),
                      ElevatedButton(
                        onPressed: () async {
                          DateTime? newDate = await showDatePicker(
                            context: context,
                            initialDate: selectedDate,
                            firstDate: DateTime(2024, 1, 1),
                            lastDate: DateTime(2026, 12, 31),
                          );
                          if (newDate != null) {
                            setStateDialog(() {
                              selectedDate = newDate;
                            });
                          }
                        },
                        child: Text('Choisir'),
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Annuler'),
                ),
                TextButton(
                  onPressed: () {
                    String abonnementName = _controller.text.trim();
                    if (abonnementName.isNotEmpty) {
                      _addAbonnementForDate(
                        abonnementName,
                        selectedDate,
                        recurring,
                      );
                      setState(() {
                        _selectedDay = selectedDate;
                        _focusedDay = selectedDate;
                      });
                    }
                    Navigator.of(context).pop();
                  },
                  child: Text('Ajouter'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final abonnementsList = _getAbonnementsForDay(_selectedDay ?? _focusedDay);
    return Scaffold(
      appBar: AppBar(title: Text('Calendrier des abonnements')),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime(2024, 1, 1),
            lastDay: DateTime(2026, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            eventLoader: _getAbonnementsForDay,
            onFormatChanged: (format) {
              setState(() {
                _calendarFormat = format;
              });
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(
                color: Colors.orange,
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
              markerDecoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(height: 8.0),
          Expanded(
            child: ListView(
              children:
                  abonnementsList
                      .map((e) => _buildAbonnementWidget(e))
                      .toList(),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddSubscriptionDialog();
        },
        tooltip: 'Ajouter un abonnement',
        child: Icon(Icons.add),
      ),
    );
  }
}
