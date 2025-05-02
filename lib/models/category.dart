class Category {
  final String nom;

  const Category({required this.nom});

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(nom: map['nom']);
  }

  Map<String, dynamic> toMap() {
    return {'nom': nom};
  }
}
