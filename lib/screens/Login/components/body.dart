import 'package:Gemu/screens/nav_screen.dart';
import 'package:Gemu/screens/principal_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:Gemu/Screens/Login/components/background.dart';
import 'package:Gemu/Screens/Signup/signup_screen.dart';
import 'package:Gemu/components/already_have_an_account_acheck.dart';
import 'package:Gemu/components/rounded_button.dart';
import 'package:Gemu/components/rounded_input_field.dart';
import 'package:Gemu/components/rounded_password_field.dart';
import 'package:flutter_svg/svg.dart';
import 'package:Gemu/screens/Welcome/components/authentication_service.dart';

class Body extends StatelessWidget {
  // const Body({
  //   Key key,
  // }) : super(key: key);
  String emailController = '';
  String passwordController = '';

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Background(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              "LOGIN",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            SizedBox(height: size.height * 0.03),
            SvgPicture.asset(
              "lib/assets/icons/login.svg",
              height: size.height * 0.35,
            ),
            SizedBox(height: size.height * 0.03),
            RoundedInputField(
              hintText: "Your Email",
              onChanged: (value) {
                emailController = value;
              },
            ),
            RoundedPasswordField(
              onChanged: (value) {
                passwordController = value;
              },
              onSubmitted: (value) async {
                String result =
                    await context.read<AuthenticationService>().signIn(
                          email: emailController,
                          password: passwordController,
                        );
                if (result == 'Signed in') {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return PrincipalScreen();
                  }));
                } else {
                  showDialog(
                    context: context,
                    builder: (_) => CupertinoAlertDialog(
                      title: Text("Erreur"),
                      content: Text("Merci de vérifier les identifiants"),
                      actions: [
                        CupertinoDialogAction(
                            child: Text(
                              'Ok',
                              style: TextStyle(color: Colors.red),
                            ),
                            onPressed: () {
                              Navigator.of(context).pop();
                            }),
                      ],
                    ),
                  );
                }
              },
            ),
            RoundedButton(
              text: "LOGIN",
              press: () async {
                String result =
                    await context.read<AuthenticationService>().signIn(
                          email: emailController,
                          password: passwordController,
                        );
                if (result == 'Signed in') {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return NavScreen();
                  }));
                } else {
                  showDialog(
                    context: context,
                    builder: (_) => CupertinoAlertDialog(
                      title: Text("Erreur"),
                      content: Text("Merci de vérifier les identifiants"),
                      actions: [
                        CupertinoDialogAction(
                            child: Text(
                              'Ok',
                              style: TextStyle(color: Colors.blue),
                            ),
                            onPressed: () {
                              Navigator.of(context).pop();
                            }),
                      ],
                    ),
                  );
                }
              },
            ),
            SizedBox(height: size.height * 0.03),
            AlreadyHaveAnAccountCheck(
              press: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return SignUpScreen();
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
