import 'package:Gemu/screensmodels/Reglages/edit_profile_screen_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gradient_app_bar/gradient_app_bar.dart';
import 'package:stacked/stacked.dart';

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
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
                        color: Theme.of(context).canvasColor.withOpacity(0.3),
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
                                                        child: StreamBuilder(
                                                            stream: FirebaseFirestore
                                                                .instance
                                                                .collection(
                                                                    'users')
                                                                .doc(FirebaseAuth
                                                                    .instance
                                                                    .currentUser
                                                                    .uid)
                                                                .snapshots(),
                                                            builder: (context,
                                                                snapshot) {
                                                              if (snapshot
                                                                  .hasData) {
                                                                return model.selectedImage ==
                                                                        null
                                                                    ? snapshot.data['photoURL'] ==
                                                                            null
                                                                        ? Container(
                                                                            child:
                                                                                Icon(
                                                                              Icons.person,
                                                                              size: 50,
                                                                            ),
                                                                          )
                                                                        : Image
                                                                            .network(
                                                                            snapshot.data['photoURL'],
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
                                                  child: Icon(
                                                    Icons.add_a_photo,
                                                    size: 18,
                                                  )),
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
                                            title: 'profileImg',
                                            currentUserID: FirebaseAuth
                                                .instance.currentUser.uid),
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
                          StreamBuilder(
                              stream: FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(FirebaseAuth.instance.currentUser.uid)
                                  .snapshots(),
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  return Text(
                                    snapshot.data['pseudo'],
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
                          StreamBuilder(
                              stream: FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(FirebaseAuth.instance.currentUser.uid)
                                  .snapshots(),
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  return Text(
                                    snapshot.data['email'],
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
                      onPressed: () => model.addImgProfile(
                          title: 'profileImg',
                          currentUserID: FirebaseAuth.instance.currentUser.uid),
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
