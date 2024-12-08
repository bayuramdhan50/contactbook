import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../database/database_helper.dart';
import '../models/contact.dart';
import 'home_screen.dart';

class ContactListScreen extends StatefulWidget {
  const ContactListScreen({super.key});

  @override
  State<ContactListScreen> createState() => _ContactListScreenState();
}

class _ContactListScreenState extends State<ContactListScreen> {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  List<Contact> contacts = [];
  List<Contact> originalContacts = [];

  @override
  void initState() {
    super.initState();
    _refreshContacts();
  }

  Future<void> _refreshContacts() async {
    final List<Map<String, dynamic>> contactMaps = await _databaseHelper.getContacts();
    setState(() {
      contacts = contactMaps.map((map) => Contact.fromMap(map)).toList();
      originalContacts = contacts;
    });
  }

  Future<void> _showContactDialog([Contact? contact]) async {
    final nameController = TextEditingController(text: contact?.name);
    final phoneController = TextEditingController(text: contact?.phone);
    final emailController = TextEditingController(text: contact?.email);
    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          contact == null ? 'Add Contact' : 'Edit Contact',
          textAlign: TextAlign.center,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: phoneController,
                decoration: InputDecoration(
                  labelText: 'Phone',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a phone number';
                  }
                  if (!RegExp(r'^\+?[\d\s-]+$').hasMatch(value)) {
                    return 'Please enter a valid phone number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                      return 'Please enter a valid email';
                    }
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                try {
                  final contactMap = {
                    if (contact?.id != null) 'id': contact!.id,
                    'name': nameController.text.trim(),
                    'phone': phoneController.text.trim(),
                    'email': emailController.text.trim(),
                    'avatar': null,
                  };

                  if (contact == null) {
                    await _databaseHelper.insertContact(contactMap);
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Contact added successfully'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  } else {
                    await _databaseHelper.updateContact(contactMap);
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Contact updated successfully'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  }

                  if (mounted) {
                    Navigator.pop(context);
                    _refreshContacts();
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error: ${e.toString()}'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteContact(Contact contact) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Contact'),
        content: Text('Are you sure you want to delete ${contact.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _databaseHelper.deleteContact(contact.id!);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Contact deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
          _refreshContacts();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1E88E5),  // Vibrant blue
            Color(0xFF7B1FA2),  // Deep purple
            Color(0xFFD32F2F),  // Deep red
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text(
            'Contact Book',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.transparent,
          leading: IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              if (context.findAncestorStateOfType<HomeScreenState>() != null) {
                context.findAncestorStateOfType<HomeScreenState>()!.toggleRail();
              }
            },
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.sort),
              onPressed: () async {
                final result = await showModalBottomSheet<String>(
                  context: context,
                  builder: (BuildContext context) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        ListTile(
                          leading: const Icon(Icons.list),
                          title: const Text('Show All'),
                          onTap: () {
                            Navigator.pop(context, 'all');
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.sort_by_alpha),
                          title: const Text('Sort by Name'),
                          onTap: () {
                            Navigator.pop(context, 'sort');
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.star),
                          title: const Text('Show Favorites'),
                          onTap: () {
                            Navigator.pop(context, 'favorites');
                          },
                        ),
                      ],
                    );
                  },
                );

                if (result == 'all') {
                  setState(() {
                    contacts = List.from(originalContacts);
                  });
                } else if (result == 'sort') {
                  setState(() {
                    contacts.sort((a, b) => a.name.compareTo(b.name));
                  });
                } else if (result == 'favorites') {
                  setState(() {
                    contacts = originalContacts.where((contact) => contact.isFavorite == 1).toList();
                  });
                }
              },
            ),
          ],
        ),
        body: contacts.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.contact_phone_outlined,
                      size: 100,
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No contacts yet',
                      style: TextStyle(
                        fontSize: 20,
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tap + to add a new contact',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                      ),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: contacts.length,
                itemBuilder: (context, index) {
                  final contact = contacts[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: Slidable(
                      endActionPane: ActionPane(
                        motion: const ScrollMotion(),
                        children: [
                          SlidableAction(
                            onPressed: (_) => _showContactDialog(contact),
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            foregroundColor: Colors.white,
                            icon: Icons.edit,
                            label: 'Edit',
                            borderRadius: const BorderRadius.horizontal(
                              left: Radius.circular(12),
                            ),
                          ),
                          SlidableAction(
                            onPressed: (_) async {
                              await DatabaseHelper.instance.toggleFavorite(contact);
                              _refreshContacts();
                            },
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                            icon: contact.isFavorite == 1 ? Icons.star : Icons.star_border,
                            label: contact.isFavorite == 1 ? 'Unfavorite' : 'Favorite',
                          ),
                          SlidableAction(
                            onPressed: (_) async {
                              await _deleteContact(contact);
                            },
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            icon: Icons.delete,
                            label: 'Delete',
                            borderRadius: const BorderRadius.horizontal(
                              right: Radius.circular(12),
                            ),
                          ),
                        ],
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Color(0xFF424242),  // Dark grey background
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Color(0xFF000000).withOpacity(0.2),  // Black shadow
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          leading: CircleAvatar(
                            radius: 25,
                            backgroundColor: Color(0xFF81C784).withOpacity(0.8),  // Mint green avatar
                            child: Text(
                              contact.name[0].toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(
                            contact.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.phone,
                                    size: 16,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      contact.phone,
                                      style: const TextStyle(
                                        color: Colors.grey,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              if (contact.email != null && contact.email!.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.email,
                                      size: 16,
                                      color: Colors.grey,
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        contact.email!,
                                        style: const TextStyle(
                                          color: Colors.grey,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.phone_outlined),
                            color: Theme.of(context).colorScheme.primary,
                            onPressed: () {
                              // TODO: Implement phone call
                            },
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showContactDialog(),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
