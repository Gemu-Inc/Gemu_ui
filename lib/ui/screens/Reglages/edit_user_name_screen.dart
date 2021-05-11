import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:Gemu/screensmodels/Reglages/edit_user_name_screen_model.dart';

class EditUserNameScreen extends StatefulWidget {
  EditUserNameScreen({Key? key}) : super(key: key);

  @override
  _EditUserNameScreenState createState() => _EditUserNameScreenState();
}

class _EditUserNameScreenState extends State<EditUserNameScreen> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  String? _currentName;
  var currentUser;

  @override
  void initState() {
    super.initState();
    currentUser = _firebaseAuth.currentUser!.uid;
  }

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<EditUserNameScreenModel>.reactive(
      viewModelBuilder: () => EditUserNameScreenModel(),
      builder: (context, model, child) => Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: PreferredSize(
            child: Container(
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                    Theme.of(context).primaryColor,
                    Theme.of(context).accentColor
                  ])),
              child: AppBar(
                elevation: 0,
                backgroundColor: Colors.transparent,
                leading: IconButton(
                  icon: Icon(
                    Icons.arrow_back_ios,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
                title: Text(
                  'Changer le nom d\'utilisateur',
                ),
              ),
            ),
            preferredSize: Size.fromHeight(60)),
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
                    child: StreamBuilder(
                        stream: FirebaseFirestore.instance
                            .collection('users')
                            .doc(currentUser)
                            .snapshots(),
                        builder: (context, AsyncSnapshot snapshot) {
                          if (snapshot.hasData) {
                            return TextFormField(
                              initialValue: snapshot.data['pseudo'],
                              validator: (value) =>
                                  value!.isEmpty ? 'Please enter a name' : null,
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
                              if (_formKey.currentState!.validate()) {
                                print("Username updated");
                                await model.updateUserPseudo(
                                    _currentName, currentUser);
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
