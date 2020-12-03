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
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                Theme.of(context).primaryColor,
                Theme.of(context).accentColor
              ])),
          child: Container(
              height: 280,
              child: DrawerHeader(
                child: Column(
                  children: [
                    Stack(
                      children: [
                        Align(
                          alignment: Alignment.topLeft,
                          child: IconButton(
                              icon: Icon(
                                Icons.expand_more,
                                size: 35,
                              ),
                              onPressed: () => model.navigateToNavigation()),
                        ),
                        Align(
                          alignment: Alignment.center,
                          child: GestureDetector(
                            onTap: () => print('Changer d\'image de profil'),
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
                          ),
                        ),
                        Align(
                          alignment: Alignment.topRight,
                          child: IconButton(
                              icon: Icon(
                                Icons.settings,
                                size: 25,
                              ),
                              onPressed: () => model.navigateToReglages()),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    GestureDetector(
                        onTap: () => print('Changer le nom du user'),
                        child: Align(
                          alignment: Alignment.center,
                          child: Text(
                            'Oruj',
                            style: TextStyle(fontSize: 23),
                          ),
                        )),
                    SizedBox(
                      height: 20,
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 5.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Text(
                            '0',
                            style: TextStyle(fontSize: 23),
                          ),
                          Text(
                            '0',
                            style: TextStyle(fontSize: 23),
                          ),
                          Padding(
                            padding: EdgeInsets.only(right: 0.0),
                            child: Text(
                              '0',
                              style: TextStyle(fontSize: 23),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text('Followers'),
                        Padding(
                          padding: EdgeInsets.only(right: 10.0),
                          child: Text('Points'),
                        ),
                        Text('Follows')
                      ],
                    )
                  ],
                ),
              )),
        ),
      ),
    );
  }
}
