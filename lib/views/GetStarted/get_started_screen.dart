import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gemu/riverpod/Theme/dayMood_provider.dart';
import 'package:gemu/riverpod/GetStarted/getStarted_provider.dart';

import 'package:gemu/constants/constants.dart';
import 'package:gemu/views/Welcome/welcome_screen.dart';

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
    return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: AnnotatedRegion<SystemUiOverlayStyle>(
          child: Consumer(builder: (_, ref, child) {
            bool seenGetStarted = ref.watch(getStartedNotifierProvider);
            if (!seenGetStarted) {
              ref.read(dayMoodNotifierProvider.notifier).timeMood();
            }
            bool isDayMood = ref.watch(dayMoodNotifierProvider);
            return Padding(
              padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
              child: Column(
                children: [
                  if (seenGetStarted) btnClear(),
                  Expanded(child: bodyGetStartedBefore()),
                  btnStart(isDayMood)
                ],
              ),
            );
          }),
          value: SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness:
                  Theme.of(context).brightness == Brightness.dark
                      ? Brightness.light
                      : Brightness.dark),
        ));
  }

  Widget btnClear() {
    return Container(
      height: 75,
      alignment: Alignment.topRight,
      padding: const EdgeInsets.only(right: 15.0),
      child: IconButton(
          onPressed: () {
            navNonAuthKey.currentState!
                .pushNamedAndRemoveUntil(Welcome, (route) => false);
          },
          icon: Icon(
            Icons.clear,
            size: 30,
          )),
    );
  }

  Widget bodyGetStartedBefore() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset("assets/images/get_started.png"),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 25.0),
          child: Text(
            "Quelques explications avant d'entrer dans l'aventure Gemu",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
            "Commencer",
            style: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.w700),
          ),
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
    return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: AnnotatedRegion<SystemUiOverlayStyle>(
            value: SystemUiOverlayStyle(
                statusBarColor: Colors.transparent,
                statusBarIconBrightness:
                    Theme.of(context).brightness == Brightness.dark
                        ? Brightness.light
                        : Brightness.dark),
            child: Consumer(builder: (context, ref, child) {
              bool isDayMood = ref.watch(dayMoodNotifierProvider);
              bool seenGetStarted = ref.watch(getStartedNotifierProvider);
              return Padding(
                padding:
                    EdgeInsets.only(top: MediaQuery.of(context).padding.top),
                child: Column(
                  children: [
                    if (seenGetStarted) btnClear(),
                    Expanded(child: bodyGetStarted(isDayMood)),
                    stepsGetStarted(isDayMood, seenGetStarted, ref)
                  ],
                ),
              );
            })));
  }

  Widget btnClear() {
    return Container(
      height: 75,
      alignment: Alignment.topRight,
      padding: const EdgeInsets.only(right: 15.0),
      child: IconButton(
          onPressed: () {
            navNonAuthKey.currentState!
                .pushNamedAndRemoveUntil(Welcome, (route) => false);
          },
          icon: Icon(
            Icons.clear,
            size: 30,
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
                    color: isDayMood ? cPinkBtn : cPurpleBtn,
                  ),
                  const SizedBox(
                    height: 15.0,
                  ),
                  Text(
                    "Met toi à jour quand tu le souhaites",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ],
              )),
          Expanded(
            child: Image.asset("assets/images/get_started.png"),
          ),
          Container(
              height: MediaQuery.of(context).size.height / 6,
              alignment: Alignment.center,
              child: Text(
                "Regarde, réagit et partage tes émotions à travers le contenu des jeux et utilisateurs que tu suis à chaque instant!",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
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
                    color: isDayMood ? cPinkBtn : cPurpleBtn,
                    size: 33,
                  ),
                  const SizedBox(
                    height: 15.0,
                  ),
                  Text(
                    "Met la lumière sur les dernières tendances",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              )),
          Expanded(
            child: Image.asset("assets/images/get_started.png"),
          ),
          Container(
              height: MediaQuery.of(context).size.height / 6,
              alignment: Alignment.center,
              child: Text(
                "Découvre tous les jours des nouveaux jeux mais aussi des nouveaux talents",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
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
                    Icons.videogame_asset,
                    color: isDayMood ? cPinkBtn : cPurpleBtn,
                    size: 33,
                  ),
                  const SizedBox(
                    height: 15.0,
                  ),
                  Text(
                    "Accède à tous les jeux possibles",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              )),
          Expanded(
            child: Image.asset("assets/images/get_started.png"),
          ),
          Container(
              height: MediaQuery.of(context).size.height / 6,
              alignment: Alignment.center,
              child: Text(
                "Découvre et suit des nouveaux jeux afin d'avoir toute l'actualité et le contenu possible",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
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
                    color: isDayMood ? cPinkBtn : cPurpleBtn,
                    size: 33,
                  ),
                  const SizedBox(
                    height: 15.0,
                  ),
                  Text(
                    "A ton tour!",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              )),
          Expanded(
            child: Image.asset("assets/images/get_started.png"),
          ),
          Container(
              height: MediaQuery.of(context).size.height / 6,
              alignment: Alignment.center,
              child: Text(
                "Ne sois pas timide et partage toi aussi ton contenu sur tes jeux favoris à la communauté!",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
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
                  "Passer",
                  style: TextStyle(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : Colors.black),
                )),
          ),
          TabPageSelector(
            controller: _tabController,
            selectedColor: isDayMood ? cPinkBtn : cPurpleBtn,
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
                      ? "Suivant"
                      : "Terminer",
                  style: TextStyle(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : Colors.black),
                )),
          )
        ],
      ),
    );
  }
}
