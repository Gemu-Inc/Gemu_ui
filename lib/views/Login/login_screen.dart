import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:gemu/constants/constants.dart';
import 'package:gemu/helpers/helpers.dart';
import 'package:gemu/riverpod/Theme/dayMood_provider.dart';
import 'package:gemu/views/Welcome/welcome_screen.dart';
import 'package:gemu/widgets/text_field_custom.dart';
import 'package:gemu/services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  @override
  Loginviewstate createState() => Loginviewstate();
}

class Loginviewstate extends State<LoginScreen> {
  bool isLoading = false;

  late TextEditingController _emailController;
  late TextEditingController _passwordController;

  late FocusNode _focusNodeEmail;
  late FocusNode _focusNodePassword;

  UserCredential? result;

  _signIn(String email, String password) async {
    setState(() {
      isLoading = true;
    });

    await Future.delayed(Duration(seconds: 2));

    setState(() {
      isLoading = false;
    });

    await AuthService.signIn(
        context: context, email: email, password: password);
  }

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _focusNodeEmail = FocusNode();
    _passwordController = TextEditingController();
    _focusNodePassword = FocusNode();

    _focusNodeEmail.addListener(() {
      setState(() {});
    });
    _focusNodePassword.addListener(() {
      setState(() {});
    });
  }

  @override
  void deactivate() {
    _focusNodeEmail.removeListener(() {
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
            child: GestureDetector(
              onTap: () => Helpers.hideKeyboard(context),
              child: Column(children: [
                topLoginEmail(),
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Text(
                    "Plus que ton email et ton mot de passe et c'est parti!",
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
                Expanded(child: Consumer(builder: (_, ref, child) {
                  bool isDayMood = ref.watch(dayMoodNotifierProvider);
                  return Container(
                    child: loginEmail(isDayMood),
                  );
                }))
              ]),
            )));
  }

  Widget topLoginEmail() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      child: AppBar(
        elevation: 0,
        shadowColor: Colors.transparent,
        leading: IconButton(
            onPressed: () {
              Helpers.hideKeyboard(context);
              navNonAuthKey.currentState!
                  .pushNamedAndRemoveUntil(Welcome, (route) => false);
            },
            icon: Icon(Icons.arrow_back_ios,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black,
                size: 25)),
        title: Text(
          "Connexion",
          style: Theme.of(context).textTheme.titleLarge,
        ),
        centerTitle: false,
      ),
    );
  }

  Widget loginEmail(bool isDayMood) {
    return ListView(
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 15.0),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 15.0),
          child: Container(
            height: MediaQuery.of(context).size.height / 12,
            child: TextFieldCustomLogin(
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
              isDayMood: isDayMood,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 25.0),
          child: Container(
            height: MediaQuery.of(context).size.height / 12,
            child: TextFieldCustomLogin(
              context: context,
              controller: _passwordController,
              focusNode: _focusNodePassword,
              label: 'Mot de passe',
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
              isDayMood: isDayMood,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 25.0, horizontal: 15.0),
          child: Container(
            height: MediaQuery.of(context).size.height / 14,
            child: ElevatedButton(
              onPressed: () =>
                  _signIn(_emailController.text, _passwordController.text),
              style: ElevatedButton.styleFrom(
                  elevation: 6,
                  shadowColor: Theme.of(context).shadowColor,
                  primary: isDayMood ? cPrimaryPurple : cPrimaryPink,
                  onPrimary: Theme.of(context).canvasColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  )),
              child: isLoading
                  ? SizedBox(
                      height: 15,
                      width: 15,
                      child: CircularProgressIndicator(
                          strokeWidth: 1.0,
                          color: Theme.of(context).iconTheme.color),
                    )
                  : Text(
                      'Se connecter',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
            ),
          ),
        ),
        const SizedBox(
          height: 15.0,
        ),
        RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
                text: "Mot de passe oublié",
                recognizer: TapGestureRecognizer()
                  ..onTap = () => print("Mot de passe oublié"),
                style: textStyleCustom(
                    isDayMood ? cPrimaryPurple : cPrimaryPink, 13))),
        const SizedBox(
          height: 5.0,
        ),
        RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
                text: "Vous n'avez pas encore un compte? ",
                style: Theme.of(context).textTheme.bodySmall,
                children: [
                  TextSpan(
                    text: "Inscription",
                    style: textStyleCustom(
                        isDayMood ? cPrimaryPurple : cPrimaryPink, 13),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () =>
                          Helpers.inscriptionBottomSheet(context, isDayMood),
                  )
                ])),
      ],
    );
  }
}
