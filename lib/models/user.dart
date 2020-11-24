class UserC {
  final String id;
  final String pseudo;
  final String email;
  final String photoURL;
  final String points;

  UserC({this.id, this.pseudo, this.email, this.photoURL, this.points});

  UserC.fromData(Map<String, dynamic> data)
      : id = data['id'],
        pseudo = data['pseudo'],
        email = data['email'],
        photoURL = data['photoURL'],
        points = data['points'];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'pseudo': pseudo,
      'email': email,
      'photoURL': photoURL,
      'points': points,
    };
  }
}
