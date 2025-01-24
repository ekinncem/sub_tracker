import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Subscription {
  final String category;
  final double price;

  Subscription({required this.category, required this.price});
}

class SubscriptionProvider extends ChangeNotifier {
  List<Subscription> _subscriptions = [];

  List<Subscription> get subscriptions => _subscriptions;

  void addSubscription(Subscription subscription) {
    _subscriptions.add(subscription);
    notifyListeners();
  }
}

// İstatistik Ekranı
class StatisticsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Abonelik İstatistikleri')),
      body: Consumer<SubscriptionProvider>(
        builder: (context, provider, child) {
          final subscriptions = provider.subscriptions;
          
          // Toplam aylık maliyet
          final totalMonthlyExpense = subscriptions.fold(
            0.0, 
            (sum, subscription) => sum + subscription.price
          );

          // Kategoriye göre harcama
          final categoryExpenses = _calculateCategoryExpenses(subscriptions);

          return ListView(
            padding: EdgeInsets.all(16),
            children: [
              _buildStatCard(
                title: 'Toplam Aylık Harcama',
                value: '${totalMonthlyExpense.toStringAsFixed(2)} TL',
              ),
              SizedBox(height: 16),
              Text(
                'Kategoriye Göre Harcama',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              ...categoryExpenses.entries.map((entry) => 
                _buildStatCard(
                  title: entry.key,
                  value: '${entry.value.toStringAsFixed(2)} TL',
                )
              ).toList(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatCard({required String title, required String value}) {
    return Card(
      elevation: 4,
      child: ListTile(
        title: Text(title),
        trailing: Text(
          value, 
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Map<String, double> _calculateCategoryExpenses(List<Subscription> subscriptions) {
    final Map<String, double> categoryExpenses = {};
    
    for (var subscription in subscriptions) {
      categoryExpenses[subscription.category] = 
        (categoryExpenses[subscription.category] ?? 0) + subscription.price;
    }
    
    return categoryExpenses;
  }
}