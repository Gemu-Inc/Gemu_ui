import 'package:Gemu/screensmodels/Profil/profil_screen_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:Gemu/models/data.dart';
import 'package:stacked/stacked.dart';

class ProfilMenu extends StatefulWidget {
  @override
  _ProfilMenuState createState() => _ProfilMenuState();
}

class _ProfilMenuState extends State<ProfilMenu> {
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<ProfilScreenModel>.reactive(
      viewModelBuilder: () => ProfilScreenModel(),
      builder: (context, model, child) => Scaffold(
        body: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                Theme.of(context).primaryColor,
                Theme.of(context).accentColor
              ])),
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              Container(
                  child: DrawerHeader(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Align(
                        alignment: Alignment.topLeft,
                        child: GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            height: 90,
                            width: 90,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border:
                                    Border.all(color: Colors.black, width: 2.0),
                                image: DecorationImage(
                                    fit: BoxFit.cover,
                                    image:
                                        AssetImage(currentUser.imageProfil))),
                          ),
                        )),
                    Row(
                      children: [
                        Spacer(
                          flex: 3,
                        ),
                        Text('Followers'),
                        Spacer(
                          flex: 1,
                        ),
                        Text('Points'),
                        Spacer(
                          flex: 1,
                        ),
                        Text('Follows')
                      ],
                    )
                  ],
                ),
              )),
              Padding(padding: EdgeInsets.symmetric(vertical: 5.0)),
              ListTile(
                  leading: Icon(Icons.verified_user),
                  title: Text('Profil'),
                  onTap: () => {
                        model.navigateToEditProfile(),
                      }),
              ListTile(
                  leading: Icon(Icons.border_color),
                  title: Text('Design'),
                  onTap: () => {model.navigateToDesign()}),
              ListTile(
                leading: Icon(Icons.exit_to_app),
                title: Text('Déconnexion'),
                onTap: () => {model.userSignOut()},
              ),
            ],
          ),
        ),
      ),
    );
  }
}
