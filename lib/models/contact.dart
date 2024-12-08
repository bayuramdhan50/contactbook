class Contact {
  final int? id;
  final String name;
  final String phone;
  final String? email;
  final String? avatar;
  final int isFavorite;

  Contact({
    this.id,
    required this.name,
    required this.phone,
    this.email,
    this.avatar,
    this.isFavorite = 0,
  });

  factory Contact.fromMap(Map<String, dynamic> map) {
    return Contact(
      id: map['id'],
      name: map['name'],
      phone: map['phone'],
      email: map['email'],
      avatar: map['avatar'],
      isFavorite: map['isFavorite'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'avatar': avatar,
      'isFavorite': isFavorite,
    };
  }
}
