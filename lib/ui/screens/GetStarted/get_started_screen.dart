import 'package:flutter/material.dart';

import 'package:gemu/ui/constants/size_config.dart';

import 'components/body.dart';

class GetStartedScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      body: Body(),
    );
  }
}
