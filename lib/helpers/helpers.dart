import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:gemu/constants/constants.dart';
import 'package:gemu/widgets/alert_dialog_custom.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:timeago/timeago.dart' as time;

class Helpers {
  static Future<bool> willPopCallbackNav(
      BuildContext context, String navigation) async {
    await navNonAuthKey.currentState!.maybePop();
    return false;
  }

  static Future<bool> willPopCallbackShowDialog(BuildContext context) async {
    Helpers.hideKeyboard(context);
    showDialog(
        context: context,
        builder: (_) {
          return AlertDialogCustom(context, "Annuler l'inscription",
              "Êtes-vous sur de vouloir annuler votre inscription?", [
            TextButton(
                onPressed: () {
                  Navigator.pop(mainKey.currentContext!);
                  navNonAuthKey.currentState!
                      .pushNamedAndRemoveUntil(Welcome, (route) => false);
                },
                child: Text(
                  "Oui",
                  style: textStyleCustom(Colors.blue[200]!, 12),
                )),
            TextButton(
                onPressed: () => Navigator.pop(mainKey.currentContext!),
                child: Text(
                  "Non",
                  style: textStyleCustom(Colors.red[200]!, 12),
                ))
          ]);
        });
    return true;
  }

  static hideKeyboard(BuildContext context) {
    FocusScope.of(context).requestFocus(FocusNode());
  }

  static String datePostView(int timestamp) {
    initializeDateFormatting();
    DateTime timePost = DateTime.fromMillisecondsSinceEpoch(timestamp);

    return time.format(timePost);
  }

  static String datePostInfo(int timestamp) {
    initializeDateFormatting();
    DateTime timePost = DateTime.fromMillisecondsSinceEpoch(timestamp);
    DateFormat format;

    format = new DateFormat.yMMMd("fr_FR");

    return format.format(timePost).toString();
  }

  static String dateBirthday(DateTime date) {
    initializeDateFormatting();
    DateFormat format = new DateFormat.yMMMd("fr_FR");

    return format.format(date).toString();
  }

  static Future inscriptionBottomSheet(BuildContext context, bool isDayMood) {
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
                                      onPressed: () => navNonAuthKey
                                          .currentState!
                                          .pushNamed(Register),
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
                                            color:
                                                Theme.of(context).brightness ==
                                                        Brightness.dark
                                                    ? Colors.white
                                                    : Colors.black,
                                          ),
                                          const SizedBox(
                                            width: 15.0,
                                          ),
                                          Text(
                                            "S'inscrire avec une adresse mail",
                                            textAlign: TextAlign.center,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall,
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
                                            style: textStyleCustom(
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
                                          primary:
                                              Theme.of(context).brightness ==
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
                                            color:
                                                Theme.of(context).brightness ==
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
                                            style: textStyleCustom(
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
                                      onPressed: () => navNonAuthKey
                                          .currentState!
                                          .pushNamed(Register),
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
                                            color:
                                                Theme.of(context).brightness ==
                                                        Brightness.dark
                                                    ? Colors.white
                                                    : Colors.black,
                                          ),
                                          const SizedBox(
                                            width: 15.0,
                                          ),
                                          Text(
                                              "S'inscrire avec une adresse mail",
                                              textAlign: TextAlign.center,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall)
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
                                              style: textStyleCustom(
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

  static Future connexionBottomSheet(BuildContext context, bool isDayMood) {
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
                                      onPressed: () => navNonAuthKey
                                          .currentState!
                                          .pushNamed(Login),
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
                                            color:
                                                Theme.of(context).brightness ==
                                                        Brightness.dark
                                                    ? Colors.white
                                                    : Colors.black,
                                          ),
                                          const SizedBox(
                                            width: 15.0,
                                          ),
                                          Text(
                                            "Se connecter avec une adresse mail",
                                            textAlign: TextAlign.center,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall,
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
                                            style: textStyleCustom(
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
                                          primary:
                                              Theme.of(context).brightness ==
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
                                            color:
                                                Theme.of(context).brightness ==
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
                                            style: textStyleCustom(
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
                                      onPressed: () => navNonAuthKey
                                          .currentState!
                                          .pushNamed(Login),
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
                                            color:
                                                Theme.of(context).brightness ==
                                                        Brightness.dark
                                                    ? Colors.white
                                                    : Colors.black,
                                          ),
                                          const SizedBox(
                                            width: 15.0,
                                          ),
                                          Text(
                                            "Se connecter avec une adresse mail",
                                            textAlign: TextAlign.center,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall,
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
                                            style: textStyleCustom(
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
}
