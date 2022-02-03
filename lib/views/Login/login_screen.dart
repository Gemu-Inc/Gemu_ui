import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:gemu/constants/constants.dart';
import 'package:gemu/views/Register/register_screen.dart';
import 'package:gemu/views/Welcome/welcome_screen.dart';
import 'package:gemu/widgets/custom_clipper.dart';
import 'package:gemu/widgets/text_field_custom.dart';
import 'package:gemu/services/auth_service.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class LoginScreen extends StatefulWidget {
  @override
  Loginviewstate createState() => Loginviewstate();
}

class Loginviewstate extends State<LoginScreen> {
  bool isDayMood = false;
  bool isLoading = false;

  late TextEditingController _emailController;
  late TextEditingController _passwordController;

  late FocusNode _focusNodeEmail;
  late FocusNode _focusNodePassword;

  UserCredential? result;

  void timeMood() {
    int hour = DateTime.now().hour;

    if (hour >= 8 && hour <= 18) {
      setState(() {
        isDayMood = true;
      });
    } else {
      setState(() {
        isDayMood = false;
      });
    }
  }

  Future<bool> _willPopCallback() async {
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (BuildContext context) => WelcomeScreen()),
        (route) => false);
    return true;
  }

  _signIn(String email, String password) async {
    setState(() {
      isLoading = true;
    });

    await Future.delayed(Duration(seconds: 2));

    AuthService.signIn(context: context, email: email, password: password);

    setState(() {
      isLoading = false;
    });
  }

  _hideKeyboard() {
    FocusScope.of(context).unfocus();
  }

  Future _inscriptionBottomSheet() {
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
                  height: MediaQuery.of(context).size.height / 2.5,
                  decoration:
                      BoxDecoration(borderRadius: BorderRadius.circular(15.0)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 15.0, horizontal: 5.0),
                    child: Column(
                      children: [
                        Material(
                          type: MaterialType.transparency,
                          child: Text(
                            "Choississez votre type d'inscription:",
                            style: TextStyle(
                              color:
                                  Theme.of(context).brightness == Brightness.dark
                                      ? Colors.white
                                      : Colors.black,
                              fontSize: 15.0,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 25.0),
                              child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                              Container(
                                  height: 50,
                                  width: MediaQuery.of(context).size.width,
                                  child: ElevatedButton(
                                      onPressed: () {
                                        print("inscription avec google");
                                      },
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          Icon(MdiIcons.google, color: Colors.black,),
                                          const SizedBox(width: 15.0,),
                                          Text(
                                          "S'inscrire' avec Google", textAlign: TextAlign.center,)
                                        ],
                                      ))),
                              Container(
                                  height: 50,
                                  width: MediaQuery.of(context).size.width,
                                  child: ElevatedButton(
                                      onPressed: () {
                                        print("inscription avec apple");
                                      },
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          Icon(MdiIcons.apple, color: Colors.black,),
                                          const SizedBox(width: 15.0,),
                                          Text(
                                          "S'inscrire avec Apple", textAlign: TextAlign.center,)
                                        ],
                                      ))),
                              Container(
                                  height: 50,
                                  width: MediaQuery.of(context).size.width,
                                  child: ElevatedButton(
                                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => RegisterScreen())),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          Icon(Icons.mail),
                                          const SizedBox(width: 15.0,),
                                          Text(
                                          "S'inscrire avec une adresse mail", textAlign: TextAlign.center,)
                                        ],
                                      )))
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
                  height: MediaQuery.of(context).size.height / 3,
                  decoration:
                      BoxDecoration(borderRadius: BorderRadius.circular(15.0)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 15.0, horizontal: 5.0),
                    child: Column(
                      children: [
                        Material(
                          type: MaterialType.transparency,
                          child: Text(
                            "Choississez votre type d'inscription:",
                            style: TextStyle(
                              color:
                                  Theme.of(context).brightness == Brightness.dark
                                      ? Colors.white
                                      : Colors.black,
                              fontSize: 15.0,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 25.0),
                              child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                              Container(
                                  height: 50,
                                  width: MediaQuery.of(context).size.width,
                                  child: ElevatedButton(
                                      onPressed: () {
                                        print("inscription avec google");
                                      },
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          Icon(MdiIcons.google, color: Colors.black,),
                                          const SizedBox(width: 15.0,),
                                          Text(
                                          "S'inscrire avec Google", textAlign: TextAlign.center,)
                                        ],
                                      ))),
                              Container(
                                  height: 50,
                                  width: MediaQuery.of(context).size.width,
                                  child: ElevatedButton(
                                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => RegisterScreen())),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          Icon(Icons.mail),
                                          const SizedBox(width: 15.0,),
                                          Text(
                                          "S'inscrire avec une adresse mail", textAlign: TextAlign.center,)
                                        ],
                                      )))
                          ],
                        ),
                            ))
                      ],
                    ),
                  ));
            });
  }

  @override
  void initState() {
    super.initState();
    timeMood();
    _emailController = TextEditingController();
    _focusNodeEmail = FocusNode();
    _passwordController = TextEditingController();
    _focusNodePassword = FocusNode();

    _emailController.addListener(() {
      setState(() {});
    });
    _passwordController.addListener(() {
      setState(() {});
    });
    _focusNodeEmail.addListener(() {
      setState(() {});
    });
    _focusNodePassword.addListener(() {
      setState(() {});
    });
  }

  @override
  void deactivate() {
    _emailController.removeListener(() {
      setState(() {});
    });
    _focusNodeEmail.removeListener(() {
      setState(() {});
    });
    _passwordController.removeListener(() {
      setState(() {});
    });
    _focusNodePassword.removeListener(() {
      setState(() {});
    });
    super.deactivate();
  }

  @override
  void dispose() {
    _focusNodeEmail.dispose();
    _focusNodePassword.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<Color> lightBgColors = [
      Color(0xFF947B8F),
      Color(0xFFB27D75),
      Color(0xFFE38048),
    ];
    List<Color> darkBgColors = [
      Color(0xFF4075DA),
      Color(0xFF6E78B1),
      Color(0xFF947B8F),
    ];

    return WillPopScope(
        child: Scaffold(
            body: AnnotatedRegion<SystemUiOverlayStyle>(
                value: SystemUiOverlayStyle(
                    statusBarColor: Colors.transparent,
                    statusBarIconBrightness:
                        Theme.of(context).brightness == Brightness.dark
                            ? Brightness.light
                            : Brightness.dark),
                child: GestureDetector(
                  onTap: () => _hideKeyboard(),
                  child: LayoutBuilder(builder: (_, constraints) {
                    return SingleChildScrollView(
                      child: ConstrainedBox(
                        constraints:
                            BoxConstraints(minHeight: constraints.maxHeight),
                        child: IntrinsicHeight(
                          child: Column(children: [
                            Container(
                                height:
                                    MediaQuery.of(context).size.height / 2.25,
                                child: topLogin(lightBgColors, darkBgColors)),
                            Expanded(
                                child: bodyLogin(lightBgColors, darkBgColors)),
                          ]),
                        ),
                      ),
                    );
                  }),
                ))),
        onWillPop: () => _willPopCallback());
  }

  topLogin(List<Color> lightBgColors, List<Color> darkBgColors) {
    return Stack(
      children: [
        ClipPath(
          clipper: MyClipper(),
          child: Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isDayMood ? lightBgColors : darkBgColors)),
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: MediaQuery.of(context).size.height / 10,
              alignment: Alignment.bottomLeft,
              padding:
                  const EdgeInsets.symmetric(horizontal: 15.0, vertical: 5.0),
              child: Container(
                child: InkWell(
                  onTap: () {
                    _hideKeyboard();
                    Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (BuildContext context) => WelcomeScreen()),
                        (route) => false);
                  },
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(Icons.arrow_back_ios,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : Colors.black,
                          size: 25),
                      Text(
                        "Retour",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white
                                    : Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 19),
                      )
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
                flex: 2,
                child: Container(
                  width: MediaQuery.of(context).size.width / 1.5,
                  alignment: Alignment.bottomCenter,
                  padding:
                      EdgeInsets.symmetric(horizontal: 5.0, vertical: 15.0),
                  child: Text(
                    "Connexion",
                    style: TextStyle(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 36),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                  ),
                )),
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 20),
                      child: Image.asset("assets/images/gameuse.png"),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 75),
                      child: Image.asset("assets/images/gamer.png"),
                    ),
                  ),
                ],
              ),
            )
          ],
        )
      ],
    );
  }

  bodyLogin(List<Color> lightBgColors, List<Color> darkBgColors) {
    return loginEmail();
  }

  Widget loginEmail() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Column(
        children: [
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 25.0, vertical: 15.0),
            child: Container(
              height: MediaQuery.of(context).size.height / 12,
              child: TextFieldCustom(
                context: context,
                controller: _emailController,
                focusNode: _focusNodeEmail,
                label: 'Email',
                obscure: false,
                icon: Icons.mail,
                textInputAction: TextInputAction.next,
                textInputType: TextInputType.emailAddress,
                clear: () {
                  setState(() {
                    _emailController.clear();
                  });
                },
                submit: (value) {
                  value = _emailController.text;
                  _focusNodeEmail.unfocus();
                  FocusScope.of(context).requestFocus(_focusNodePassword);
                },
              ),
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 25.0, vertical: 15.0),
            child: Container(
              height: MediaQuery.of(context).size.height / 12,
              child: TextFieldCustom(
                context: context,
                controller: _passwordController,
                focusNode: _focusNodePassword,
                label: 'Password',
                obscure: true,
                icon: Icons.lock,
                textInputAction: TextInputAction.go,
                clear: () {
                  setState(() {
                    _passwordController.clear();
                  });
                },
                submit: (value) {
                  value = _passwordController.text;
                  _focusNodePassword.unfocus();
                  _signIn(_emailController.text, value);
                },
              ),
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 45.0, vertical: 15.0),
            child: Container(
              height: MediaQuery.of(context).size.height / 15,
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 10.0),
              child: ElevatedButton(
                onPressed: () =>
                    _signIn(_emailController.text, _passwordController.text),
                style: ElevatedButton.styleFrom(
                    elevation: 6,
                    shadowColor: Theme.of(context).shadowColor,
                    primary: Theme.of(context).canvasColor,
                    onPrimary: Theme.of(context).primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    )),
                child: isLoading
                    ? SizedBox(
                        height: 15,
                        width: 15,
                        child: CircularProgressIndicator(
                          strokeWidth: 1.0,
                          color:
                              Theme.of(context).brightness == Brightness.dark
                                  ? Colors.white
                                  : Colors.black,
                        ),
                      )
                    : Text(
                        'Login',
                        style: TextStyle(
                            color: Theme.of(context).brightness ==
                                    Brightness.dark
                                ? Colors.white
                                : Colors.black,
                            fontSize: 15,
                            fontWeight: FontWeight.w700),
                      ),
              ),
            ),
          ),
          Expanded(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              InkWell(
                onTap: () => print("mot de passe oublié"),
                child: Text(
                  'Mot de passe oublié',
                  style: mystyle(12, Theme.of(context).primaryColor),
                ),
              ),
              const SizedBox(height: 15.0,),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Vous n'avez pas encore un compte?",
                    style: mystyle(12),
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  InkWell(
                    onTap: () => _inscriptionBottomSheet(),
                    child: Text(
                      'Inscription',
                      style: mystyle(12, Theme.of(context).primaryColor),
                    ),
                  )
                ],
              ),
            ],
          ))
        ],
      ),
    );
  }
}
