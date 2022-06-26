import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gemu/constants/constants.dart';
import 'package:gemu/providers/Navigation/nav_non_auth.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

Future inscriptionBottomSheet(
    BuildContext context, bool isDayMood, WidgetRef ref) {
  return Platform.isIOS
      ? showCupertinoModalBottomSheet(
          context: context,
          enableDrag: true,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(15.0),
                  topRight: Radius.circular(15.0))),
          builder: (context) {
            return Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height / 2.30,
                decoration:
                    BoxDecoration(borderRadius: BorderRadius.circular(15.0)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 15.0, horizontal: 5.0),
                  child: Column(
                    children: [
                      Material(
                        type: MaterialType.transparency,
                        child: Container(
                          height: 50.0,
                          alignment: Alignment.center,
                          child: Text(
                            "Choisis ton moyen d'inscription",
                            style: Theme.of(context).textTheme.titleSmall,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      Expanded(
                          child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 25.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                                height: 50,
                                width: MediaQuery.of(context).size.width,
                                child: ElevatedButton(
                                    onPressed: () {
                                      ref
                                          .read(
                                              currentRouteNonAuthNotifierProvider
                                                  .notifier)
                                          .updateCurrentRoute("Register");
                                      navNonAuthKey.currentState!
                                          .pushNamed(Register);
                                    },
                                    style: ElevatedButton.styleFrom(
                                        elevation: 6,
                                        primary: isDayMood
                                            ? cPrimaryPink
                                            : cPrimaryPurple,
                                        onPrimary:
                                            Theme.of(context).canvasColor,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(15.0),
                                        )),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Icon(
                                          Icons.mail,
                                          color: Colors.white,
                                        ),
                                        const SizedBox(
                                          width: 15.0,
                                        ),
                                        Text(
                                          "S'inscrire avec une adresse mail",
                                          textAlign: TextAlign.center,
                                          style: textStyleCustomBold(
                                              Colors.white, 12),
                                        )
                                      ],
                                    ))),
                            const SizedBox(
                              height: 25.0,
                            ),
                            Container(
                                height: 50,
                                width: MediaQuery.of(context).size.width,
                                child: ElevatedButton(
                                    onPressed: () {
                                      print("inscription avec google");
                                    },
                                    style: ElevatedButton.styleFrom(
                                        elevation: 6,
                                        primary: Colors.grey,
                                        onPrimary:
                                            Theme.of(context).canvasColor,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(15.0),
                                        )),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Icon(
                                          MdiIcons.google,
                                          color: Colors.black,
                                        ),
                                        const SizedBox(
                                          width: 15.0,
                                        ),
                                        Text(
                                          "S'inscrire' avec Google",
                                          textAlign: TextAlign.center,
                                          style: textStyleCustomBold(
                                              Colors.black, 12),
                                        )
                                      ],
                                    ))),
                            const SizedBox(
                              height: 25.0,
                            ),
                            Container(
                                height: 50,
                                width: MediaQuery.of(context).size.width,
                                child: ElevatedButton(
                                    onPressed: () {
                                      print("inscription avec apple");
                                    },
                                    style: ElevatedButton.styleFrom(
                                        elevation: 6,
                                        primary: Theme.of(context).brightness ==
                                                Brightness.dark
                                            ? Colors.white
                                            : Colors.black,
                                        onPrimary:
                                            Theme.of(context).canvasColor,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(15.0),
                                        )),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Icon(
                                          MdiIcons.apple,
                                          color: Theme.of(context).brightness ==
                                                  Brightness.dark
                                              ? Colors.black
                                              : Colors.white,
                                        ),
                                        const SizedBox(
                                          width: 15.0,
                                        ),
                                        Text(
                                          "S'inscrire avec Apple",
                                          textAlign: TextAlign.center,
                                          style: textStyleCustomBold(
                                              Theme.of(context).brightness ==
                                                      Brightness.dark
                                                  ? Colors.black
                                                  : Colors.white,
                                              12),
                                        )
                                      ],
                                    ))),
                          ],
                        ),
                      ))
                    ],
                  ),
                ));
          })
      : showMaterialModalBottomSheet(
          context: context,
          enableDrag: true,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(15.0),
                  topRight: Radius.circular(15.0))),
          builder: (context) {
            return Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height / 2.30,
                decoration:
                    BoxDecoration(borderRadius: BorderRadius.circular(15.0)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 15.0, horizontal: 5.0),
                  child: Column(
                    children: [
                      Material(
                          type: MaterialType.transparency,
                          child: Container(
                            height: 50.0,
                            alignment: Alignment.center,
                            child: Text(
                              "Choisis ton moyen d'inscription",
                              style: Theme.of(context).textTheme.titleSmall,
                              textAlign: TextAlign.center,
                            ),
                          )),
                      Expanded(
                          child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 25.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                                height: 50,
                                width: MediaQuery.of(context).size.width,
                                child: ElevatedButton(
                                    onPressed: () {
                                      ref
                                          .read(
                                              currentRouteNonAuthNotifierProvider
                                                  .notifier)
                                          .updateCurrentRoute("Register");
                                      navNonAuthKey.currentState!
                                          .pushNamed(Register);
                                    },
                                    style: ElevatedButton.styleFrom(
                                        elevation: 6,
                                        primary: isDayMood
                                            ? cPrimaryPink
                                            : cPrimaryPurple,
                                        onPrimary:
                                            Theme.of(context).canvasColor,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(15.0),
                                        )),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Icon(
                                          Icons.mail,
                                          color: Colors.white,
                                        ),
                                        const SizedBox(
                                          width: 15.0,
                                        ),
                                        Text("S'inscrire avec une adresse mail",
                                            textAlign: TextAlign.center,
                                            style: textStyleCustomBold(
                                                Colors.white, 12))
                                      ],
                                    ))),
                            const SizedBox(
                              height: 25.0,
                            ),
                            Container(
                                height: 50,
                                width: MediaQuery.of(context).size.width,
                                child: ElevatedButton(
                                    onPressed: () {
                                      print("inscription avec google");
                                    },
                                    style: ElevatedButton.styleFrom(
                                        elevation: 6,
                                        primary: Colors.grey,
                                        onPrimary:
                                            Theme.of(context).canvasColor,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(15.0),
                                        )),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Icon(
                                          MdiIcons.google,
                                          color: Colors.black,
                                        ),
                                        const SizedBox(
                                          width: 15.0,
                                        ),
                                        Text("S'inscrire avec Google",
                                            textAlign: TextAlign.center,
                                            style: textStyleCustomBold(
                                                Colors.black, 12))
                                      ],
                                    ))),
                          ],
                        ),
                      ))
                    ],
                  ),
                ));
          });
}

Future connexionBottomSheet(
    BuildContext context, bool isDayMood, WidgetRef ref) {
  return Platform.isIOS
      ? showCupertinoModalBottomSheet(
          context: context,
          enableDrag: true,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(15.0),
                  topRight: Radius.circular(15.0))),
          builder: (context) {
            return Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height / 2.30,
                decoration:
                    BoxDecoration(borderRadius: BorderRadius.circular(15.0)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 15.0, horizontal: 5.0),
                  child: Column(
                    children: [
                      Material(
                        type: MaterialType.transparency,
                        child: Container(
                          height: 50.0,
                          alignment: Alignment.center,
                          child: Text(
                            "Choisis ton moyen de connexion",
                            style: Theme.of(context).textTheme.titleSmall,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      Expanded(
                          child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 25.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                                height: 50,
                                width: MediaQuery.of(context).size.width,
                                child: ElevatedButton(
                                    onPressed: () {
                                      ref
                                          .read(
                                              currentRouteNonAuthNotifierProvider
                                                  .notifier)
                                          .updateCurrentRoute("Login");
                                      navNonAuthKey.currentState!
                                          .pushNamed(Login);
                                    },
                                    style: ElevatedButton.styleFrom(
                                        elevation: 6,
                                        primary: isDayMood
                                            ? cPrimaryPurple
                                            : cPrimaryPink,
                                        onPrimary:
                                            Theme.of(context).canvasColor,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(15.0),
                                        )),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Icon(
                                          Icons.mail,
                                          color: Colors.white,
                                        ),
                                        const SizedBox(
                                          width: 15.0,
                                        ),
                                        Text(
                                          "Se connecter avec une adresse mail",
                                          textAlign: TextAlign.center,
                                          style: textStyleCustomBold(
                                              Colors.white, 12),
                                        )
                                      ],
                                    ))),
                            const SizedBox(
                              height: 25.0,
                            ),
                            Container(
                                height: 50,
                                width: MediaQuery.of(context).size.width,
                                child: ElevatedButton(
                                    onPressed: () {
                                      print("connexion avec google");
                                    },
                                    style: ElevatedButton.styleFrom(
                                        elevation: 6,
                                        primary: Colors.grey,
                                        onPrimary:
                                            Theme.of(context).canvasColor,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(15.0),
                                        )),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Icon(
                                          MdiIcons.google,
                                          color: Colors.black,
                                        ),
                                        const SizedBox(
                                          width: 15.0,
                                        ),
                                        Text(
                                          "Se connecter avec Google",
                                          textAlign: TextAlign.center,
                                          style: textStyleCustomBold(
                                              Colors.black, 12),
                                        )
                                      ],
                                    ))),
                            const SizedBox(
                              height: 25.0,
                            ),
                            Container(
                                height: 50,
                                width: MediaQuery.of(context).size.width,
                                child: ElevatedButton(
                                    onPressed: () {
                                      print("connexion avec apple");
                                    },
                                    style: ElevatedButton.styleFrom(
                                        elevation: 6,
                                        primary: Theme.of(context).brightness ==
                                                Brightness.dark
                                            ? Colors.white
                                            : Colors.black,
                                        onPrimary:
                                            Theme.of(context).canvasColor,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(15.0),
                                        )),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Icon(
                                          MdiIcons.apple,
                                          color: Theme.of(context).brightness ==
                                                  Brightness.dark
                                              ? Colors.black
                                              : Colors.white,
                                        ),
                                        const SizedBox(
                                          width: 15.0,
                                        ),
                                        Text(
                                          "Se connecter avec Apple",
                                          textAlign: TextAlign.center,
                                          style: textStyleCustomBold(
                                              Theme.of(context).brightness ==
                                                      Brightness.dark
                                                  ? Colors.black
                                                  : Colors.white,
                                              12),
                                        )
                                      ],
                                    ))),
                          ],
                        ),
                      ))
                    ],
                  ),
                ));
          })
      : showMaterialModalBottomSheet(
          context: context,
          enableDrag: true,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(15.0),
                  topRight: Radius.circular(15.0))),
          builder: (context) {
            return Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height / 2.30,
                decoration:
                    BoxDecoration(borderRadius: BorderRadius.circular(15.0)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 15.0, horizontal: 5.0),
                  child: Column(
                    children: [
                      Material(
                        type: MaterialType.transparency,
                        child: Container(
                          height: 50.0,
                          alignment: Alignment.center,
                          child: Text(
                            "Choisis ton moyen de connexion",
                            style: Theme.of(context).textTheme.titleSmall,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      Expanded(
                          child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 25.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                                height: 50,
                                width: MediaQuery.of(context).size.width,
                                child: ElevatedButton(
                                    onPressed: () {
                                      ref
                                          .read(
                                              currentRouteNonAuthNotifierProvider
                                                  .notifier)
                                          .updateCurrentRoute("Login");
                                      navNonAuthKey.currentState!
                                          .pushNamed(Login);
                                    },
                                    style: ElevatedButton.styleFrom(
                                        elevation: 6,
                                        primary: isDayMood
                                            ? cPrimaryPurple
                                            : cPrimaryPink,
                                        onPrimary:
                                            Theme.of(context).canvasColor,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(15.0),
                                        )),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Icon(
                                          Icons.mail,
                                          color: Colors.white,
                                        ),
                                        const SizedBox(
                                          width: 15.0,
                                        ),
                                        Text(
                                          "Se connecter avec une adresse mail",
                                          textAlign: TextAlign.center,
                                          style: textStyleCustomBold(
                                              Colors.white, 12),
                                        )
                                      ],
                                    ))),
                            const SizedBox(
                              height: 25.0,
                            ),
                            Container(
                                height: 50,
                                width: MediaQuery.of(context).size.width,
                                child: ElevatedButton(
                                    onPressed: () {
                                      print("connexion avec google");
                                    },
                                    style: ElevatedButton.styleFrom(
                                        elevation: 6,
                                        primary: Colors.grey,
                                        onPrimary:
                                            Theme.of(context).canvasColor,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(15.0),
                                        )),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Icon(
                                          MdiIcons.google,
                                          color: Colors.black,
                                        ),
                                        const SizedBox(
                                          width: 15.0,
                                        ),
                                        Text(
                                          "Se connecter avec Google",
                                          textAlign: TextAlign.center,
                                          style: textStyleCustomBold(
                                              Colors.black, 12),
                                        )
                                      ],
                                    ))),
                          ],
                        ),
                      ))
                    ],
                  ),
                ));
          });
}
