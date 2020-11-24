import 'package:meta/meta.dart';

class UserLogin {
  final String name;
  final String imageProfil;
  final String imageBanniere;
  final String uid;

  const UserLogin({
    @required this.name,
    @required this.imageProfil,
    @required this.imageBanniere,
    this.uid,
  });
}
