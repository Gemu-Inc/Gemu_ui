class UserModel {
  final String id;
  final String pseudo;
  final String email;
  final String photoURL;
  final String points;
  final List<String> idGames;

  UserModel(
      {this.id,
      this.pseudo,
      this.email,
      this.photoURL,
      this.points,
      this.idGames});

  factory UserModel.fromMap(Map<String, dynamic> data) {
    return UserModel(
        id: data['id'],
        pseudo: data['pseudo'],
        email: data['email'],
        photoURL: data['photoURL'],
        points: data['points'],
        idGames: List<String>.from(data['idGames'].map((item) {
          return item;
        }).toList()));
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'pseudo': pseudo,
      'email': email,
      'photoURL': photoURL,
      'points': points,
      'idGames': idGames
    };
  }
}
