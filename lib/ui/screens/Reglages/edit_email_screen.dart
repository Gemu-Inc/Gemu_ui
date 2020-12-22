import 'package:Gemu/screensmodels/Reglages/edit_email_screen_model.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:Gemu/models/user.dart';

class EditEmailScreen extends StatefulWidget {
  EditEmailScreen({Key key}) : super(key: key);

  @override
  _EditEmailScreenState createState() => _EditEmailScreenState();
}

class _EditEmailScreenState extends State<EditEmailScreen> {
  final _formKeyMail = GlobalKey<FormState>();
  final _formKeyPassword = GlobalKey<FormState>();
  String _currentEmail;
  String _currentPassword;

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<EditEmailScreenModel>.reactive(
      viewModelBuilder: () => EditEmailScreenModel(),
      builder: (context, model, child) => Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black26,
          elevation: 0.0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              color: Colors.grey,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'Changer l\'adresse mail',
            style: TextStyle(color: Colors.grey),
          ),
        ),
        body: Form(
          key: _formKeyMail,
          child: Stack(
            children: [
              Align(
                alignment: Alignment.topCenter,
                child: Container(
                    margin: EdgeInsets.only(top: 20.0),
                    height: 60,
                    width: MediaQuery.of(context).size.width - 130.0,
                    color: Colors.transparent,
                    child: StreamBuilder<UserC>(
                        stream: model.userData,
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            UserC _userC = snapshot.data;
                            return TextFormField(
                              initialValue: _userC.email,
                              validator: (value) =>
                                  value.isEmpty ? 'Please enter a mail' : null,
                              onChanged: (value) =>
                                  setState(() => _currentEmail = value),
                            );
                          } else {
                            return CircularProgressIndicator();
                          }
                        })),
              ),
              Align(
                  alignment: Alignment.bottomRight,
                  child: Container(
                    margin: EdgeInsets.only(right: 16.0, bottom: 16.0),
                    child: _currentEmail == null
                        ? SizedBox()
                        : FloatingActionButton(
                            onPressed: () async {
                              if (_formKeyMail.currentState.validate()) {
                                showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                            title: Text('Re-Authentification'),
                                            content: Form(
                                              key: _formKeyPassword,
                                              child: TextFormField(
                                                  decoration: InputDecoration(
                                                      labelText: "Password"),
                                                  obscureText: true,
                                                  validator: (value) => value
                                                          .isEmpty
                                                      ? 'Please enter a password'
                                                      : null,
                                                  onChanged: (value) =>
                                                      setState(() =>
                                                          _currentPassword =
                                                              value)),
                                            ),
                                            actions: [
                                              FlatButton(
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                  },
                                                  child: Text('Cancel')),
                                              FlatButton(
                                                  onPressed: () async {
                                                    await model.updateUserEmail(
                                                        _currentPassword,
                                                        _currentEmail);
                                                    Navigator.pop(context);
                                                  },
                                                  child: Text('OK'))
                                            ]));
                                print("Email updated");
                              }
                            },
                            child: Stack(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            Theme.of(context).primaryColor,
                                            Theme.of(context).accentColor
                                          ])),
                                ),
                                Align(
                                  alignment: Alignment.center,
                                  child: Icon(
                                    Icons.save,
                                    size: 25,
                                  ),
                                )
                              ],
                            ),
                          ),
                  ))
            ],
          ),
        ),
      ),
    );
  }
}
