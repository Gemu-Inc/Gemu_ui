import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:gemu/ui/screens/Reglages/Design/theme_notifier.dart';

import 'package:gemu/models/user.dart';

//User global
UserModel? me;

//Style texte
mystyle(double size, [Color? color, FontWeight fw = FontWeight.w700]) {
  return GoogleFonts.montserrat(fontSize: size, color: color, fontWeight: fw);
}

//Avoir le thème
ThemeData themeApp(BuildContext context) {
  final themeNotifier = Provider.of<ThemeNotifier>(context);
  ThemeData themeApp = themeNotifier.getTheme();
  return themeApp;
}
