import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gemu/providers/Theme/dayMood_provider.dart';
import 'package:gemu/providers/GetStarted/getStarted_provider.dart';

import 'package:gemu/constants/constants.dart';
import 'package:gemu/translations/app_localizations.dart';

class GetStartedBeforeScreen extends ConsumerStatefulWidget {
  const GetStartedBeforeScreen({Key? key}) : super(key: key);

  @override
  _GetStartedBeforeScreenState createState() => _GetStartedBeforeScreenState();
}

class _GetStartedBeforeScreenState
    extends ConsumerState<GetStartedBeforeScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    bool seenGetStarted = ref.watch(getStartedNotifierProvider);
    bool isDayMood = ref.watch(dayMoodNotifierProvider);
    return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
          child: Padding(
            padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
            child: Column(
              children: [
                if (seenGetStarted) btnClear(),
                Expanded(child: bodyGetStartedBefore()),
                btnStart(isDayMood)
              ],
            ),
          ),
        ));
  }

  Widget btnClear() {
    return Container(
      height: 75,
      alignment: Alignment.topRight,
      padding: const EdgeInsets.only(right: 15.0),
      child: IconButton(
          onPressed: () {
                navNonAuthKey.currentState!.popUntil((route) => route.isFirst);
          },
          icon: Icon(
            Icons.clear,
            size: 30,
            color: Theme.of(context).iconTheme.color,
          )),
    );
  }

  Widget bodyGetStartedBefore() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          "assets/images/get_started.png",
          height: MediaQuery.of(context).size.height / 2.25,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 25.0),
          child: Text(
            AppLocalization.of(context)
                .translate("get_started_screen", "explanations"),
            style: Theme.of(context).textTheme.titleSmall,
            textAlign: TextAlign.center,
          ),
        )
      ],
    );
  }

  Widget btnStart(bool isDayMood) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 15.0),
      child: Container(
        height: MediaQuery.of(context).size.height / 12,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDayMood ? lightBgColors : darkBgColors),
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: ElevatedButton(
          onPressed: () {
            navNonAuthKey.currentState!.pushNamed(GetStarted);
          },
          style: ElevatedButton.styleFrom(
              primary: Colors.transparent,
              shadowColor: Colors.transparent,
              onPrimary: Theme.of(context).canvasColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              )),
          child: Text(
              AppLocalization.of(context)
                  .translate("get_started_screen", "start"),
              style: textStyleCustomBold(Colors.white, 14)),
        ),
      ),
    );
  }
}

class GetStartedScreen extends ConsumerStatefulWidget {
  const GetStartedScreen({Key? key}) : super(key: key);

  @override
  _GetStartedScreenState createState() => _GetStartedScreenState();
}

class _GetStartedScreenState extends ConsumerState<GetStartedScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int lengthGetStarted = 4;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: lengthGetStarted, vsync: this);
    _tabController.animation!.addListener(() {
      setState(() {
        _tabController.index = (_tabController.animation!.value).round();
      });
    });
  }

  @override
  void deactivate() {
    _tabController.animation?.removeListener(() {
      setState(() {
        _tabController.index = (_tabController.animation!.value).round();
      });
    });
    super.deactivate();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isDayMood = ref.watch(dayMoodNotifierProvider);
    bool seenGetStarted = ref.watch(getStartedNotifierProvider);

    return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
            child: Padding(
              padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
              child: Column(
                children: [
                  if (seenGetStarted) btnClear(),
                  Expanded(child: bodyGetStarted(isDayMood)),
                  stepsGetStarted(isDayMood, seenGetStarted, ref)
                ],
              ),
            )));
  }

  Widget btnClear() {
    return Container(
      height: 75,
      alignment: Alignment.topRight,
      padding: const EdgeInsets.only(right: 15.0),
      child: IconButton(
          onPressed: () {
            navNonAuthKey.currentState!.popUntil((route) => route.isFirst);
          },
          icon: Icon(
            Icons.clear,
            size: 30,
            color: Theme.of(context).iconTheme.color,
          )),
    );
  }

  Widget bodyGetStarted(bool isDayMood) {
    return TabBarView(
        controller: _tabController,
        physics: AlwaysScrollableScrollPhysics(),
        children: [
          firstPage(isDayMood),
          secondPage(isDayMood),
          thirdPage(isDayMood),
          fourthPage(isDayMood)
        ]);
  }

  Widget firstPage(bool isDayMood) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: Column(
        children: [
          Container(
              height: MediaQuery.of(context).size.height / 6,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.home,
                    size: 33,
                    color: isDayMood ? cPrimaryPink : cPrimaryPurple,
                  ),
                  const SizedBox(
                    height: 15.0,
                  ),
                  Text(
                    AppLocalization.of(context).translate(
                        "get_started_screen", "explanations_home_title"),
                    style: Theme.of(context).textTheme.titleSmall,
                    textAlign: TextAlign.center,
                  ),
                ],
              )),
          Expanded(
            child: Image.asset(
              "assets/images/get_started.png",
              height: MediaQuery.of(context).size.height / 2.25,
            ),
          ),
          Container(
              height: MediaQuery.of(context).size.height / 6,
              alignment: Alignment.center,
              child: Text(
                AppLocalization.of(context).translate(
                    "get_started_screen", "explanations_home_content"),
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ))
        ],
      ),
    );
  }

  Widget secondPage(bool isDayMood) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: Column(
        children: [
          Container(
              height: MediaQuery.of(context).size.height / 6,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.highlight,
                    color: isDayMood ? cPrimaryPink : cPrimaryPurple,
                    size: 33,
                  ),
                  const SizedBox(
                    height: 15.0,
                  ),
                  Text(
                    AppLocalization.of(context).translate(
                        "get_started_screen", "explanations_selection_title"),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ],
              )),
          Expanded(
            child: Image.asset(
              "assets/images/get_started.png",
              height: MediaQuery.of(context).size.height / 2.25,
            ),
          ),
          Container(
              height: MediaQuery.of(context).size.height / 6,
              alignment: Alignment.center,
              child: Text(
                AppLocalization.of(context).translate(
                    "get_started_screen", "explanations_selection_content"),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ))
        ],
      ),
    );
  }

  Widget thirdPage(bool isDayMood) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: Column(
        children: [
          Container(
              height: MediaQuery.of(context).size.height / 6,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_active,
                    color: isDayMood ? cPrimaryPink : cPrimaryPurple,
                    size: 33,
                  ),
                  const SizedBox(
                    height: 15.0,
                  ),
                  Text(
                    AppLocalization.of(context).translate(
                        "get_started_screen", "explanations_activities_title"),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ],
              )),
          Expanded(
            child: Image.asset(
              "assets/images/get_started.png",
              height: MediaQuery.of(context).size.height / 2.25,
            ),
          ),
          Container(
              height: MediaQuery.of(context).size.height / 6,
              alignment: Alignment.center,
              child: Text(
                AppLocalization.of(context).translate(
                    "get_started_screen", "explanations_activities_content"),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ))
        ],
      ),
    );
  }

  Widget fourthPage(bool isDayMood) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: Column(
        children: [
          Container(
              height: MediaQuery.of(context).size.height / 6,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.create,
                    color: isDayMood ? cPrimaryPink : cPrimaryPurple,
                    size: 33,
                  ),
                  const SizedBox(
                    height: 15.0,
                  ),
                  Text(
                    AppLocalization.of(context).translate(
                        "get_started_screen", "explanations_add_title"),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ],
              )),
          Expanded(
            child: Image.asset(
              "assets/images/get_started.png",
              height: MediaQuery.of(context).size.height / 2.25,
            ),
          ),
          Container(
              height: MediaQuery.of(context).size.height / 6,
              alignment: Alignment.center,
              child: Text(
                AppLocalization.of(context).translate(
                    "get_started_screen", "explanations_add_content"),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ))
        ],
      ),
    );
  }

  Widget stepsGetStarted(bool isDayMood, bool seenGetStarted, WidgetRef ref) {
    return Container(
      height: MediaQuery.of(context).size.height / 12,
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 100,
            child: TextButton(
                onPressed: () {
                  if (_tabController.index != lengthGetStarted - 1) {
                    setState(() {
                      _tabController.index = lengthGetStarted - 1;
                    });
                  }
                },
                child: Text(
                  AppLocalization.of(context)
                      .translate("get_started_screen", "passed"),
                  style: textStyleCustomBold(
                      Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : Colors.black,
                      12),
                )),
          ),
          TabPageSelector(
            controller: _tabController,
            selectedColor: isDayMood ? cPrimaryPink : cPrimaryPurple,
            color: Colors.transparent,
            indicatorSize: 14,
          ),
          Container(
            width: 100,
            child: TextButton(
                onPressed: () async {
                  if (_tabController.index != lengthGetStarted - 1) {
                    setState(() {
                      _tabController.index += 1;
                    });
                  } else {
                    if (!seenGetStarted) {
                      navNonAuthKey.currentState!
                          .pushNamedAndRemoveUntil(Welcome, (route) => false);
                      await Future.delayed(Duration(milliseconds: 250));
                      ref
                          .read(getStartedNotifierProvider.notifier)
                          .updateSeenGetStarted();
                    } else {
                      navNonAuthKey.currentState!
                          .pushNamedAndRemoveUntil(Welcome, (route) => false);
                    }
                  }
                },
                child: Text(
                  _tabController.index != lengthGetStarted - 1
                      ? AppLocalization.of(context)
                          .translate("get_started_screen", "next")
                      : AppLocalization.of(context)
                          .translate("get_started_screen", "finish"),
                  style: textStyleCustomBold(
                      Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : Colors.black,
                      12),
                )),
          )
        ],
      ),
    );
  }
}
