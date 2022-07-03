import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:gemu/components/alert_dialog_custom.dart';
import 'package:gemu/constants/constants.dart';

class EditPasswordScreen extends StatefulWidget {
  EditPasswordScreen({Key? key}) : super(key: key);

  @override
  _EditPasswordviewstate createState() => _EditPasswordviewstate();
}

class _EditPasswordviewstate extends State<EditPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _currentPassword;
  String? _newPassword;

  Future updatePassword(
      {required String currentPassword, required String newPassword}) async {
    try {
      String? email = FirebaseAuth.instance.currentUser!.email;
      AuthCredential credential = EmailAuthProvider.credential(
          email: email!, password: currentPassword);
      UserCredential authResult = await FirebaseAuth.instance.currentUser!
          .reauthenticateWithCredential(credential);
      await authResult.user!.updatePassword(newPassword);
      alertUpdatePassword(
          'Password successfully updated', 'Your password has been changed');
    } on FirebaseAuthException catch (e) {
      print(e);
      return alertUpdatePassword('Could not change password', 'Try again');
    }
  }

  Future alertUpdatePassword(String title, String content) {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialogCustom(context, title, content, [
            TextButton(
                onPressed: () {
                  Navigator.popUntil(
                      context, ModalRoute.withName('/EditProfile'));
                },
                child: Text(
                  'OK',
                  style: TextStyle(color: cGreenConfirm),
                ))
          ]);
        });
  }

  Future alertSaveBeforeLeave() {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialogCustom(context, 'Sauvegarder',
              'Voulez-vous sauvegarder vos changements?', [
            TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  updatePassword(
                      currentPassword: _currentPassword!,
                      newPassword: _newPassword!);
                },
                child: Text(
                  'Save',
                  style: TextStyle(color: cGreenConfirm),
                )),
            TextButton(
                onPressed: () {
                  Navigator.popUntil(
                      context, ModalRoute.withName('/EditProfile'));
                },
                child: Text(
                  'Leave',
                  style: TextStyle(color: cRedCancel),
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
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.secondary
              ])),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
          ),
          onPressed: () {
            _hideKeyboard();
            if (_currentPassword != null && _newPassword != null) {
              alertSaveBeforeLeave();
            } else {
              Navigator.pop(context);
            }
          },
        ),
        title: Text(
          'Password',
        ),
      ),
      body: Form(
          key: _formKey,
          child: Stack(
            children: [
              Container(
                margin: EdgeInsets.only(
                    top: 20.0,
                    left: MediaQuery.of(context).size.width / 4,
                    right: MediaQuery.of(context).size.width / 4),
                color: Colors.transparent,
                width: MediaQuery.of(context).size.width - 130,
                child: TextFormField(
                  cursorColor: Theme.of(context).colorScheme.primary,
                  decoration: InputDecoration(
                      labelText: "Current Password",
                      labelStyle: TextStyle(
                          color: Theme.of(context).colorScheme.primary),
                      focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.primary))),
                  obscureText: true,
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter a password' : null,
                  onChanged: (value) =>
                      setState(() => _currentPassword = value),
                ),
              ),
              Container(
                margin: EdgeInsets.only(
                    top: 100.0,
                    left: MediaQuery.of(context).size.width / 4,
                    right: MediaQuery.of(context).size.width / 4),
                color: Colors.transparent,
                width: MediaQuery.of(context).size.width - 130,
                child: TextFormField(
                  cursorColor: Theme.of(context).colorScheme.primary,
                  decoration: InputDecoration(
                      labelText: "New Password",
                      labelStyle: TextStyle(
                          color: Theme.of(context).colorScheme.primary),
                      focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.primary))),
                  obscureText: true,
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter a password' : null,
                  onChanged: (value) => setState(() => _newPassword = value),
                ),
              ),
              Align(
                  alignment: Alignment.bottomRight,
                  child: Container(
                    margin: EdgeInsets.only(right: 16.0, bottom: 16.0),
                    child: _currentPassword == null || _newPassword == null
                        ? SizedBox()
                        : FloatingActionButton(
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                _hideKeyboard();
                                await updatePassword(
                                    currentPassword: _currentPassword!,
                                    newPassword: _newPassword!);
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
                                            Theme.of(context)
                                                .colorScheme
                                                .primary,
                                            Theme.of(context)
                                                .colorScheme
                                                .secondary
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
          )),
    );
  }
}
