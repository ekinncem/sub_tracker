import 'package:flutter/material.dart';
import 'package:sub_tracker/database/database_helper.dart' as db;
import 'package:sub_tracker/models/subscription.dart';
import 'package:intl/intl.dart';

import 'database/database_helper.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Abonelik Takip',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const SubscriptionList(),
    );
  }
}

class SubscriptionList extends StatefulWidget {
  const SubscriptionList({super.key});

  @override
  _SubscriptionListState createState() => _SubscriptionListState();
}

class _SubscriptionListState extends State<SubscriptionList> {
  late Future<List<Subscription>> _subscriptions;
  final db.DatabaseHelper _dbHelper = db.DatabaseHelper.instance;

  @override
  void initState() {
    super.initState();
    _refreshList();
  }

  void _refreshList() {
    _subscriptions = _dbHelper.getAllSubscriptions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Aboneliklerim'),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => _showSubscriptionForm(),
      ),
      body: FutureBuilder<List<Subscription>>(
        future: _subscriptions,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Abonelik bulunamadı'));
          }

          final subscriptions = snapshot.data!;
          final total = subscriptions.fold(0.0, (sum, item) => sum + item.price);

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: subscriptions.length,
                  itemBuilder: (context, index) {
                    final sub = subscriptions[index];
                    return Dismissible(
                      key: Key(sub.id.toString()),
                      background: Container(color: Colors.red),
                      onDismissed: (direction) {
                        _dbHelper.deleteSubscription(sub.id!);
                        _refreshList();
                      },
                      child: ListTile(
                        title: Text(sub.name),
                        subtitle: Text(
                            '${DateFormat('dd/MM/yyyy').format(sub.date)} - ${sub.price.toStringAsFixed(2)}₺'),
                        trailing: IconButton(
                          icon: const Icos(Icons.edit),
                          onPressed: () => _showSubscriptionForm(subscription: sub),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Toplam Aylık Maliyet: ${total.toStringAsFixed(2)}₺',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showSubscriptionForm({Subscription? subscription}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: _SubscriptionForm(
          subscription: subscription,
          onSaved: () {
            _refreshList();
            Navigator.pop(context);
          },
        ),
      ),
    );
  }
}

class _SubscriptionForm extends StatefulWidget {
  final Subscription? subscription;
  final Function onSaved;

  const _SubscriptionForm({this.subscription, required this.onSaved});

  @override
  __SubscriptionFormState createState() => __SubscriptionFormState();
}

class __SubscriptionFormState extends State<_SubscriptionForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
        text: widget.subscription?.name ?? '');
    _priceController = TextEditingController(
        text: widget.subscription?.price.toString() ?? '');
    _selectedDate = widget.subscription?.date ?? DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Abonelik Adı'),
              validator: (value) =>
                  value!.isEmpty ? 'Lütfen bir ad girin' : null,
            ),
            TextFormField(
              controller: _priceController,
              decoration: const InputDecoration(labelText: 'Aylık Ücret (₺)'),
              keyboardType: TextInputType.number,
              validator: (value) =>
                  value!.isEmpty ? 'Lütfen ücret girin' : null,
            ),
            ListTile(
              title: Text(_selectedDate == null
                  ? 'Tarih Seçin'
                  : DateFormat('dd/MM/yyyy').format(_selectedDate!)),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate ?? DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (date != null) {
                  setState(() => _selectedDate = date);
                }
              },
            ),
            ElevatedButton(
              child: const Text('Kaydet'),
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  final subscription = Subscription(
                    id: widget.subscription?.id,
                    name: _nameController.text,
                    price: double.parse(_priceController.text),
                    date: _selectedDate!,
                  );

                  if (subscription.id == null) {
                    await DatabaseHelper.instance.insertSubscription(subscription);
                  } else {
                    await DatabaseHelper.instance.updateSubscription(subscription);
                  }

                  widget.onSaved();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}