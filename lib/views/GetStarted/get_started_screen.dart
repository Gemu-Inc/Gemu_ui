import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gemu/providers/dayMood_provider.dart';

import 'package:gemu/constants/constants.dart';
import 'package:gemu/views/Welcome/welcome_screen.dart';

class GetStartedBeforeScreen extends StatefulWidget {
  @override
  _GetStartedBeforeScreenState createState() => _GetStartedBeforeScreenState();
}

class _GetStartedBeforeScreenState extends State<GetStartedBeforeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: AnnotatedRegion<SystemUiOverlayStyle>(
          child: Consumer(builder: (_, ref, child) {
            bool isDayMood = ref.watch(dayMoodNotifierProvider);
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [btnStart(isDayMood)],
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

  Widget btnStart(bool isDayMood) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
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
            Navigator.push(
                context, MaterialPageRoute(builder: (_) => GetStartedScreen()));
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
                fontSize: 15,
                fontWeight: FontWeight.w700),
          ),
        ),
      ),
    );
  }
}

class GetStartedScreen extends StatefulWidget {
  @override
  _GetStartedScreenState createState() => _GetStartedScreenState();
}

class _GetStartedScreenState extends State<GetStartedScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int lengthGetStarted = 3;

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
              return Column(
                children: [
                  Expanded(child: bodyGetStarted()),
                  stepsGetStarted(isDayMood)
                ],
              );
            })));
  }

  Widget bodyGetStarted() {
    return TabBarView(
        controller: _tabController,
        physics: AlwaysScrollableScrollPhysics(),
        children: [Container(), Container(), Container()]);
  }

  Widget stepsGetStarted(bool isDayMood) {
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
                  setState(() {
                    if (_tabController.index != lengthGetStarted - 1) {
                      setState(() {
                        _tabController.index = 2;
                      });
                    }
                  });
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
                onPressed: () {
                  if (_tabController.index != lengthGetStarted - 1) {
                    setState(() {
                      _tabController.index += 1;
                    });
                  } else {
                    Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => WelcomeScreen()),
                        (route) => false);
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
