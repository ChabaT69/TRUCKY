import 'package:flutter/material.dart';
import 'package:trucky/config/colors.dart';
import 'package:trucky/models/subscription.dart';
import 'package:trucky/screens/calendar_screen.dart';
import 'package:trucky/screens/subscription/add_edit_subscription_screen.dart';
import 'package:trucky/services/subscription_service.dart';
import 'package:trucky/widgets/subscription_card.dart';

class HomeScreen extends StatefulWidget {
  final String userId;
  const HomeScreen({super.key, required this.userId});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Subscription>> _subscriptionsFuture;

  @override
  void initState() {
    super.initState();
    _fetchSubscriptions();
  }

  void _fetchSubscriptions() {
    _subscriptionsFuture = SubscriptionService().getSubscriptions(
      widget.userId,
    );
  }

  void _addSubscription() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditSubscriptionScreen(userId: widget.userId),
      ),
    );
    setState(() {
      _fetchSubscriptions();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Subscriptions', style: TextStyle(fontSize: 22)),
      ),
      body: FutureBuilder<List<Subscription>>(
        future: _subscriptionsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            var subscriptions = snapshot.data ?? [];
            if (subscriptions.isEmpty) {
              return Center(
                child: Image.asset(
                  'assets/images/home.png',
                  width: 300,
                  fit: BoxFit.cover,
                ),
              );
            } else {
              return ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: subscriptions.length,
                itemBuilder: (context, index) {
                  return SubscriptionCard(subscription: subscriptions[index]);
                },
              );
            }
          }
        },
      ),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 6,
        color: BTN700,
        child: SizedBox(
          height: 65,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                icon: const Icon(Icons.home, color: Colors.white),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.event_note, color: Colors.white),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CalendarScreen()),
                  );
                },
              ),
              const SizedBox(width: 40),
              IconButton(
                icon: const Icon(Icons.bar_chart, color: Colors.white),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.more_horiz, color: Colors.white),
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black,
        shape: const CircleBorder(),
        onPressed: _addSubscription,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
