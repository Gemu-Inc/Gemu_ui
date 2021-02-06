import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:Gemu/size_config.dart';

class Sun extends StatelessWidget {
  const Sun({Key key, @required this.isFullSun}) : super(key: key);

  final bool isFullSun;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: getProportionateScreenWidth(30),
      bottom: getProportionateScreenWidth(isFullSun ? -45 : -160),
      child: SvgPicture.asset("lib/assets/images/Sun.svg"),
    );
  }
}
