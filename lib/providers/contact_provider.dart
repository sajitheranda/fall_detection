import 'package:flutter/foundation.dart';
import '../database/contact_database.dart';
import '../model/contact.dart';

class ContactProvider with ChangeNotifier {
  final List<Contact> _contacts = [];

  List<Contact> get contacts => [..._contacts];

  Future<void> loadContacts() async {
    final data = await ContactDatabase.instance.getAllContacts();
    _contacts.clear();
    _contacts.addAll(data);
    notifyListeners();
  }

  Future<void> addContact(Contact contact) async {
    await ContactDatabase.instance.insertContact(contact);
    _contacts.add(contact);
    notifyListeners();
  }

  Future<void> updateContact(String id, Contact updated) async {
    await ContactDatabase.instance.updateContact(updated);
    final index = _contacts.indexWhere((c) => c.id == id);
    if (index >= 0) {
      _contacts[index] = updated;
      notifyListeners();
    }
  }

  Future<void> deleteContact(String id) async {
    await ContactDatabase.instance.deleteContact(id);
    _contacts.removeWhere((c) => c.id == id);
    notifyListeners();
  }
}
