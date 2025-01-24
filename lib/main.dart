import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class SubscriptionProvider extends ChangeNotifier {
  final List<Subscription> _subscriptions = [];

  List<Subscription> get subscriptions => _subscriptions;

  void addSubscription(Subscription subscription) {
    _subscriptions.add(subscription);
    notifyListeners();
  }
}

class Subscription {
  final String id;
  final String name;
  final double price;
  final DateTime startDate;
  final DateTime renewalDate;
  final String category;

  Subscription({
    required this.id,
    required this.name,
    required this.price,
    required this.startDate,
    required this.renewalDate,
    required this.category,
  });
}

class AddSubscriptionScreen extends StatefulWidget {
  @override
  _AddSubscriptionScreenState createState() => _AddSubscriptionScreenState();
}

class _AddSubscriptionScreenState extends State<AddSubscriptionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  
  DateTime? _startDate;
  DateTime? _renewalDate;
  String _selectedCategory = 'Diğer';

  // Kategori listesi
  final List<String> _categories = [
    'Müzik', 
    'Video', 
    'Yazılım', 
    'Oyun', 
    'Eğitim', 
    'Sağlık', 
    'Diğer'
  ];

  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != _startDate) {
      setState(() {
        _startDate = picked;
        // Yenileme tarihini otomatik hesapla
        _renewalDate = DateTime(
          picked.year, 
          picked.month + 1, 
          picked.day
        );
      });
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final subscription = Subscription(
        id: Uuid().v4(),
        name: _nameController.text,
        price: double.parse(_priceController.text),
        startDate: _startDate ?? DateTime.now(),
        renewalDate: _renewalDate ?? DateTime.now().add(Duration(days: 30)),
        category: _selectedCategory,
      );

      Provider.of<SubscriptionProvider>(context, listen: false)
        .addSubscription(subscription);

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Yeni Abonelik Ekle')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Abonelik Adı',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lütfen abonelik adını giriniz';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _priceController,
                decoration: InputDecoration(
                  labelText: 'Aylık Ücret',
                  suffixText: 'TL',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lütfen ücreti giriniz';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: InputDecoration(
                  labelText: 'Kategori',
                  border: OutlineInputBorder(),
                ),
                items: _categories.map((String category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedCategory = newValue!;
                  });
                },
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _selectStartDate(context),
                      child: Text(_startDate == null 
                        ? 'Başlangıç Tarihi Seç' 
                        : 'Tarih: ${_startDate!.day}/${_startDate!.month}/${_startDate!.year}'
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Text(
                _renewalDate != null 
                  ? 'Yenileme Tarihi: ${_renewalDate!.day}/${_renewalDate!.month}/${_renewalDate!.year}'
                  : 'Yenileme Tarihi Hesaplanacak',
                style: TextStyle(color: Colors.grey),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _submitForm,
                child: Text('Aboneliği Kaydet'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}