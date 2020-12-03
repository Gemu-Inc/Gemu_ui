import 'package:Gemu/screensmodels/Profil/reglages_screen_model.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:gradient_app_bar/gradient_app_bar.dart';

class ReglagesScreen extends StatelessWidget {
  const ReglagesScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<ReglagesScreenModel>.reactive(
        viewModelBuilder: () => ReglagesScreenModel(),
        builder: (context, model, child) => Scaffold(
              appBar: GradientAppBar(
                gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Theme.of(context).primaryColor,
                      Theme.of(context).accentColor
                    ]),
                leading: IconButton(
                    icon: Icon(Icons.arrow_back_ios),
                    onPressed: () => model.navigateToProfile()),
                title: Text("Réglages"),
              ),
              body: ListView(
                padding: EdgeInsets.zero,
                children: [
                  Padding(padding: EdgeInsets.only(top: 10.0)),
                  ListTile(
                    leading: Icon(Icons.verified_user),
                    title: Text('Profil'),
                    onTap: () => model.navigateToEditProfile(),
                  ),
                  ListTile(
                      leading: Icon(Icons.border_color),
                      title: Text('Design'),
                      onTap: () => model.navigateToDesign()),
                  ListTile(
                    leading: Icon(Icons.exit_to_app),
                    title: Text('Déconnexion'),
                    onTap: () => model.userSignOut(),
                  ),
                ],
              ),
            ));
  }
}
