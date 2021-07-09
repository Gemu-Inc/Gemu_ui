import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:gemu/services/auth_service.dart';
import 'package:gemu/services/database_service.dart';
import 'package:gemu/models/user.dart';
import 'package:gemu/ui/widgets/alert_dialog_custom.dart';

class EditEmailScreen extends StatefulWidget {
  final UserModel user;

  const EditEmailScreen({Key? key, required this.user}) : super(key: key);

  @override
  _EditEmailScreenState createState() => _EditEmailScreenState();
}

class _EditEmailScreenState extends State<EditEmailScreen> {
  final _formKeyMail = GlobalKey<FormState>();
  final _formKeyPassword = GlobalKey<FormState>();

  String? _currentEmail;
  late String _currentPassword;

  Future updateUserEmail(
      {required String password, required String newEmail}) async {
    try {
      String? email = FirebaseAuth.instance.currentUser!.email;
      AuthCredential authCredential =
          EmailAuthProvider.credential(email: email!, password: password);
      UserCredential authResult = await FirebaseAuth.instance.currentUser!
          .reauthenticateWithCredential(authCredential);
      await authResult.user!.updateEmail(newEmail);
      await DatabaseService.updateUserEmail(newEmail, widget.user.uid);
      alertUpdateMail(
          'Email successfully updated', 'Your email has been changed');
    } on FirebaseAuthException catch (e) {
      return alertUpdateMail('Could not change email', 'Try again');
    }
  }

  Future alertReAuthentification() {
    return showDialog(
        context: context,
        builder: (context) => AlertDialog(
                backgroundColor: Theme.of(context).canvasColor,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.0)),
                title: Text('Re-Authentification'),
                content: Form(
                  key: _formKeyPassword,
                  child: TextFormField(
                      decoration: InputDecoration(labelText: "Password"),
                      obscureText: true,
                      validator: (value) =>
                          value!.isEmpty ? 'Please enter a password' : null,
                      onChanged: (value) =>
                          setState(() => _currentPassword = value)),
                ),
                actions: [
                  TextButton(
                      onPressed: () async {
                        _hideKeyboard();
                        Navigator.pop(context);
                        await updateUserEmail(
                            password: _currentPassword,
                            newEmail: _currentEmail!);
                      },
                      child: Text(
                        'OK',
                        style: TextStyle(color: Colors.blue[200]),
                      )),
                  TextButton(
                      onPressed: () {
                        _hideKeyboard();
                        Navigator.pop(context);
                      },
                      child: Text(
                        'Cancel',
                        style: TextStyle(color: Colors.red[200]),
                      )),
                ]));
  }

  Future alertUpdateMail(String title, String content) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialogCustom(context, title, content, [
            TextButton(
                onPressed: () {
                  Navigator.popUntil(
                      context, ModalRoute.withName('/EditProfile'));
                },
                child: Text(
                  'OK',
                  style: TextStyle(color: Colors.blue[200]),
                ))
          ]);
        });
  }

  Future alertSaveBeforeLeave() {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialogCustom(context, 'Sauvegarder',
              'Voulez-vous sauvegarder vos changements?', [
            TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  alertReAuthentification();
                },
                child: Text(
                  'Save',
                  style: TextStyle(color: Colors.blue[200]),
                )),
            TextButton(
                onPressed: () {
                  Navigator.popUntil(
                      context, ModalRoute.withName('/EditProfile'));
                },
                child: Text(
                  'Leave',
                  style: TextStyle(color: Colors.red[200]),
                ))
          ]);
        });
  }

  _hideKeyboard() {
    FocusScope.of(context).requestFocus(FocusNode());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                Theme.of(context).primaryColor,
                Theme.of(context).accentColor
              ])),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
          ),
          onPressed: () async {
            _hideKeyboard();
            if (_currentEmail != null) {
              alertSaveBeforeLeave();
            } else {
              Navigator.pop(context);
            }
          },
        ),
        title: Text(
          'Email',
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
                  child: TextFormField(
                    initialValue: widget.user.email,
                    validator: (value) =>
                        value!.isEmpty ? 'Please enter a mail' : null,
                    onChanged: (value) => setState(() => _currentEmail = value),
                  )),
            ),
            Align(
                alignment: Alignment.bottomRight,
                child: Container(
                  margin: EdgeInsets.only(right: 16.0, bottom: 16.0),
                  child: _currentEmail == null
                      ? SizedBox()
                      : FloatingActionButton(
                          onPressed: () async {
                            if (_formKeyMail.currentState!.validate()) {
                              _hideKeyboard();
                              alertReAuthentification();
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
    );
  }
}
