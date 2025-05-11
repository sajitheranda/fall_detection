import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../providers/contact_provider.dart';
import 'model/contact.dart';

class ContactListScreen extends StatelessWidget {
  Future<void> showContactDialog(BuildContext context, {Contact? contact}) async {
    final _formKey = GlobalKey<FormState>();
    String name = contact?.name ?? '';
    String phone = contact?.phone ?? '';

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(contact == null ? 'Add Contact' : 'Edit Contact'),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                initialValue: name,
                decoration: InputDecoration(labelText: 'Name'),
                onSaved: (val) => name = val!,
                validator: (val) => val!.isEmpty ? 'Enter name' : null,
              ),
              TextFormField(
                initialValue: phone,
                decoration: InputDecoration(labelText: 'Phone'),
                onSaved: (val) => phone = val!,
                validator: (val) => val!.isEmpty ? 'Enter phone' : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                _formKey.currentState!.save();
                final provider = Provider.of<ContactProvider>(context, listen: false);
                if (contact == null) {
                  provider.addContact(Contact(id: Uuid().v4(), name: name, phone: phone));
                } else {
                  provider.updateContact(contact.id, Contact(id: contact.id, name: name, phone: phone));
                }
                Navigator.of(ctx).pop();
              }
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  void showDeleteDialog(BuildContext context, Contact contact) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete Contact'),
        content: Text('Are you sure you want to delete ${contact.name}?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Provider.of<ContactProvider>(context, listen: false).deleteContact(contact.id);
              Navigator.of(ctx).pop();
            },
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final contactProvider = Provider.of<ContactProvider>(context);
    final contacts = contactProvider.contacts;

    return Column(
      children: [
        const SizedBox(height: 40),
        Divider(),
        const Padding(
          padding: EdgeInsets.all(10), // Top padding for spacing
          child: Text(
            'Contact List',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.blueAccent,
            ),
          ),
        ),
        contacts.isEmpty
            ? Center(child: Text('No contacts yet.'))
            : ListView.builder(
          shrinkWrap: true, // Makes the inner ListView take only required space
          physics: NeverScrollableScrollPhysics(), // Prevents inner ListView from scrolling independently
          itemCount: contacts.length,
          itemBuilder: (_, index) {
            final contact = contacts[index];
            return ListTile(
              title: Text(contact.name),
              subtitle: Text(contact.phone),
              onTap: () => showContactDialog(context, contact: contact),
              trailing: IconButton(
                icon: Icon(Icons.delete),
                onPressed: () => showDeleteDialog(context, contact),
              ),
            );
          },
        ),

        SizedBox(height: 20),


        TextButton(
          onPressed: () => showContactDialog(context),
          child: Text(
            'Add Contact',
            style: TextStyle(color: Colors.white),
          ),
          style: TextButton.styleFrom(
            backgroundColor: Colors.blueAccent,
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        )

      ],
    );
  }
}