import 'package:flutter/material.dart';
import 'package:Gemu/size_config.dart';

import 'components/body.dart';

class GetStartedScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      backgroundColor: Color(0xFF1A1C25),
      body: Body(),
    );
  }
}
