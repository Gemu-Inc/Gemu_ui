import 'package:flutter/material.dart';
import 'package:Gemu/core/models/models.dart';

class ProfilBanniere extends StatelessWidget {
  final UserLogin currentUser;

  const ProfilBanniere({
    Key key,
    @required this.currentUser,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => print('Bannière'),
      child: Image(
        image: AssetImage(currentUser.imageBanniere),
        width: 200,
        alignment: Alignment.topCenter,
        fit: BoxFit.cover,
      ),
    );
  }
}
