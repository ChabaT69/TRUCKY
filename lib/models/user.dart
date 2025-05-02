class User {
  final String email;
  final String motDePasse;
  final String nom;
  final String prenom;

  const User({
    required this.email,
    required this.motDePasse,
    required this.nom,
    required this.prenom,
  });

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      email: map['email'],
      motDePasse: map['motDePasse'],
      nom: map['nom'],
      prenom: map['prenom'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'motDePasse': motDePasse,
      'nom': nom,
      'prenom': prenom,
    };
  }
}
