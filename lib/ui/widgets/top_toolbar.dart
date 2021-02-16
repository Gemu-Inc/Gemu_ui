import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:Gemu/screensmodels/Home/home_screen_model.dart';
import 'package:Gemu/ui/widgets/profil_button.dart';
import 'package:Gemu/models/game.dart';
import 'package:gradient_app_bar/gradient_app_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TopToolBarHome extends StatelessWidget {
  final HomeScreenModel model;
  final Color gradient1, gradient2;
  final double elevationBar;
  final int currentPageGamesIndex, currentTabGamesIndex, currentTabIndex;
  final List<Game> game;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  TopToolBarHome(
      {Key key,
      @required this.model,
      @required this.gradient1,
      @required this.gradient2,
      @required this.elevationBar,
      @required this.currentPageGamesIndex,
      @required this.currentTabGamesIndex,
      @required this.currentTabIndex,
      @required this.game})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GradientAppBar(
      elevation: elevationBar,
      gradient: LinearGradient(colors: [gradient1, gradient2]),
      leading: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(_firebaseAuth.currentUser.uid)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              //UserC _userC = UserC.fromData(snapshot.data());
              return snapshot.data['photoURL'] == null
                  ? Builder(
                      builder: (context) => GestureDetector(
                        onTap: () => Scaffold.of(context).openDrawer(),
                        child: Container(
                          margin: EdgeInsets.all(3.0),
                          height: 45,
                          width: 45,
                          decoration: BoxDecoration(
                              color: Color(0xFF222831),
                              shape: BoxShape.circle,
                              border: Border.all(color: Color(0xFF222831))),
                          child: Icon(
                            Icons.person,
                            size: 40,
                          ),
                        ),
                      ),
                    )
                  : ProfilButtonHome(
                      currentUser: snapshot.data['photoURL'],
                      width: 45,
                      height: 45,
                      colorFond: Colors.transparent,
                      colorBorder: Color(0xFF222831),
                      onPress: () => Scaffold.of(context).openDrawer());
            } else {
              return CircularProgressIndicator(
                strokeWidth: 3,
                valueColor:
                    AlwaysStoppedAnimation(Theme.of(context).primaryColor),
              );
            }
          }),
      actions: [
        Builder(
          builder: (context) => GestureDetector(
            onTap: () => Scaffold.of(context).openEndDrawer(),
            child: Container(
              margin: EdgeInsets.only(top: 7.5, bottom: 7.5, right: 5.0),
              height: 50,
              width: 50,
              decoration: BoxDecoration(
                  color: Theme.of(context).canvasColor.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                      color: Theme.of(context).canvasColor.withOpacity(0.5))),
              child: Icon(Icons.notifications_active,
                  size: 28, color: Theme.of(context).accentColor),
            ),
          ),
        ),
      ],
      title: PreferredSize(
          child: currentTabIndex == 0
              ? SizedBox()
              : game != null
                  ? Container(
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                          gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Theme.of(context).primaryColor,
                                Theme.of(context).accentColor
                              ]),
                          borderRadius: BorderRadius.circular(10.0),
                          border: Border.all(color: Color(0xFF222831)),
                          image: DecorationImage(
                              fit: BoxFit.cover,
                              image: CachedNetworkImageProvider(
                                  game[currentTabGamesIndex].imageUrl))))
                  : CircularProgressIndicator(),
          preferredSize: Size.fromHeight(50)),
      centerTitle: true,
    );
  }
}
