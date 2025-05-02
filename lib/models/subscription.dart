class Subscription {
  final DateTime dateDebut;
  final int duree;
  final String nomService;
  final double prix;

  const Subscription({
    required this.dateDebut,
    required this.duree,
    required this.nomService,
    required this.prix,
  });

  factory Subscription.fromMap(Map<String, dynamic> map) {
    return Subscription(
      dateDebut: DateTime.parse(map['dateDebut']),
      duree: map['duree'],
      nomService: map['nomService'],
      prix: (map['prix'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'dateDebut': dateDebut.toIso8601String(),
      'duree': duree,
      'nomService': nomService,
      'prix': prix,
    };
  }
}
