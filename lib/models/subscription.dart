class Subscription {
  final String id;
  final String nomService;
  final double prix;
  final DateTime dateDebut;
  final int duree; // en jours ou mois selon logique

  Subscription({
    required this.id,
    required this.nomService,
    required this.prix,
    required this.dateDebut,
    required this.duree,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nomService': nomService,
      'prix': prix,
      'dateDebut': dateDebut.toIso8601String(),
      'duree': duree,
    };
  }

  factory Subscription.fromMap(Map<String, dynamic> map) {
    return Subscription(
      id: map['id'],
      nomService: map['nomService'],
      prix: map['prix'],
      dateDebut: DateTime.parse(map['dateDebut']),
      duree: map['duree'],
    );
  }
}
