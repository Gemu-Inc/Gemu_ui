import 'package:flutter/material.dart';
import 'package:Gemu/Screens/Login/login_screen.dart';
import 'package:Gemu/Screens/Signup/components/background.dart';
// import 'package:Gemu/Screens/Signup/components/or_divider.dart';
// import 'package:Gemu/Screens/Signup/components/social_icon.dart';
import 'package:Gemu/components/already_have_an_account_acheck.dart';
import 'package:Gemu/components/rounded_button.dart';
import 'package:Gemu/components/rounded_input_field.dart';
import 'package:Gemu/components/rounded_password_field.dart';
import 'package:flutter_svg/svg.dart';
import 'package:Gemu/screens/Welcome/components/authentication_service.dart';
import 'package:provider/provider.dart';

class Body extends StatelessWidget {
  String emailController = '';
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Background(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              "SIGNUP",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            SizedBox(height: size.height * 0.03),
            SvgPicture.asset(
              "lib/assets/icons/signup.svg",
              height: size.height * 0.35,
            ),
            RoundedInputField(
              hintText: "Your Email",
              onChanged: (value) {
                emailController = value;
              },
            ),
            RoundedPasswordField(
              onChanged: (value) {},
            ),
            RoundedButton(
              text: "SIGNUP",
              press: () async {
                  await context.read<AuthenticationService>().signInorUpEmailLink(email: emailController);
              },
            ),
            SizedBox(height: size.height * 0.03),
            AlreadyHaveAnAccountCheck(
              login: false,
              press: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return LoginScreen();
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
