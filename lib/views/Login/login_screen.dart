import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:email_validator/email_validator.dart';

import 'package:gemu/constants/constants.dart';
import 'package:gemu/helpers/helpers.dart';
import 'package:gemu/riverpod/Theme/dayMood_provider.dart';
import 'package:gemu/widgets/text_field_custom.dart';
import 'package:gemu/services/auth_service.dart';
import 'package:gemu/riverpod/Login/login_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  @override
  Loginviewstate createState() => Loginviewstate();
}

class Loginviewstate extends ConsumerState<LoginScreen> {
  late TextEditingController _emailController;
  late TextEditingController _passwordController;

  late FocusNode currentFocus;
  late FocusNode _focusNodeEmail;
  late FocusNode _focusNodePassword;

  bool isCompleted = false;

  @override
  void initState() {
    super.initState();

    _emailController = TextEditingController();
    _focusNodeEmail = FocusNode();
    _passwordController = TextEditingController();
    _focusNodePassword = FocusNode();

    _emailController.addListener(() {
      if (_emailController.text.trim().isNotEmpty &&
          EmailValidator.validate(_emailController.text)) {
        ref.read(emailValidLoginNotifierProvider.notifier).updateValidity(true);
      } else {
        ref
            .read(emailValidLoginNotifierProvider.notifier)
            .updateValidity(false);
      }
    });
    _passwordController.addListener(() {
      if (_passwordController.text.trim().isNotEmpty) {
        ref
            .read(passwordValidLoginNotifierProvider.notifier)
            .updateValidity(true);
      } else {
        ref
            .read(passwordValidLoginNotifierProvider.notifier)
            .updateValidity(false);
      }
    });
  }

  @override
  void deactivate() {
    _emailController.removeListener(() {
      if (_emailController.text.trim().isNotEmpty &&
          EmailValidator.validate(_emailController.text)) {
        ref.read(emailValidLoginNotifierProvider.notifier).updateValidity(true);
      } else {
        ref
            .read(emailValidLoginNotifierProvider.notifier)
            .updateValidity(false);
      }
    });
    _passwordController.removeListener(() {
      if (_passwordController.text.trim().isNotEmpty) {
        ref
            .read(passwordValidLoginNotifierProvider.notifier)
            .updateValidity(true);
      } else {
        ref
            .read(passwordValidLoginNotifierProvider.notifier)
            .updateValidity(false);
      }
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
    currentFocus = FocusScope.of(context);
    final isLoading = ref.watch(loadingLoginNotifierProvider);
    final isDayMood = ref.watch(dayMoodNotifierProvider);
    final creationComplete = ref.watch(loginCompleteProvider);
    if (creationComplete.asData != null) {
      isCompleted = creationComplete.asData!.value;
    }
    return Scaffold(
        resizeToAvoidBottomInset: true,
        body: GestureDetector(
          onTap: () => Helpers.hideKeyboard(context),
          child: Column(children: [
            topLoginEmail(),
            Expanded(
              child: loginEmail(isDayMood, isLoading),
            )
          ]),
        ));
  }

  Widget topLoginEmail() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      child: AppBar(
        elevation: 0,
        shadowColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            systemNavigationBarColor: Theme.of(context).scaffoldBackgroundColor,
            statusBarIconBrightness:
                Theme.of(context).brightness == Brightness.dark
                    ? Brightness.light
                    : Brightness.dark,
            systemNavigationBarIconBrightness:
                Theme.of(context).brightness == Brightness.dark
                    ? Brightness.light
                    : Brightness.dark),
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

  Widget loginEmail(bool isDayMood, bool isLoading) {
    return ListView(
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 25.0),
      physics: AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
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
              changed: (value) {
                setState(() {
                  value = _emailController.text;
                });
              },
              submit: (value) {
                value = _emailController.text;
                currentFocus.unfocus();
                currentFocus.requestFocus(_focusNodePassword);
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
              changed: (value) {
                setState(() {
                  value = _passwordController.text;
                });
              },
              submit: (value) async {
                value = _passwordController.text;
                _focusNodePassword.unfocus();
                if (isCompleted) {
                  ref
                      .read(loadingLoginNotifierProvider.notifier)
                      .updateLoader();
                  await AuthService.signIn(
                      context: context,
                      email: _emailController.text,
                      password: _passwordController.text);
                  if (mounted) {
                    ref
                        .read(loadingLoginNotifierProvider.notifier)
                        .updateLoader();
                  }
                }
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
              onPressed: () async {
                if (isCompleted) {
                  ref
                      .read(loadingLoginNotifierProvider.notifier)
                      .updateLoader();
                  await AuthService.signIn(
                      context: context,
                      email: _emailController.text,
                      password: _passwordController.text);
                  if (mounted) {
                    ref
                        .read(loadingLoginNotifierProvider.notifier)
                        .updateLoader();
                  }
                }
              },
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
