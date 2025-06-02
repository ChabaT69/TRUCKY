import 'package:flutter/material.dart';
import 'package:trucky/screens/settings_screen.dart';
import 'package:trucky/screens/calendar_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:trucky/screens/subscription/add_edit_subscription_screen.dart';
import 'package:trucky/screens/subscription/subscription_details_screen.dart'; // Add this import
import '../models/subscription.dart';
import '../services/subscription_manager.dart';
import 'statistics_screen.dart'; // Add this import
import 'package:trucky/config/colors.dart';
import 'package:intl/intl.dart';

class MyApp extends StatelessWidget {
  static const Color lightBlue = Color(0xFF81D4FA);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Trucky',
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
          backgroundColor: BTN700,
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
      home: const HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

enum TabItem { home, calendar, statistics, profile }

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  TabItem _currentTab = TabItem.home;
  final List<Subscription> _subscriptions = [];
  final SubscriptionManager _subscriptionManager = SubscriptionManager();
  bool _isLoading = false;

  // Add sorting state variables
  SortOption _currentSortOption = SortOption.date;
  bool _sortAscending = true;

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
    TabItem.profile: 'Profil',
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

    // Load subscriptions
    _loadSubscriptions();
  }

  Future<void> _loadSubscriptions() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final subscriptions =
          await _subscriptionManager.getCurrentUserSubscriptions();
      setState(() {
        _subscriptions.clear();
        _subscriptions.addAll(subscriptions);
        _sortSubscriptions(); // Apply sorting to loaded subscriptions
      });
    } catch (e) {
      print('Error loading subscriptions: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
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
      return Column(
        children: [
          // Remove the duplicate page title from these components
          // _buildPageTitle(tabTitles[_currentTab] ?? ''),
          // Add total price display
          _buildTotalPriceDisplay(),
          Expanded(
            child:
                _subscriptions.isEmpty
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset('assets/images/home.png'),
                          const SizedBox(height: 20),
                          Text(
                            "Tap the + button to add a subscription",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    )
                    : Column(
                      children: [
                        Expanded(child: _buildSubscriptionList()),
                        // Add sort button row
                        _buildSortControls(),
                      ],
                    ),
          ),
        ],
      );
    } else if (_currentTab == TabItem.calendar) {
      return Column(
        children: [
          // Remove the duplicate page title
          // _buildPageTitle(tabTitles[_currentTab] ?? ''),
          Expanded(child: CalendarPage(subscriptions: _subscriptions)),
        ],
      );
    } else if (_currentTab == TabItem.statistics) {
      return Column(
        children: [
          // Remove the duplicate page title
          // _buildPageTitle(tabTitles[_currentTab] ?? ''),
          Expanded(child: StatisticsPage(subscriptions: _subscriptions)),
        ],
      );
    } else if (_currentTab == TabItem.profile) {
      return Column(
        children: [
          // Remove the duplicate page title
          // _buildPageTitle(tabTitles[_currentTab] ?? ''),
          const Expanded(child: ProfilePage()),
        ],
      );
    }

    // Default case
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

  Widget _buildPageTitle(String title) {
    return FadeTransition(
      opacity: _animation,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        alignment: Alignment.centerLeft, // Align to left
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
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
            onAdd: (s) async {
              if (isEditing) {
                await _subscriptionManager.updateSubscription(s);
              } else {
                await _subscriptionManager.addSubscription(s);
              }
            },
          ),
    );

    if (updatedSubscription != null) {
      _loadSubscriptions();
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
      final subscription = _subscriptions[index];
      if (subscription.id != null) {
        final success = await _subscriptionManager.deleteSubscription(
          subscription.id!,
        );
        if (success) {
          _loadSubscriptions();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error deleting subscription')),
          );
        }
      }
    }
  }

  // Optimized subscription list with fixed layout and tappable cards
  Widget _buildSubscriptionList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      itemCount: _subscriptions.length,
      itemBuilder: (context, index) {
        final subscription = _subscriptions[index];

        // Determine status based on payment date - using the correct date for status
        final DateTime now = DateTime.now();
        final DateTime paymentDate =
            subscription.lastPaymentDate != null &&
                    subscription.nextPaymentDate != null
                ? subscription.nextPaymentDate!
                : subscription.startDate;

        // Make sure the days calculation is correct for monthly subscriptions
        final int daysUntilPayment = paymentDate.difference(now).inDays;

        // Define status based on days until payment
        SubscriptionStatus status;
        if (daysUntilPayment < 0) {
          status = SubscriptionStatus.expired;
        } else if (daysUntilPayment <= 7) {
          status = SubscriptionStatus.dueSoon;
        } else {
          status = SubscriptionStatus.active;
        }

        Color statusColor;
        String statusText;
        IconData statusIcon;

        // Set status color, text, and icon
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

        // Determine which date to display based on payment history
        String dateValue;

        // Check if the subscription has been paid at least once
        if (subscription.lastPaymentDate != null) {
          // Show next payment date if the subscription has been paid before
          dateValue =
              subscription.nextPaymentDate != null
                  ? _formatDate(subscription.nextPaymentDate!)
                  : 'Not scheduled';
        } else {
          // For new subscriptions that haven't been paid yet, show the initial payment date
          // This is the date the user entered when creating the subscription
          dateValue = _formatDate(subscription.startDate);
        }

        return GestureDetector(
          onTap: () => _navigateToSubscriptionDetails(subscription),
          child: Card(
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
                  // Status avatar
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
                        // First row - Category and price
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                subscription.category,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ),
                            Icon(
                              Icons.attach_money,
                              size: 16,
                              color: Colors.grey[600],
                            ),
                            Text(
                              subscription.price.toStringAsFixed(2),
                              style: TextStyle(color: Colors.grey[800]),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        // Second row - Date and status
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 16,
                              color: Colors.blue[700],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              dateValue,
                              style: TextStyle(color: Colors.grey[800]),
                            ),
                            const Spacer(),
                            // Status tag
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
                  // Arrow indicator for navigation
                  Icon(Icons.chevron_right, color: Colors.grey[500]),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Navigate to subscription details
  Future<void> _navigateToSubscriptionDetails(Subscription subscription) async {
    // Navigate to the details page and wait for a result
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => SubscriptionDetailsScreen(subscription: subscription),
      ),
    );

    // Handle the result when returning from details page
    if (result != null && result is Map<String, dynamic>) {
      if (result['action'] == 'delete') {
        // Subscription was deleted, refresh the list
        _loadSubscriptions();
      } else if (result['action'] == 'update') {
        // Immediately update the subscription in the local list for instant UI update
        if (result['subscription'] != null &&
            result['subscription'] is Subscription) {
          final updatedSubscription = result['subscription'] as Subscription;
          final index = _subscriptions.indexWhere(
            (s) => s.id == updatedSubscription.id,
          );
          if (index != -1) {
            setState(() {
              _subscriptions[index] = updatedSubscription;
              _sortSubscriptions(); // Re-sort the list
            });
          }
        }
        // Also reload from the database to ensure consistency
        _loadSubscriptions();
      }
    }
  }

  // Update sorting to consider due date for better organization
  void _sortSubscriptions() {
    setState(() {
      switch (_currentSortOption) {
        case SortOption.date:
          _subscriptions.sort((a, b) {
            // First sort by status (expired -> due soon -> active)
            final statusCompare = a.status.index.compareTo(b.status.index);
            if (statusCompare != 0) return statusCompare;

            // Then by start date
            return _sortAscending
                ? a.startDate.compareTo(b.startDate)
                : b.startDate.compareTo(a.startDate);
          });
          break;
        case SortOption.price:
          _subscriptions.sort((a, b) {
            return _sortAscending
                ? a.price.compareTo(b.price)
                : b.price.compareTo(a.price);
          });
          break;
      }
    });
  }

  // Format date to a readable string
  String _formatDate(DateTime date) {
    // Format as day/month/year (e.g., 6/6/2025)
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _showAddSubscriptionDialogSimple() {
    _showAddSubscriptionDialog();
  }

  // Add widget to display total subscription cost
  Widget _buildTotalPriceDisplay() {
    final totalPrice = _subscriptions.fold(
      0.0,
      (sum, subscription) => sum + subscription.price,
    );

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.lightBlue.shade50,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Total Monthly Cost:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.blueGrey[700],
            ),
          ),
          Text(
            '\$${totalPrice.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.lightBlue[800],
            ),
          ),
        ],
      ),
    );
  }

  // Sort controls widget
  Widget _buildSortControls() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Color.fromARGB(255, 249, 243, 249),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, -2),
            blurRadius: 3,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Sort by:'),
          const SizedBox(width: 12),
          ChoiceChip(
            label: const Text('Date'),
            selected: _currentSortOption == SortOption.date,
            selectedColor: BTN700.withOpacity(0.7),
            labelStyle: TextStyle(
              color:
                  _currentSortOption == SortOption.date
                      ? Colors.white
                      : Colors.black87,
            ),
            onSelected: (selected) {
              if (selected) {
                setState(() {
                  _currentSortOption = SortOption.date;
                  _sortSubscriptions();
                });
              }
            },
          ),
          const SizedBox(width: 8),
          ChoiceChip(
            label: const Text('Price'),
            selected: _currentSortOption == SortOption.price,
            selectedColor: BTN700.withOpacity(0.7),
            labelStyle: TextStyle(
              color:
                  _currentSortOption == SortOption.price
                      ? Colors.white
                      : Colors.black87,
            ),
            onSelected: (selected) {
              if (selected) {
                setState(() {
                  _currentSortOption = SortOption.price;
                  _sortSubscriptions();
                });
              }
            },
          ),
          const SizedBox(width: 16),
          Container(
            decoration: BoxDecoration(
              color: BTN700.withOpacity(0.7),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(
                _sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
                size: 20,
                color: Colors.white,
              ),
              onPressed: () {
                setState(() {
                  _sortAscending = !_sortAscending;
                  _sortSubscriptions();
                });
              },
              tooltip: _sortAscending ? 'Ascending' : 'Descending',
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(tabTitles[_currentTab] ?? ''),
        centerTitle: true,
        // Remove back button/arrow
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(child: _buildBody()),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        tooltip: 'Add Subscription',
        child: const Icon(Icons.add, size: 32),
        onPressed: _showAddSubscriptionDialogSimple,
      ),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        color:
            BTN500, // Changed from Theme.of(context).bottomAppBarTheme.color to BTN700
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

// Add sort option enum at the bottom of the file
enum SortOption { date, price }
