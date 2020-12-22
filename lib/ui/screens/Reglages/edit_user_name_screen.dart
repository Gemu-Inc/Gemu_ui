import 'package:Gemu/screensmodels/Reglages/edit_user_name_screen_model.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:Gemu/models/user.dart';

class EditUserNameScreen extends StatefulWidget {
  EditUserNameScreen({Key key}) : super(key: key);

  @override
  _EditUserNameScreenState createState() => _EditUserNameScreenState();
}

class _EditUserNameScreenState extends State<EditUserNameScreen> {
  final _formKey = GlobalKey<FormState>();
  String _currentName;

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<EditUserNameScreenModel>.reactive(
      viewModelBuilder: () => EditUserNameScreenModel(),
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
            'Changer le nom d\'utilisateur',
            style: TextStyle(color: Colors.grey),
          ),
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
                    child: StreamBuilder<UserC>(
                        stream: model.userData,
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            UserC _userC = snapshot.data;
                            return TextFormField(
                              initialValue: _userC.pseudo,
                              validator: (value) =>
                                  value.isEmpty ? 'Please enter a name' : null,
                              onChanged: (value) =>
                                  setState(() => _currentName = value),
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
                    child: _currentName == null
                        ? SizedBox()
                        : FloatingActionButton(
                            onPressed: () async {
                              if (_formKey.currentState.validate()) {
                                print("Username updated");
                                await model.updateUserPseudo(_currentName);
                              }
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
