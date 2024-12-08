import 'package:flutter/material.dart';
import '../models/contact.dart';
import '../database/database_helper.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({super.key});

  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  List<Contact> favoriteContacts = [];

  @override
  void initState() {
    super.initState();
    _refreshFavorites();
  }

  Future<void> _refreshFavorites() async {
    final favorites = await DatabaseHelper.instance.getFavoriteContacts();
    setState(() {
      favoriteContacts = favorites;
    });
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
            'Favorites',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.transparent,
        ),
        body: favoriteContacts.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.favorite_border,
                      size: 100,
                      color: Colors.white.withOpacity(0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No favorite contacts yet',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.white.withOpacity(0.5),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: favoriteContacts.length,
                itemBuilder: (context, index) {
                  final contact = favoriteContacts[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: Slidable(
                      endActionPane: ActionPane(
                        motion: const ScrollMotion(),
                        children: [
                          SlidableAction(
                            onPressed: (_) async {
                              await DatabaseHelper.instance.toggleFavorite(contact);
                              _refreshFavorites();
                            },
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                            icon: Icons.star_border,
                            label: 'Unfavorite',
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ],
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Color(0xFF424242).withOpacity(0.7),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
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
                            backgroundColor: Color(0xFFF57C00),
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
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            contact.phone,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
