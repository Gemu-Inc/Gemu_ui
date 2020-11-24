import 'package:meta/meta.dart';

class CategoriePost {
  final int idCategorie;
  final String name;
  bool selected;

  CategoriePost(
      {@required this.idCategorie,
      @required this.name,
      @required this.selected});
}
