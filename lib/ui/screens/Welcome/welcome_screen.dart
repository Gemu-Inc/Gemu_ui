import 'package:flutter/material.dart';
import 'package:Gemu/size_config.dart';
import 'package:Gemu/ui/screens/Welcome/components/body.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      backgroundColor: Color(0xFF1A1C25),
      body: Body(),
    );
  }
}
