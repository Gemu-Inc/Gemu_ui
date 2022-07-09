import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gemu/components/snack_bar_custom.dart';
import 'package:gemu/constants/constants.dart';
import 'package:gemu/providers/Credentials/credentials_provider.dart';
import 'package:gemu/providers/Navigation/nav_non_auth.dart';
import 'package:gemu/services/auth_service.dart';
import 'package:gemu/translations/app_localizations.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

Future inscriptionBottomSheet(
    BuildContext context, bool isDayMood, WidgetRef ref, bool loadingGoogle) {
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
                            AppLocalization.of(context)
                                .translate("register_screen", "choice"),
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
                                      navNonAuthKey.currentState!.pushNamed(
                                          Register,
                                          arguments: [false, null]);
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
                                          AppLocalization.of(context).translate(
                                              "register_screen",
                                              "register_mail"),
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
                                    onPressed: () async {
                                      if (!loadingGoogle) {
                                        ref
                                            .read(loadingSignGoogleProvider
                                                .notifier)
                                            .updateLoading(true);
                                        try {
                                          await AuthService.signWithGoogle(ref);
                                        } catch (e) {
                                          messageUser(
                                              context,
                                              AppLocalization.of(context)
                                                  .translate("message_user",
                                                      "oups_problem"));
                                        }
                                        ref
                                            .read(loadingSignGoogleProvider
                                                .notifier)
                                            .updateLoading(false);
                                      }
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
                                          AppLocalization.of(context).translate(
                                              "register_screen",
                                              "register_google"),
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
                                          AppLocalization.of(context).translate(
                                              "register_screen",
                                              "register_apple"),
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
                              AppLocalization.of(context)
                                  .translate("register_screen", "choice"),
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
                                      navNonAuthKey.currentState!.pushNamed(
                                          Register,
                                          arguments: [false, null]);
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
                                            AppLocalization.of(context)
                                                .translate("register_screen",
                                                    "register_mail"),
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
                                    onPressed: () async {
                                      if (!loadingGoogle) {
                                        ref
                                            .read(loadingSignGoogleProvider
                                                .notifier)
                                            .updateLoading(true);
                                        try {
                                          await AuthService.signWithGoogle(ref);
                                        } catch (e) {
                                          messageUser(
                                              context,
                                              AppLocalization.of(context)
                                                  .translate("message_user",
                                                      "oups_problem"));
                                        }
                                        ref
                                            .read(loadingSignGoogleProvider
                                                .notifier)
                                            .updateLoading(false);
                                      }
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
                                          AppLocalization.of(context).translate(
                                              "register_screen",
                                              "register_google"),
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

Future connexionBottomSheet(
    BuildContext context, bool isDayMood, WidgetRef ref, bool loadingGoogle) {
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
                            AppLocalization.of(context)
                                .translate("login_screen", "choice"),
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
                                          AppLocalization.of(context).translate(
                                              "login_screen", "login_email"),
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
                                    onPressed: () async {
                                      if (!loadingGoogle) {
                                        ref
                                            .read(loadingSignGoogleProvider
                                                .notifier)
                                            .updateLoading(true);
                                        try {
                                          await AuthService.signWithGoogle(ref);
                                        } catch (e) {
                                          messageUser(
                                              context,
                                              AppLocalization.of(context)
                                                  .translate("message_user",
                                                      "oups_problem"));
                                        }
                                        ref
                                            .read(loadingSignGoogleProvider
                                                .notifier)
                                            .updateLoading(false);
                                      }
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
                                          AppLocalization.of(context).translate(
                                              "login_screen", "login_google"),
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
                                          AppLocalization.of(context).translate(
                                              "login_screen", "login_apple"),
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
                            AppLocalization.of(context)
                                .translate("login_screen", "choice"),
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
                                          AppLocalization.of(context).translate(
                                              "login_screen", "login_email"),
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
                                    onPressed: () async {
                                      if (!loadingGoogle) {
                                        ref
                                            .read(loadingSignGoogleProvider
                                                .notifier)
                                            .updateLoading(true);
                                        try {
                                          await AuthService.signWithGoogle(ref);
                                        } catch (e) {
                                          messageUser(
                                              context,
                                              AppLocalization.of(context)
                                                  .translate("message_user",
                                                      "oups_problem"));
                                        }
                                        ref
                                            .read(loadingSignGoogleProvider
                                                .notifier)
                                            .updateLoading(false);
                                      }
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
                                          AppLocalization.of(context).translate(
                                              "login_screen", "login_google"),
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
