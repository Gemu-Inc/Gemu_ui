import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gradient_app_bar/gradient_app_bar.dart';

import 'package:Gemu/screensmodels/Reglages/edit_email_screen_model.dart';

class EditEmailScreen extends StatefulWidget {
  EditEmailScreen({Key key}) : super(key: key);

  @override
  _EditEmailScreenState createState() => _EditEmailScreenState();
}

class _EditEmailScreenState extends State<EditEmailScreen> {
  final _formKeyMail = GlobalKey<FormState>();
  final _formKeyPassword = GlobalKey<FormState>();
  final _firebaseAuth = FirebaseAuth.instance;
  var currentUser;
  String _currentEmail;
  String _currentPassword;

  @override
  void initState() {
    super.initState();
    currentUser = _firebaseAuth.currentUser.uid;
  }

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<EditEmailScreenModel>.reactive(
      viewModelBuilder: () => EditEmailScreenModel(),
      builder: (context, model, child) => Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: GradientAppBar(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).primaryColor,
              Theme.of(context).accentColor
            ],
          ),
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'Changer l\'adresse mail',
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
                    child: StreamBuilder(
                        stream: FirebaseFirestore.instance
                            .collection('users')
                            .doc(currentUser)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            return TextFormField(
                              initialValue: snapshot.data['email'],
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
                                                    Navigator.pop(context);
                                                    await model.updateUserEmail(
                                                        _currentPassword,
                                                        _currentEmail,
                                                        currentUser);
                                                    model
                                                        .navigateToEditProfile();
                                                  },
                                                  child: Text('OK'))
                                            ]));
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
