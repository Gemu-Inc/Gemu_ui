import 'package:Gemu/screensmodels/Login/login_screen_model.dart';
import 'package:Gemu/ui/widgets/busy_button.dart';
import 'package:flutter/material.dart';
import 'package:gradient_app_bar/gradient_app_bar.dart';
import 'package:stacked/stacked.dart';

class LoginScreen extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    String _email;
    String _password;
    return ViewModelBuilder<LoginScreenModel>.reactive(
        viewModelBuilder: () => LoginScreenModel(),
        builder: (context, model, child) => Scaffold(
              backgroundColor: Color(0xFF1A1C25),
              appBar: GradientAppBar(
                gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Theme.of(context).primaryColor,
                      Theme.of(context).accentColor
                    ]),
                title: Text("Sign In"),
              ),
              body: Container(
                padding: EdgeInsets.all(20.0),
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      children: <Widget>[
                        SizedBox(height: 20.0),
                        TextFormField(
                          style: Theme.of(context).textTheme.bodyText1,
                          keyboardType: TextInputType.emailAddress,
                          decoration:
                              InputDecoration(labelText: "Email Address"),
                          onSaved: (value) => _email = value,
                          validator: (String value) {
                            if (value.isEmpty) {
                              return 'Please enter an email';
                            }
                            if (!value.contains('@')) {
                              return 'Please enter a valid email';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 20.0),
                        TextFormField(
                          style: Theme.of(context).textTheme.bodyText1,
                          validator: (String value) {
                            if (value.isEmpty) {
                              return 'Please enter a password';
                            }
                            return null;
                          },
                          obscureText: true,
                          decoration: InputDecoration(labelText: "Password"),
                          onSaved: (value) => _password = value,
                        ),
                        SizedBox(height: 40.0),
                        Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16.0),
                            child: BusyButton(
                                title: "SIGN IN",
                                onPressed: () {
                                  final form = _formKey.currentState;
                                  form.save();

                                  if (form.validate()) {
                                    print('Form was successfully validated');
                                    model.login(
                                        email: _email, password: _password);
                                  }
                                })),
                      ],
                    ),
                  ),
                ),
              ),
            ));
  }
}
