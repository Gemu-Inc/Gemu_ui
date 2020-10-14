import 'package:meta/meta.dart';

class User {
  final String name;
  final String imageProfil;
  final String imageBanniere;
  final String uid;

  const User({
    @required this.name,
    @required this.imageProfil,
    @required this.imageBanniere,
    this.uid,
  });
}
