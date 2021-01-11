import 'package:flutter/material.dart';
import 'package:Gemu/screensmodels/Home/home_screen_model.dart';
import 'package:Gemu/models/user.dart';
import 'package:Gemu/ui/widgets/profil_button.dart';
import 'package:Gemu/models/fil_model.dart';

class TopToolBar extends StatelessWidget {
  final HomeScreenModel model;
  final Color fondBar;
  final double elevationBar;
  final int currentPageGamesIndex, currentTabGamesIndex;
  final List<Fil> fil;

  const TopToolBar(
      {Key key,
      @required this.model,
      @required this.fondBar,
      @required this.elevationBar,
      @required this.currentPageGamesIndex,
      @required this.currentTabGamesIndex,
      @required this.fil})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: elevationBar,
      //backgroundColor: Colors.purple,
      leading: StreamBuilder<UserC>(
          stream: model.userData,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              UserC _userC = snapshot.data;
              return _userC.photoURL == null
                  ? GestureDetector(
                      onTap: () => model.navigateToProfil(),
                      child: Container(
                        margin: EdgeInsets.all(3.0),
                        height: 50,
                        width: 50,
                        decoration: BoxDecoration(
                            color: Color(0xFF222831),
                            shape: BoxShape.circle,
                            border: Border.all(color: Color(0xFF222831))),
                        child: Icon(
                          Icons.person,
                          size: 40,
                        ),
                      ),
                    )
                  : ProfilButton(
                      currentUser: _userC.photoURL,
                      width: 50,
                      height: 50,
                      colorFond: Colors.transparent,
                      colorBorder: Color(0xFF222831),
                      onPress: () => model.navigateToProfil());
            } else {
              return CircularProgressIndicator(
                strokeWidth: 3,
                valueColor:
                    AlwaysStoppedAnimation(Theme.of(context).primaryColor),
              );
            }
          }),
      actions: [
        GestureDetector(
          child: Container(
            margin: EdgeInsets.only(top: 7.5, bottom: 7.5, right: 5.0),
            height: 35,
            width: 35,
            decoration: BoxDecoration(
                color: Color(0xFF222831).withOpacity(0.5),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Color(0xFF222831).withOpacity(0.5))),
            child: Icon(
              Icons.search,
              size: 28,
              color: Theme.of(context).accentColor,
            ),
          ),
          onTap: () => model.navigateToSearch(),
        ),
        Builder(
          builder: (context) => GestureDetector(
            onTap: () => Scaffold.of(context).openEndDrawer(),
            child: Container(
              margin: EdgeInsets.only(top: 7.5, bottom: 7.5, right: 5.0),
              height: 35,
              width: 35,
              decoration: BoxDecoration(
                  color: Color(0xFF222831).withOpacity(0.5),
                  borderRadius: BorderRadius.circular(15),
                  border:
                      Border.all(color: Color(0xFF222831).withOpacity(0.5))),
              child: Icon(Icons.bubble_chart_outlined,
                  size: 28, color: Theme.of(context).accentColor),
            ),
          ),
        ),
      ],
      title: Text(
        '${fil[currentTabGamesIndex].nameFil}',
        style: TextStyle(
            fontSize: 17,
            color: currentPageGamesIndex == 0
                ? Colors.transparent
                : Colors.grey[300],
            fontWeight: FontWeight.bold),
      ),
      centerTitle: true,
    );
  }
}
