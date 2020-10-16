import 'package:Gemu/screens/Login/login_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:Gemu/data/data.dart';
import 'package:provider/provider.dart';
import 'package:Gemu/screens/Welcome/components/authentication_service.dart';

class ProfilMenu extends StatefulWidget {
  ProfilMenu({Key key}) : super(key: key);

  @override
  _ProfilMenuState createState() => _ProfilMenuState();
}

class _ProfilMenuState extends State<ProfilMenu> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                height: 200,
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
                                  border: Border.all(
                                      color: Colors.black, width: 2.0),
                                  image: DecorationImage(
                                      fit: BoxFit.cover,
                                      image:
                                          AssetImage(currentUser.imageProfil))),
                            ),
                          )),
                      Row(
                        children: [
                          Padding(
                            padding: EdgeInsets.only(left: 10.0),
                            child: Text(
                              currentUser.name,
                              style: TextStyle(
                                  fontSize: 23, fontWeight: FontWeight.bold),
                            ),
                          ),
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
              onTap: () => {},
            ),
            ListTile(
              leading: Icon(Icons.border_color),
              title: Text('Design'),
              onTap: () => {Navigator.pushNamed(context, '/reglagesScreen')},
            ),
            ListTile(
              leading: Icon(Icons.access_time),
              title: Text('Activités'),
              onTap: () => {},
            ),
            ListTile(
              leading: Icon(Icons.save),
              title: Text('Sauvegardes'),
              onTap: () => {},
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Réglages'),
              onTap: () => {},
            ),
            ListTile(
              leading: Icon(Icons.exit_to_app),
              title: Text('Déconnexion'),
              onTap: () => {
                print('enter'),
                showDialog(
                  context: context,
                  builder: (_) => CupertinoAlertDialog(
                    title: Text("Déconnexion"),
                    content: Text("En êtes-vous sûr ?"),
                    actions: [
                      CupertinoDialogAction(
                          child: Text(
                            'Non',
                            style: TextStyle(color: Colors.blue),
                          ),
                          onPressed: () {
                            Navigator.of(context).pop();
                          }),
                      CupertinoDialogAction(
                          child: Text(
                            'Oui',
                            style: TextStyle(color: Colors.red),
                          ),
                          onPressed: () {
                            context.read<AuthenticationService>().signOut();
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) {
                              return LoginScreen();
                            }));
                          }),
                    ],
                  ),

                  // actions: [
                  //   FlatButton("Non"),
                  //   FlatButton("Oui"),
                  // ],
                ),
              },
              // onTap:
              //   CupertinoAlertDialog(
              //     title: Text("Déconnexion ?"),
              //     content: Text("Êtes-vous sûr ?"),
              //     actions: [
              //       FlatButton("Non"),
              //       FlatButton("Oui"),
              //     ],
              //   )
              //context.read<AuthenticationService>().signOut()
            ),
          ],
        ),
      ),
    );
  }
}
