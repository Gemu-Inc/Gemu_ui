import 'package:Gemu/screensmodels/Reglages/edit_password_screen_model.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

class EditPasswordScreen extends StatefulWidget {
  EditPasswordScreen({Key key}) : super(key: key);

  @override
  _EditPasswordScreenState createState() => _EditPasswordScreenState();
}

class _EditPasswordScreenState extends State<EditPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  String _currentPassword;
  String _newPassword;

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<EditPasswordScreenModel>.reactive(
        viewModelBuilder: () => EditPasswordScreenModel(),
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
                  'Changer le mot de passe',
                  style: TextStyle(color: Colors.grey),
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
                          decoration:
                              InputDecoration(labelText: "Current Password"),
                          obscureText: true,
                          validator: (value) =>
                              value.isEmpty ? 'Please enter a password' : null,
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
                          decoration:
                              InputDecoration(labelText: "New Password"),
                          obscureText: true,
                          validator: (value) =>
                              value.isEmpty ? 'Please enter a password' : null,
                          onChanged: (value) =>
                              setState(() => _newPassword = value),
                        ),
                      ),
                      Align(
                          alignment: Alignment.bottomRight,
                          child: Container(
                            margin: EdgeInsets.only(right: 16.0, bottom: 16.0),
                            child: _currentPassword == null ||
                                    _newPassword == null
                                ? SizedBox()
                                : FloatingActionButton(
                                    onPressed: () async {
                                      if (_formKey.currentState.validate()) {
                                        await model.updateUserPassword(
                                            _currentPassword, _newPassword);
                                      }
                                      print("Password updated");
                                      model.navigateToEditProfile();
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
                                                        .primaryColor,
                                                    Theme.of(context)
                                                        .accentColor
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
            ));
  }
}
