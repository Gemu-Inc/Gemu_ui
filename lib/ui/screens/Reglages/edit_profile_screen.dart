import 'package:Gemu/screensmodels/Reglages/edit_profile_screen_model.dart';
import 'package:flutter/material.dart';
import 'package:gradient_app_bar/gradient_app_bar.dart';
import 'package:stacked/stacked.dart';
import 'package:Gemu/models/user.dart';

class EditProfileScreen extends StatefulWidget {
  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<EditProfileScreenModel>.reactive(
        viewModelBuilder: () => EditProfileScreenModel(),
        builder: (context, model, child) => Scaffold(
              backgroundColor: Color(0xFF1A1C25),
              appBar: GradientAppBar(
                  leading: IconButton(
                      icon: Icon(Icons.arrow_back_ios),
                      onPressed: () => model.navigateToReglages()),
                  title: Text('Mon compte'),
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).primaryColor,
                      Theme.of(context).accentColor
                    ],
                  ),
                  bottom: PreferredSize(
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        color: Colors.black45,
                        child: Column(
                          children: [
                            Stack(
                              children: [
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Padding(
                                    padding: EdgeInsets.only(left: 50.0),
                                    child: GestureDetector(
                                      onTap: () {
                                        model.selectImage();
                                      },
                                      child: Container(
                                        margin: EdgeInsets.only(top: 10.0),
                                        height: 100,
                                        width: 100,
                                        decoration: BoxDecoration(
                                            color: Colors.transparent,
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                                color: Colors.black)),
                                        child: Stack(
                                          children: [
                                            Align(
                                                alignment: Alignment.center,
                                                child: CircleAvatar(
                                                  radius: 100,
                                                  backgroundColor:
                                                      Colors.transparent,
                                                  child: ClipOval(
                                                    child: SizedBox(
                                                        height: 100,
                                                        width: 100,
                                                        child: StreamBuilder<
                                                                UserC>(
                                                            stream:
                                                                model.userData,
                                                            builder: (context,
                                                                snapshot) {
                                                              if (snapshot
                                                                  .hasData) {
                                                                UserC _userC =
                                                                    snapshot
                                                                        .data;
                                                                return model.selectedImage ==
                                                                        null
                                                                    ? _userC.photoURL ==
                                                                            null
                                                                        ? Container(
                                                                            child:
                                                                                Icon(Icons.person),
                                                                          )
                                                                        : Image
                                                                            .network(
                                                                            _userC.photoURL,
                                                                            fit:
                                                                                BoxFit.cover,
                                                                          )
                                                                    : Image.file(
                                                                        model
                                                                            .selectedImage,
                                                                        fit: BoxFit
                                                                            .cover);
                                                              } else {
                                                                return CircularProgressIndicator(
                                                                  strokeWidth:
                                                                      3,
                                                                  valueColor: AlwaysStoppedAnimation(
                                                                      Theme.of(
                                                                              context)
                                                                          .primaryColor),
                                                                );
                                                              }
                                                            })),
                                                  ),
                                                )),
                                            Align(
                                              alignment: Alignment.topRight,
                                              child: Container(
                                                  height: 30,
                                                  width: 30,
                                                  decoration: BoxDecoration(
                                                      color: Colors.grey,
                                                      shape: BoxShape.circle),
                                                  child:
                                                      Icon(Icons.add_a_photo)),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.bottomRight,
                                  child: Padding(
                                    padding: EdgeInsets.only(
                                        top: 75.0, right: 100.0),
                                    child: FlatButton(
                                        onPressed: () => model.deleteImgProfile(
                                            title: 'profileImg'),
                                        child: Text('Supprimer l\'icône',
                                            style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.red))),
                                  ),
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                      preferredSize: Size.fromHeight(120))),
              body: ListView(
                padding: EdgeInsets.zero,
                children: [
                  ListTile(
                    title: Text('INFORMATIONS DU COMPTE'),
                  ),
                  FlatButton(
                      onPressed: () => model.navigateToEditUserName(),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Nom d\'utilisateur'),
                          StreamBuilder<UserC>(
                              stream: model.userData,
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  UserC _userC = snapshot.data;
                                  return Text(
                                    _userC.pseudo,
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey),
                                  );
                                } else {
                                  return CircularProgressIndicator();
                                }
                              }),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 12,
                          ),
                        ],
                      )),
                  FlatButton(
                      onPressed: () => model.navigateToEditEmail(),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('E-mail'),
                          StreamBuilder<UserC>(
                              stream: model.userData,
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  UserC _userC = snapshot.data;
                                  return Text(
                                    _userC.email,
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey),
                                  );
                                } else {
                                  return CircularProgressIndicator();
                                }
                              }),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 12,
                          )
                        ],
                      )),
                  FlatButton(
                      onPressed: () => model.navigateToEditPassword(),
                      child: Stack(
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text('Password'),
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Icon(
                              Icons.arrow_forward_ios,
                              size: 12,
                            ),
                          )
                        ],
                      )),
                  Divider(),
                  ListTile(
                    title: Text('GESTION DU COMPTE'),
                  ),
                  FlatButton(
                      onPressed: () => print('Désactiver le compte'),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text('Désactiver le compte'),
                      )),
                  FlatButton(
                      onPressed: () => print('Supprimer le compte'),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Supprimer le compte',
                          style: TextStyle(color: Colors.red),
                        ),
                      )),
                ],
              ),
              floatingActionButton: model.selectedImage == null
                  ? SizedBox()
                  : FloatingActionButton(
                      onPressed: () => model.addImgProfile(title: 'profileImg'),
                      backgroundColor: Colors.transparent,
                      elevation: 6.0,
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
                      )),
            ));
  }
}
