import 'package:flutter/material.dart';

import 'package:gemu/services/auth_service.dart';
import 'package:gemu/views/Reglages/Design/design_screen.dart';
import 'package:gemu/views/Reglages/Compte/edit_profile_screen.dart';
import 'package:gemu/views/Reglages/Privacy/privacy_screen.dart';
import 'package:gemu/views/Welcome/welcome_screen.dart';
import 'package:gemu/widgets/app_bar_custom.dart';
import 'package:gemu/widgets/alert_dialog_custom.dart';
import 'package:gemu/models/user.dart';

class ReglagesScreen extends StatelessWidget {
  final UserModel user;

  const ReglagesScreen({Key? key, required this.user}) : super(key: key);

  _signOut(BuildContext context) async {
    await AuthService.instance.signOut();
    await Future.delayed(Duration(seconds: 1));
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (BuildContext context) => WelcomeScreen()),
        (route) => false);
  }

  Future confirmDisconnect(BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialogCustom(
              context,
              'Déconnexion',
              'Êtes-vous sur de vouloir vous déconnecter?',
              [disconnectBtn(context), closeAlert(context)]);
        });
  }

  TextButton disconnectBtn(BuildContext context) {
    return TextButton(
        onPressed: () => _signOut(context),
        child: Text(
          'Oui',
          style: TextStyle(color: Colors.blue[200]),
        ));
  }

  TextButton closeAlert(BuildContext context) {
    return TextButton(
        onPressed: () {
          Navigator.pop(context);
        },
        child: Text(
          'Non',
          style: TextStyle(color: Colors.red[200]),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBarCustom(context: context, title: 'Réglages', actions: [
        IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => confirmDisconnect(context))
      ]),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          Padding(padding: EdgeInsets.only(top: 10.0)),
          ListTile(
            title: Text('PARAMÈTRES UTILISATEUR'),
          ),
          ListTile(
            leading: Icon(Icons.account_box),
            title: Text('Mon compte'),
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    settings: RouteSettings(name: ('/EditProfile')),
                    builder: (BuildContext context) =>
                        EditProfileScreen(user: user))),
          ),
          ListTile(
            leading: Icon(Icons.lock),
            title: Text('Privacy'),
            onTap: () => Navigator.push(
                context, MaterialPageRoute(builder: (_) => PrivacyScreen())),
          ),
          Divider(),
          ListTile(
            title: Text('PARAMÈTRES DE L\'APPLICATION'),
          ),
          ListTile(
              leading: Icon(Icons.design_services),
              title: Text('Apparence'),
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (BuildContext context) => DesignScreen()))),
          Divider(),
          ListTile(
            title: Text('INFORMATIONS SUR L\'APPLICATION'),
          ),
        ],
      ),
    );
  }
}
