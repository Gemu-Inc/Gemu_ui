import 'package:Gemu/screensmodels/Reglages/reglages_screen_model.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

class ReglagesScreen extends StatelessWidget {
  const ReglagesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<ReglagesScreenModel>.reactive(
        viewModelBuilder: () => ReglagesScreenModel(),
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
                      leading: IconButton(
                          icon: Icon(Icons.arrow_back_ios),
                          onPressed: () => model.navigateToProfile()),
                      title: Text("Réglages"),
                      actions: [
                        IconButton(
                            icon: Icon(Icons.logout),
                            onPressed: () => model.userSignOut())
                      ],
                    ),
                  ),
                  preferredSize: Size.fromHeight(60)),
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
                    onTap: () => model.navigateToEditProfile(),
                  ),
                  Divider(),
                  ListTile(
                    title: Text('PARAMÈTRES DE L\'APPLICATION'),
                  ),
                  ListTile(
                      leading: Icon(Icons.design_services),
                      title: Text('Apparence'),
                      onTap: () => model.navigateToDesign()),
                  Divider(),
                  ListTile(
                    title: Text('INFORMATIONS SUR L\'APPLICATION'),
                  ),
                ],
              ),
            ));
  }
}
