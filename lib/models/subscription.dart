class Subscription {
  int? id;
  String name;
  double price;
  DateTime date;

  Subscription({
    this.id,
    required this.name,
    required this.price,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'date': date,
    };
  }

  factory Subscription.fromMap(Map<String, dynamic> map) {
    return Subscription(
      id: map['id'],
      name: map['name'],
      price: map['price'],
      date: DateTime.parse(map['date']),
    );
  }
}