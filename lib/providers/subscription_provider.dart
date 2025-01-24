import 'package:flutter/foundation.dart';
import '../models/subscription.dart';

class SubscriptionProvider with ChangeNotifier {
  List<Subscription> _subscriptions = [];

  // Tüm abonelikleri getiren getter
  List<Subscription> get subscriptions => [..._subscriptions];

  // Aktif abonelikleri getiren getter
  List<Subscription> get activeSubscriptions => 
    _subscriptions.where((sub) => sub.isActive).toList();

  // Abonelik ekleme metodu
  void addSubscription(Subscription subscription) {
    _subscriptions.add(subscription);
    notifyListeners();
  }

  // Abonelik silme metodu
  void removeSubscription(String id) {
    _subscriptions.removeWhere((sub) => sub.id == id);
    notifyListeners();
  }

  // Abonelik güncelleme metodu
  void updateSubscription(Subscription updatedSubscription) {
    final index = _subscriptions.indexWhere((sub) => sub.id == updatedSubscription.id);
    if (index != -1) {
      _subscriptions[index] = updatedSubscription;
      notifyListeners();
    }
  }

  // Belirli bir kategorideki abonelikleri getirme
  List<Subscription> getSubscriptionsByCategory(String category) {
    return _subscriptions.where((sub) => sub.category == category).toList();
  }

  // Yaklaşan yenileme tarihine göre abonelikleri sıralama
  List<Subscription> getUpcomingRenewals() {
    return _subscriptions
      .where((sub) => sub.isActive)
      .where((sub) => sub.getDaysUntilRenewal() <= 30)
      .toList()
      ..sort((a, b) => a.getDaysUntilRenewal().compareTo(b.getDaysUntilRenewal()));
  }

  // Toplam aylık abonelik maliyeti
  double getTotalMonthlyExpense() {
    return _subscriptions
      .where((sub) => sub.isActive)
      .map((sub) => sub.price)
      .fold(0, (prev, price) => prev + price);
  }

  // Abonelik durumunu değiştirme
  void toggleSubscriptionStatus(String id) {
    final index = _subscriptions.indexWhere((sub) => sub.id == id);
    if (index != -1) {
      _subscriptions[index].isActive = !_subscriptions[index].isActive;
      notifyListeners();
    }
  }

  // Yenileme tarihlerini otomatik güncelleme
  void updateAllRenewalDates() {
    for (var subscription in _subscriptions) {
      if (subscription.isActive && 
          DateTime.now().isAfter(subscription.renewalDate)) {
        subscription.updateRenewalDate();
      }
    }
    notifyListeners();
  }
}

class Subscription {

  String id;

  String category;

  double price;

  bool isActive;

  DateTime renewalDate;



  Subscription({

    required this.id,

    required this.category,

    required this.price,

    required this.renewalDate,

    this.isActive = true,

  });



  int getDaysUntilRenewal() {

    return renewalDate.difference(DateTime.now()).inDays;

  }



  void updateRenewalDate() {

    renewalDate = DateTime.now().add(const Duration(days: 30));

  }

}