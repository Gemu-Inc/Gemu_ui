import 'package:Gemu/components/components.dart';
import 'package:Gemu/screens/Login/login_screen.dart';
import 'package:Gemu/screens/Welcome/welcome_screen.dart';
import 'package:Gemu/screens/screens.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:Gemu/core/data/data.dart';
import 'package:provider/provider.dart';
import 'package:Gemu/core/services/authentication_service.dart';
import 'package:Gemu/core/services/auth_service.dart';

class ProfilMenu extends StatefulWidget {
  static final String routeName = 'profil';

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
                                  image: AssetImage(currentUser.imageProfil))),
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
              onTap: () => {Navigator.pushNamed(context, '/editprofileScreen')},
            ),
            ListTile(
              leading: Icon(Icons.border_color),
              title: Text('Design'),
              onTap: () =>
                  {Navigator.pushNamed(context, ReglagesScreen.routeName)},
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
                            _signOut();
                            Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(
                                    builder: (BuildContext context) =>
                                        WelcomeScreen()),
                                (Route<dynamic> route) => false);
                          }),
                    ],
                  ),
                ),
              },
            ),
          ],
        ),
      ),
    );
  }

  void _signOut() async {
    await Provider.of<AuthService>(context, listen: false).signOut();
    if (await Provider.of<AuthService>(context, listen: false).getUser() ==
        null) {
      print('Sucessfully signed out user');
    } else {
      print('Failed to sign out user');
    }
  }
}
