import 'package:flutter/material.dart';
import 'package:trucky/screens/settings_screen.dart';
import 'package:trucky/screens/calendar_screen.dart';
import 'package:trucky/screens/subscription/add_edit_subscription_screen.dart';

class MyApp extends StatelessWidget {
  static const Color lightBlue = Color(0xFF81D4FA);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tracky',
      theme: ThemeData(
        primaryColor: lightBlue,
        scaffoldBackgroundColor: Colors.white,
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: lightBlue,
          elevation: 6.0,
          splashColor: Colors.blueAccent,
        ),
        bottomAppBarTheme: BottomAppBarTheme(
          color: lightBlue.withOpacity(0.95),
          elevation: 8,
          shape: const CircularNotchedRectangle(),
        ),
        iconTheme: const IconThemeData(color: Colors.white, size: 28),
        appBarTheme: const AppBarTheme(
          backgroundColor: lightBlue,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
          iconTheme: IconThemeData(color: Colors.white),
        ),
      ),
      home: const HomePage(userId: ''),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key, required String userId}) : super(key: key);
  @override
  _HomePageState createState() => _HomePageState();
}

enum TabItem { home, calendar, statistics, profile }

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  TabItem _currentTab = TabItem.home;
  final List<Subscription> _subscriptions = [];

  final Map<TabItem, IconData> tabIcons = {
    TabItem.home: Icons.home,
    TabItem.calendar: Icons.calendar_today,
    TabItem.statistics: Icons.insert_chart_outlined,
    TabItem.profile: Icons.person,
  };

  final Map<TabItem, String> tabTitles = {
    TabItem.home: 'Home',
    TabItem.calendar: 'Calendar',
    TabItem.statistics: 'Statistics',
    TabItem.profile: 'Profile',
  };

  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _controller.forward();
  }

  void _selectTab(TabItem tabItem) {
    _controller.reverse().then((_) {
      setState(() {
        _currentTab = tabItem;
      });
      _controller.forward();
    });
  }

  Widget _buildBody() {
    if (_currentTab == TabItem.home) {
      return _subscriptions.isEmpty
          ? Center(
            child: Text(
              "No subscriptions yet.\nTap the + button to add one.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
          )
          : _buildSubscriptionList();
    } else if (_currentTab == TabItem.calendar) {
      return CalendarPage(subscriptions: _subscriptions);
    } else if (_currentTab == TabItem.profile) {
      return const ProfilePage();
    }
    String title = tabTitles[_currentTab] ?? '';
    return Center(
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  Future<void> _showAddSubscriptionDialog({
    Subscription? subscription,
    int? index,
  }) async {
    final bool isEditing = subscription != null && index != null;
    final updatedSubscription = await showDialog<Subscription>(
      context: context,
      builder:
          (context) => AddSubscriptionDialog(
            isEditing: isEditing,
            existingSubscription: subscription,
            onAdd: (s) {}, // Dummy
          ),
    );

    if (updatedSubscription != null) {
      setState(() {
        if (isEditing) {
          _subscriptions[index!] = updatedSubscription;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Subscription "${updatedSubscription.name}" modified!',
              ),
            ),
          );
        } else {
          _subscriptions.add(updatedSubscription);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Subscription "${updatedSubscription.name}" added!',
              ),
            ),
          );
        }
      });
    }
  }

  void _deleteSubscription(int index) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("Confirm Deletion"),
            content: Text(
              'Are you sure you want to delete "${_subscriptions[index].name}"?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Delete'),
              ),
            ],
          ),
    );

    if (confirm == true) {
      setState(() {
        final deletedName = _subscriptions[index].name;
        _subscriptions.removeAt(index);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Subscription "$deletedName" deleted')),
        );
      });
    }
  }

  Widget _buildSubscriptionList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      itemCount: _subscriptions.length,
      itemBuilder: (context, index) {
        final subscription = _subscriptions[index];
        final status = subscription.status;
        Color statusColor;
        String statusText;
        IconData statusIcon;
        switch (status) {
          case SubscriptionStatus.expired:
            statusColor = Colors.red.shade700;
            statusText = "Expired";
            statusIcon = Icons.warning;
            break;
          case SubscriptionStatus.dueSoon:
            statusColor = Colors.orange.shade700;
            statusText = "Due Soon";
            statusIcon = Icons.access_time;
            break;
          case SubscriptionStatus.active:
          default:
            statusColor = Colors.green.shade700;
            statusText = "Active";
            statusIcon = Icons.check_circle;
            break;
        }
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: statusColor.withOpacity(0.2),
                  child: Icon(statusIcon, color: statusColor, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        subscription.name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subscription.category,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            Icons.attach_money,
                            size: 16,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            subscription.price.toStringAsFixed(2),
                            style: TextStyle(color: Colors.grey[800]),
                          ),
                          const SizedBox(width: 24),
                          Icon(
                            Icons.calendar_today,
                            size: 16,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            subscription.startDateFormatted,
                            style: TextStyle(color: Colors.grey[800]),
                          ),
                          const SizedBox(width: 24),
                          Container(
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(
                              vertical: 2,
                              horizontal: 10,
                            ),
                            child: Text(
                              statusText,
                              style: TextStyle(
                                color: statusColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blueAccent),
                      tooltip: 'Modifier',
                      onPressed: () {
                        _showAddSubscriptionDialog(
                          subscription: subscription,
                          index: index,
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.redAccent),
                      tooltip: 'Supprimer',
                      onPressed: () {
                        _deleteSubscription(index);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _showAddSubscriptionDialogSimple() {
    _showAddSubscriptionDialog();
  }

  @override
  Widget build(BuildContext context) {
    final appBarTitle = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.track_changes, color: Colors.white, size: 26),
        const SizedBox(width: 8),
        FadeTransition(
          opacity: _animation,
          child: Text(
            'Tracky - ${tabTitles[_currentTab]}',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ),
      ],
    );

    return Scaffold(
      appBar: AppBar(title: appBarTitle, centerTitle: true),
      body: _buildBody(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        tooltip: 'Add Subscription',
        child: const Icon(Icons.add, size: 32),
        onPressed: _showAddSubscriptionDialogSimple,
      ),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        color: Theme.of(context).bottomAppBarTheme.color,
        elevation: Theme.of(context).bottomAppBarTheme.elevation,
        child: SizedBox(
          height: 60,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    _buildTabIcon(TabItem.home),
                    const SizedBox(width: 24),
                    _buildTabIcon(TabItem.calendar),
                  ],
                ),
                Row(
                  children: [
                    _buildTabIcon(TabItem.statistics),
                    const SizedBox(width: 24),
                    _buildTabIcon(TabItem.profile),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabIcon(TabItem tabItem) {
    bool isSelected = _currentTab == tabItem;
    return IconButton(
      icon: Icon(
        tabIcons[tabItem],
        color: isSelected ? Colors.white : Colors.white70,
        size: isSelected ? 32 : 28,
      ),
      onPressed: () => _selectTab(tabItem),
      splashRadius: 24,
      tooltip: tabTitles[tabItem],
    );
  }
}
