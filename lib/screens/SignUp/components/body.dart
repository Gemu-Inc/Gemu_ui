import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  TextEditingController _nameController = new TextEditingController();
  TextEditingController _emailController = new TextEditingController();
  TextEditingController _passwordController = new TextEditingController();
  TextEditingController _repasswordController = new TextEditingController();
  /*String _emailController = '';
  String _nameController = '';*/
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
            /*RoundedInputField(
              hintText: "Your Email",
              onChanged: (value) {
                _emailController = value;
              },
            ),
            RoundedInputField(
              hintText: "Your Name",
              onChanged: (value) {
                _nameController = value;
              },
            ),*/
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: "Name: "),
            ),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: "Email: "),
            ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: "Password: "),
            ),
            TextField(
              controller: _repasswordController,
              decoration: const InputDecoration(labelText: "RePassword: "),
            ),
            RoundedButton(
                text: "SIGNUP",
                press: () async {
                  try {
                    User user = (await FirebaseAuth.instance
                            .createUserWithEmailAndPassword(
                                email: _emailController.text,
                                password: _passwordController.text))
                        .user;
                    await CloudFunctions.instance
                        .getHttpsCallable(functionName: "addUser")
                        .call({
                      "email": _emailController.text,
                      "name": _nameController.text,
                    });
                    print('okkkkkk');
                  } catch (e) {
                    print(e);
                    _nameController.text = "";
                    _emailController.text = "";
                    _passwordController.text = "";
                    _repasswordController.text = "";
                  }
                  /*CloudFunctions.instance
                      .getHttpsCallable(functionName: "addUser")
                      .call({
                    "name": _nameController,
                    "email": _emailController,
                  });*/
                }),
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
