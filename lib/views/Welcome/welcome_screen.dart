import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loader_overlay/loader_overlay.dart';

import 'package:gemu/constants/constants.dart';
import 'package:gemu/providers/Credentials/credentials_provider.dart';
import 'package:gemu/providers/Navigation/nav_non_auth.dart';
import 'package:gemu/providers/Theme/dayMood_provider.dart';
import 'package:gemu/components/bottom_sheet_custom.dart';
import 'package:gemu/components/clip_shadow_path.dart';
import 'package:gemu/components/custom_clipper.dart';
import 'package:gemu/translations/app_localizations.dart';

class WelcomeScreen extends ConsumerStatefulWidget {
  const WelcomeScreen({Key? key}) : super(key: key);
  @override
  WelcomeviewState createState() => WelcomeviewState();
}

class WelcomeviewState extends ConsumerState<WelcomeScreen> {
  @override
  Widget build(BuildContext context) {
    bool isDayMood = ref.watch(dayMoodNotifierProvider);

    return Scaffold(
        body: AnnotatedRegion<SystemUiOverlayStyle>(
            value: SystemUiOverlayStyle(
                statusBarColor: Colors.transparent,
                systemNavigationBarColor:
                    Theme.of(context).scaffoldBackgroundColor,
                statusBarIconBrightness:
                    Theme.of(context).brightness == Brightness.dark
                        ? Brightness.light
                        : Brightness.dark,
                systemNavigationBarIconBrightness:
                    Theme.of(context).brightness == Brightness.dark
                        ? Brightness.light
                        : Brightness.dark),
            child: Stack(
              children: [
                bodyWelcome(lightBgColors, darkBgColors, isDayMood),
              ],
            )));
  }

  Widget bodyWelcome(
      List<Color> lightBgColors, List<Color> darkBgColors, bool isDayMood) {
    return Padding(
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
      child: Stack(
        children: [
          ClipShadowPath(
            shadow: BoxShadow(
                color: Theme.of(context).shadowColor,
                offset: Offset(4, 4),
                blurRadius: 4,
                spreadRadius: 1),
            clipper: BigClipper(),
            child: Container(
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: isDayMood ? lightBgColors : darkBgColors)),
            ),
          ),
          ClipShadowPath(
            shadow: BoxShadow(
                color: Theme.of(context).shadowColor,
                offset: Offset(4, 4),
                blurRadius: 4,
                spreadRadius: 1),
            clipper: SmallClipper(),
            child: Container(
              decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor),
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: Image.asset(
              "assets/images/get_started.png",
              height: MediaQuery.of(context).size.height / 3,
            ),
          ),
          Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: const EdgeInsets.only(right: 25.0, top: 15.0),
              child: GestureDetector(
                  onTap: () {
                    navNonAuthKey.currentState!.pushNamed(GetStartedBefore);
                  },
                  child: Icon(Icons.info_outline,
                      size: 28, color: Theme.of(context).iconTheme.color)),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
                height: MediaQuery.of(context).size.height / 1.75,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width / 1.25,
                      padding: EdgeInsets.symmetric(horizontal: 15),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            AppLocalization.of(context)
                                .translate("welcome_screen", "welcome"),
                            style: textStyleCustomBold(
                                Theme.of(context).brightness == Brightness.dark
                                    ? cTextDarkTheme
                                    : cTextLightTheme,
                                30,
                                FontWeight.w500),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                          ),
                          const SizedBox(
                            height: 10.0,
                          ),
                          Text(
                            AppLocalization.of(context)
                                .translate("welcome_screen", "rejoign"),
                            style: textStyleCustomBold(
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white
                                    : Colors.black,
                                14),
                            textAlign: TextAlign.center,
                          )
                        ],
                      ),
                    ),
                    Container(
                      padding:
                          EdgeInsets.symmetric(vertical: 15.0, horizontal: 5.0),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                height: 2,
                                width: MediaQuery.of(context).size.width / 4,
                                color: Theme.of(context).canvasColor,
                              ),
                              Text(
                                AppLocalization.of(context)
                                    .translate("welcome_screen", "start"),
                                style: textStyleCustomBold(
                                    Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Colors.white
                                        : Colors.black,
                                    14),
                              ),
                              Container(
                                height: 2,
                                width: MediaQuery.of(context).size.width / 4,
                                color: Theme.of(context).canvasColor,
                              )
                            ],
                          ),
                          const SizedBox(
                            height: 10.0,
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width - 70,
                            height: MediaQuery.of(context).size.height / 14,
                            child: ElevatedButton(
                                onPressed: () => inscriptionBottomSheet(
                                    context, isDayMood, ref),
                                style: ElevatedButton.styleFrom(
                                    elevation: 6,
                                    shadowColor: Theme.of(context).shadowColor,
                                    primary: isDayMood
                                        ? cPrimaryPink
                                        : cPrimaryPurple,
                                    onPrimary: Theme.of(context).canvasColor,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15.0),
                                    )),
                                child: Text(
                                  AppLocalization.of(context)
                                      .translate("welcome_screen", "register"),
                                  style: textStyleCustomBold(Colors.white, 14),
                                )),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding:
                          EdgeInsets.symmetric(vertical: 15.0, horizontal: 5.0),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                height: 2,
                                width: MediaQuery.of(context).size.width / 4,
                                color: Theme.of(context).canvasColor,
                              ),
                              Text(
                                AppLocalization.of(context).translate(
                                    "welcome_screen", "already_account"),
                                style: textStyleCustomBold(
                                    Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Colors.white
                                        : Colors.black,
                                    14),
                              ),
                              Container(
                                height: 2,
                                width: MediaQuery.of(context).size.width / 4,
                                color: Theme.of(context).canvasColor,
                              )
                            ],
                          ),
                          const SizedBox(
                            height: 10.0,
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width - 70,
                            height: MediaQuery.of(context).size.height / 14,
                            child: ElevatedButton(
                                onPressed: () => connexionBottomSheet(
                                    context, isDayMood, ref),
                                style: ElevatedButton.styleFrom(
                                    elevation: 6,
                                    shadowColor: Theme.of(context).shadowColor,
                                    primary: isDayMood
                                        ? cPrimaryPurple
                                        : cPrimaryPink,
                                    onPrimary: Theme.of(context).canvasColor,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15.0),
                                    )),
                                child: Text(
                                  AppLocalization.of(context)
                                      .translate("welcome_screen", "login"),
                                  style: textStyleCustomBold(Colors.white, 14),
                                )),
                          ),
                        ],
                      ),
                    ),
                    Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10.0, vertical: 10.0),
                        child: RichText(
                            text: TextSpan(
                                text: AppLocalization.of(context)
                                    .translate("welcome_screen", "accord"),
                                style: textStyleCustomRegular(
                                    Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Colors.white
                                        : Colors.black,
                                    12),
                                children: [
                                  TextSpan(
                                      text: AppLocalization.of(context)
                                          .translate("welcome_screen", "cgu"),
                                      recognizer: TapGestureRecognizer()
                                        ..onTap =
                                            () => print("terms and conditions"),
                                      style: textStyleCustomBold(
                                          isDayMood
                                              ? cPrimaryPink
                                              : cPrimaryPurple,
                                          12)),
                                  TextSpan(
                                      text: AppLocalization.of(context)
                                          .translate(
                                              "welcome_screen", "accord_bis"),
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall),
                                  TextSpan(
                                      text: AppLocalization.of(context)
                                          .translate("welcome_screen",
                                              "confidentiality"),
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () => print("privacy policy"),
                                      style: textStyleCustomBold(
                                          isDayMood
                                              ? cPrimaryPink
                                              : cPrimaryPurple,
                                          12))
                                ]),
                            textAlign: TextAlign.center)),
                  ],
                )),
          ),
        ],
      ),
    );
  }
}
