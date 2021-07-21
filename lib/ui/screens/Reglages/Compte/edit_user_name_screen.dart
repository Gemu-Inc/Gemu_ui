import 'package:flutter/material.dart';

import 'package:gemu/services/database_service.dart';
import 'package:gemu/models/user.dart';
import 'package:gemu/ui/widgets/alert_dialog_custom.dart';

class EditUserNameScreen extends StatefulWidget {
  final UserModel user;

  EditUserNameScreen({Key? key, required this.user}) : super(key: key);

  @override
  _EditUserNameScreenState createState() => _EditUserNameScreenState();
}

class _EditUserNameScreenState extends State<EditUserNameScreen> {
  final _formKey = GlobalKey<FormState>();

  String? _currentName;

  Future updateUserPseudo(String? currentName, String currentUserID) async {
    var result = await DatabaseService.updateUserPseudo(
        currentName ?? widget.user.username, currentUserID);

    if (result is String) {
      alertUpdateUsername('Could not change username', result);
    } else {
      alertUpdateUsername(
          'Username successfully updated', 'Your username has been changed');
    }
  }

  Future alertUpdateUsername(String title, String content) {
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
                  updateUserPseudo(_currentName, widget.user.uid);
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
        backgroundColor: Colors.transparent,
        elevation: 6,
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
            onPressed: () {
              _hideKeyboard();
              if (_currentName != null) {
                alertSaveBeforeLeave();
              } else {
                Navigator.pop(context);
              }
            },
            icon: Icon(Icons.arrow_back_ios)),
        title: Text('Username'),
        centerTitle: false,
      ),
      body: Form(
        key: _formKey,
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
                    initialValue: widget.user.username,
                    cursorColor: Theme.of(context).primaryColor,
                    decoration: InputDecoration(
                        focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                                color: Theme.of(context).primaryColor))),
                    validator: (value) =>
                        value!.isEmpty ? 'Please enter a name' : null,
                    onChanged: (value) => setState(() => _currentName = value),
                  )),
            ),
            Align(
                alignment: Alignment.bottomRight,
                child: Container(
                  margin: EdgeInsets.only(right: 16.0, bottom: 16.0),
                  child: _currentName == null
                      ? SizedBox()
                      : FloatingActionButton(
                          onPressed: () async {
                            _hideKeyboard();
                            if (_formKey.currentState!.validate()) {
                              print("Username updated");
                              await updateUserPseudo(
                                  _currentName, widget.user.uid);
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
