import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ActionsPostBar extends StatelessWidget {
  static const double ActionWidgetSize = 60.0;
  static const double ActionIconSize = 35.0;
  static const double ShareActionIconSize = 25.0;
  static const double ProfileImageSize = 50.0;
  static const double PlusIconSize = 20.0;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      height: 70,
      width: MediaQuery.of(context).size.width / 2,
      child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _getSocialReferencement(
                iconUp: Icons.arrow_upward,
                iconDown: Icons.arrow_downward,
                title: '3.2m'),
            _getSocialAction(icon: Icons.message_rounded, title: '16.4k'),
            _getFollowAction(context: context),
          ]),
    );
  }

  Widget _getSocialReferencement(
      {String title, IconData iconUp, IconData iconDown}) {
    return Container(
        height: 60.0,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(iconUp, size: 28, color: Colors.grey[300]),
                SizedBox(
                  width: 10.0,
                ),
                Icon(iconDown, size: 28, color: Colors.grey[300]),
              ],
            ),
            Padding(
              padding: EdgeInsets.only(top: 2.0),
              child: Text(title, style: TextStyle(fontSize: 12.0)),
            )
          ],
        ));
  }

  Widget _getSocialAction({String title, IconData icon}) {
    return Container(
        height: 60.0,
        child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
          Icon(icon, size: 28, color: Colors.grey[300]),
          Padding(
            padding: EdgeInsets.only(top: 2.0),
            child: Text(title,
                style: TextStyle(fontSize: 12.0, color: Colors.grey[300])),
          )
        ]));
  }

  Widget _getFollowAction({BuildContext context}) {
    return Container(
        margin: EdgeInsets.only(top: 10.0),
        width: 55.0,
        height: 55.0,
        child: Stack(
            children: [_getProfilePicture(), _getPlusIcon(context: context)]));
  }

  Widget _getPlusIcon({BuildContext context}) {
    return Positioned(
      bottom: 0,
      left: ((ActionWidgetSize / 2) - (PlusIconSize / 2)),
      child: Container(
          width: PlusIconSize, // PlusIconSize = 20.0;
          height: PlusIconSize, // PlusIconSize = 20.0;
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Theme.of(context).primaryColor,
                    Theme.of(context).accentColor
                  ]),
              borderRadius: BorderRadius.circular(15.0)),
          child: Icon(
            Icons.add,
            color: Colors.white,
            size: 20.0,
          )),
    );
  }

  Widget _getProfilePicture() {
    return Positioned(
        left: (ActionWidgetSize / 2) - (ProfileImageSize / 2),
        child: Container(
            padding:
                EdgeInsets.all(1.0), // Add 1.0 point padding to create border
            height: ProfileImageSize, // ProfileImageSize = 50.0;
            width: ProfileImageSize, // ProfileImageSize = 50.0;
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(ProfileImageSize / 2)),
            // import 'package:cached_network_image/cached_network_image.dart'; at the top to use CachedNetworkImage
            child: CachedNetworkImage(
              imageUrl:
                  "https://secure.gravatar.com/avatar/ef4a9338dca42372f15427cdb4595ef7",
              placeholder: (context, url) => new CircularProgressIndicator(),
              errorWidget: (context, url, error) => new Icon(Icons.error),
            )));
  }
}
