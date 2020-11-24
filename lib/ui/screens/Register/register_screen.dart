import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:Gemu/screensmodels/Register/register_screen_model.dart';
import 'package:gradient_app_bar/gradient_app_bar.dart';
import 'package:Gemu/ui/widgets/busy_button.dart';

class RegisterScreen extends StatelessWidget {
  final _registerFormKey = GlobalKey<FormState>();

  String _pseudo;
  String _email;
  String _password;

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<RegisterScreenModel>.reactive(
        viewModelBuilder: () => RegisterScreenModel(),
        builder: (context, model, child) => Scaffold(
              appBar: GradientAppBar(
                gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Theme.of(context).primaryColor,
                      Theme.of(context).accentColor
                    ]),
                title: Text('Register'),
              ),
              body: Container(
                padding: EdgeInsets.all(20.0),
                child: Form(
                    key: _registerFormKey,
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          SizedBox(
                            height: 20.0,
                          ),
                          TextFormField(
                            validator: (String value) {
                              if (value.isEmpty) {
                                return 'Please enter a name';
                              }
                              return null;
                            },
                            decoration: InputDecoration(labelText: "Pseudo"),
                            onSaved: (value) => _pseudo = value,
                          ),
                          SizedBox(
                            height: 20.0,
                          ),
                          TextFormField(
                            validator: (String value) {
                              if (value.isEmpty) {
                                return 'Please enter an email';
                              }
                              if (!value.contains('@')) {
                                return 'Please enter a valid email';
                              }
                              return null;
                            },
                            decoration:
                                InputDecoration(labelText: "Email Adress"),
                            keyboardType: TextInputType.emailAddress,
                            onSaved: (value) => _email = value,
                          ),
                          SizedBox(
                            height: 20.0,
                          ),
                          TextFormField(
                            validator: (String value) {
                              if (value.isEmpty) {
                                return "Please enter a password";
                              }
                              if (value.length < 6) {
                                return 'Password should be at least 6 characters';
                              }
                              return null;
                            },
                            decoration: InputDecoration(labelText: "Password"),
                            obscureText: true,
                            onSaved: (value) => _password = value,
                          ),
                          SizedBox(
                            height: 40.0,
                          ),
                          Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16.0),
                              child: BusyButton(
                                  title: "SIGN UP",
                                  busy: model.busy,
                                  onPressed: () {
                                    final form = _registerFormKey.currentState;
                                    form.save();
                                    if (form.validate()) {
                                      print('Form was successfully validated');
                                      model.signUp(
                                          pseudo: _pseudo,
                                          email: _email,
                                          password: _password);
                                    } else {
                                      print(
                                          'Form was not successfully validated');
                                    }
                                  })),
                        ],
                      ),
                    )),
              ),
            ));
  }
}
