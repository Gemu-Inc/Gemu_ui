import 'package:flutter/material.dart';
import 'package:Gemu/size_config.dart';

class Land extends StatelessWidget {
  const Land({Key? key, required this.dayMood}) : super(key: key);

  final bool dayMood;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: getProportionateScreenWidth(-65),
      left: 0,
      right: 0,
      child: dayMood
          ? Image.asset(
              "lib/assets/images/land_tree_light.png",
              height: getProportionateScreenWidth(450),
              fit: BoxFit.fitHeight,
            )
          : Image.asset(
              "lib/assets/images/land_tree_dark.png",
              height: getProportionateScreenWidth(450),
              fit: BoxFit.fitHeight,
            ),
    );
  }
}
