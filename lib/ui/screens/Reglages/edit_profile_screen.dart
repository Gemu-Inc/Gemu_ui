import 'package:Gemu/constants/route_names.dart';
import 'package:Gemu/screensmodels/Reglages/edit_profile_screen_model.dart';
import 'package:Gemu/services/firestore_service.dart';
import 'package:flutter/material.dart';
import 'package:gradient_app_bar/gradient_app_bar.dart';
import 'package:stacked/stacked.dart';
import 'package:Gemu/models/user.dart';
import 'package:Gemu/models/data.dart';

class EditProfileScreen extends StatefulWidget {
  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  String _currentName;

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<EditProfileScreenModel>.reactive(
        viewModelBuilder: () => EditProfileScreenModel(),
        builder: (context, model, child) => Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            appBar: GradientAppBar(
              leading: IconButton(
                  icon: Icon(Icons.arrow_back_ios),
                  onPressed: () => Navigator.pop(context)),
              title: Text('Mon compte'),
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).primaryColor,
                  Theme.of(context).accentColor
                ],
              ),
            ),
            body: Column(
              children: [
                GestureDetector(
                  onTap: () {
                    model.selectImage();
                  },
                  child: Container(
                    margin: EdgeInsets.only(top: 10.0),
                    height: 125,
                    width: 125,
                    decoration: BoxDecoration(
                        color: Colors.transparent,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.black)),
                    child: Stack(
                      children: [
                        Align(
                            alignment: Alignment.center,
                            child: CircleAvatar(
                              radius: 100,
                              backgroundColor: Colors.transparent,
                              child: ClipOval(
                                child: SizedBox(
                                    height: 125,
                                    width: 125,
                                    child: StreamBuilder<UserC>(
                                        stream: model.userData,
                                        builder: (context, snapshot) {
                                          if (snapshot.hasData) {
                                            UserC _userC = snapshot.data;
                                            return model.selectedImage == null
                                                ? _userC.photoURL == null
                                                    ? Container(
                                                        child:
                                                            Icon(Icons.person),
                                                      )
                                                    : Image.network(
                                                        _userC.photoURL,
                                                        fit: BoxFit.cover,
                                                      )
                                                : Image.file(
                                                    model.selectedImage,
                                                    fit: BoxFit.cover);
                                          } else {
                                            return CircularProgressIndicator(
                                              strokeWidth: 3,
                                              valueColor:
                                                  AlwaysStoppedAnimation(
                                                      Theme.of(context)
                                                          .primaryColor),
                                            );
                                          }
                                        })),
                              ),
                            )),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: Container(
                              margin:
                                  EdgeInsets.only(right: 11.0, bottom: 11.0),
                              height: 40,
                              width: 40,
                              decoration: BoxDecoration(
                                  color: Colors.grey, shape: BoxShape.circle),
                              child: Icon(Icons.add_a_photo)),
                        )
                      ],
                    ),
                  ),
                ),
                RaisedButton(
                    child: Text('Save'),
                    onPressed: () => model.addImgProfile(title: 'profileImg')),
                RaisedButton(
                    child: Text('Supp'),
                    onPressed: () =>
                        model.deleteImgProfile(title: 'profileImg')),
                Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          decoration: InputDecoration(labelText: "Pseudo"),
                          validator: (value) =>
                              value.isEmpty ? 'Please enter a name' : null,
                          onChanged: (value) =>
                              setState(() => _currentName = value),
                        ),
                        RaisedButton(
                            child: Text('Save'),
                            onPressed: () async {
                              if (_formKey.currentState.validate()) {
                                print("Username updated");
                                await model.updateUserPseudo(_currentName);
                              }
                              Navigator.pushNamed(context, NavScreenRoute)
                                  .then((value) => setState(() {}));
                            })
                      ],
                    )),
              ],
            )));
  }
}
