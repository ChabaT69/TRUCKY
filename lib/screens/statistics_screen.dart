// CODE COMPLET DE statistics.dart (version améliorée)
// Remplacez entièrement votre fichier lib/statistics.dart par ce contenu.
// Le code comprend toutes les améliorations demandées : légendes sous le PieChart, animations, cohérence des couleurs,
// interactions avec le PieChart et le BarChart, etc.

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/subscription.dart';

class StatisticsPage extends StatefulWidget {
  final List<Subscription> subscriptions;

  const StatisticsPage({Key? key, required this.subscriptions})
    : super(key: key);

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage>
    with SingleTickerProviderStateMixin {
  late Map<String, _CategoryStats> categoryStats;
  late String? mostExpensiveCategory;
  String? selectedCategory;
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    categoryStats = _calculateCategoryStats();
    mostExpensiveCategory = _findMostExpensiveCategory();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Map<String, _CategoryStats> _calculateCategoryStats() {
    final stats = <String, _CategoryStats>{};
    for (var sub in widget.subscriptions) {
      final cat = sub.category.trim().isEmpty ? 'Autre' : sub.category.trim();
      stats.putIfAbsent(cat, () => _CategoryStats());
      stats[cat]!.totalSpent += sub.price;
      stats[cat]!.subscriptions.add(sub);
    }
    return stats;
  }

  String? _findMostExpensiveCategory() {
    if (categoryStats.isEmpty) return null;
    return categoryStats.entries
        .reduce((a, b) => a.value.totalSpent > b.value.totalSpent ? a : b)
        .key;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final media = MediaQuery.of(context);
    final isSmallWidth = media.size.width < 400;
    final chartHeight = isSmallWidth ? 220.0 : 270.0;
    final fontSizeCategory = isSmallWidth ? 9.0 : 12.0;

    if (widget.subscriptions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Statistiques')),
        body: const Center(child: Text('Aucune donnée ')),
      );
    }

    final cats = categoryStats.keys.toList();
    final totalSpentMax = categoryStats.values
        .map((e) => e.totalSpent)
        .reduce((a, b) => a > b ? a : b);
    final totalAll = categoryStats.values
        .map((e) => e.totalSpent)
        .fold<double>(0.0, (sum, e) => sum + e);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistiques'),
        backgroundColor: Colors.lightBlue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              FadeTransition(
                opacity: _fadeAnimation,
                child:
                    selectedCategory == null
                        ? _buildGlobalView(
                          theme,
                          cats,
                          totalSpentMax,
                          totalAll,
                          chartHeight,
                          fontSizeCategory,
                        )
                        : _buildDetailView(theme, chartHeight),
              ),
              if (mostExpensiveCategory != null && selectedCategory == null)
                _buildMostExpensiveBar(theme),
            ],
          ),
        ),
      ),
      floatingActionButton:
          selectedCategory != null
              ? FloatingActionButton.extended(
                onPressed: () {
                  _controller.reverse().then((_) {
                    setState(() => selectedCategory = null);
                    _controller.forward();
                  });
                },
                icon: const Icon(Icons.arrow_back),
                label: const Text('Retour'),
                backgroundColor: Colors.lightBlue,
              )
              : null,
    );
  }

  Widget _buildGlobalView(
    ThemeData theme,
    List<String> cats,
    double totalSpentMax,
    double totalAll,
    double chartHeight,
    double fontSizeCategory,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Dépenses par catégorie', style: theme.textTheme.titleLarge),
        SizedBox(
          height: chartHeight,
          child: _buildBarChart(cats, totalSpentMax),
        ),
        const SizedBox(height: 24),
        Text('Répartition par catégorie', style: theme.textTheme.titleLarge),
        SizedBox(height: chartHeight, child: _buildPieChart(cats, totalAll)),
        _buildPieLegend(cats),
      ],
    );
  }

  Widget _buildDetailView(ThemeData theme, double chartHeight) {
    final subs = categoryStats[selectedCategory!]!.subscriptions;
    final maxPrice = subs.map((s) => s.price).reduce((a, b) => a > b ? a : b);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Détails : $selectedCategory', style: theme.textTheme.titleLarge),
        const SizedBox(height: 12),
        SizedBox(
          height: chartHeight,
          child: _buildSubscriptionChart(subs, maxPrice),
        ),
      ],
    );
  }

  Widget _buildBarChart(List<String> cats, double totalSpentMax) {
    return BarChart(
      BarChartData(
        barTouchData: BarTouchData(
          touchCallback: (event, response) {
            if (response != null && response.spot != null) {
              final index = response.spot!.touchedBarGroupIndex;
              setState(() => selectedCategory = cats[index]);
              _controller.forward(from: 0);
            }
          },
        ),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30, // Reserve more space for labels
              getTitlesWidget: (value, meta) {
                int index = value.toInt();
                if (index >= 0 && index < cats.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 6.0),
                    child: Text(
                      cats[index],
                      style: const TextStyle(fontSize: 10),
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40, // Reserve space for y-axis labels
              getTitlesWidget: (value, meta) {
                // Show some price values on y-axis instead of category names
                return Padding(
                  padding: const EdgeInsets.only(right: 6.0),
                  child: Text(
                    value.toStringAsFixed(0),
                    style: const TextStyle(fontSize: 10),
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              },
            ),
          ),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        barGroups: List.generate(cats.length, (i) {
          final spent = categoryStats[cats[i]]!.totalSpent;
          return BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: spent,
                width: 18,
                backDrawRodData: BackgroundBarChartRodData(
                  show: true,
                  toY: totalSpentMax,
                  color: Colors.grey.withOpacity(0.1),
                ),
                color: _getColorByIndex(i),
                borderRadius: BorderRadius.circular(4),
              ),
            ],
            showingTooltipIndicators: [0],
          );
        }),
        maxY: totalSpentMax * 1.1,
        borderData: FlBorderData(show: false),
      ),
    );
  }

  Widget _buildPieChart(List<String> cats, double totalAll) {
    return PieChart(
      PieChartData(
        centerSpaceRadius: 40,
        sectionsSpace: 2,
        sections: List.generate(cats.length, (i) {
          final cat = cats[i];
          final stat = categoryStats[cat]!;
          final percent = stat.totalSpent / totalAll * 100;
          return PieChartSectionData(
            color: _getColorByIndex(i),
            value: stat.totalSpent,
            radius: 60 + (stat.totalSpent / totalAll) * 20,
            title: '${cat}${percent.toStringAsFixed(1)}%',
            titleStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            titlePositionPercentageOffset: 0.6,
            badgeWidget: GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder:
                      (_) => AlertDialog(
                        title: Text('Abonnements - $cat'),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children:
                              stat.subscriptions
                                  .map(
                                    (sub) => Text('${sub.name}: ${sub.price}€'),
                                  )
                                  .toList(),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Fermer'),
                          ),
                        ],
                      ),
                );
              },
              child: const Icon(Icons.info, color: Colors.white),
            ),
            badgePositionPercentageOffset: 1.2,
          );
        }),
      ),
    );
  }

  Widget _buildPieLegend(List<String> cats) {
    return Column(
      children:
          cats.map((cat) {
            final index = cats.indexOf(cat);
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: _getColorByIndex(index),
                    radius: 6,
                  ),
                  const SizedBox(width: 8),
                  Text(cat, style: const TextStyle(fontSize: 12)),
                ],
              ),
            );
          }).toList(),
    );
  }

  Widget _buildSubscriptionChart(List<Subscription> subs, double maxPrice) {
    return BarChart(
      BarChartData(
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                int index = value.toInt();
                if (index >= 0 && index < subs.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 6.0),
                    child: Text(
                      subs[index].name,
                      style: const TextStyle(fontSize: 10),
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
        ),
        barGroups: List.generate(subs.length, (i) {
          return BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: subs[i].price,
                width: 16,
                color: Colors.indigo,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          );
        }),
        maxY: maxPrice * 1.1,
        borderData: FlBorderData(show: false),
      ),
    );
  }

  Widget _buildMostExpensiveBar(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.shade100,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.star, color: Colors.deepOrange),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Catégorie la plus chère : $mostExpensiveCategory (${categoryStats[mostExpensiveCategory]?.totalSpent.toStringAsFixed(2)} €)',
              style: theme.textTheme.bodyLarge,
            ),
          ),
        ],
      ),
    );
  }

  Color _getColorByIndex(int index) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
      Colors.amber,
    ];
    return colors[index % colors.length];
  }
}

class _CategoryStats {
  double totalSpent = 0;
  List<Subscription> subscriptions = [];
}
