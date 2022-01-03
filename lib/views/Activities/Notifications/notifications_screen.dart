import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:gemu/constants/constants.dart';
import 'package:gemu/models/notification.dart';

import 'notification_tile.dart';

class NotificationsScreen extends StatefulWidget {
  final String? whatActivity;
  final ScrollController notifScrollController;

  NotificationsScreen(
      {required this.whatActivity, required this.notifScrollController});

  @override
  Notificationsviewstate createState() => Notificationsviewstate();
}

class Notificationsviewstate extends State<NotificationsScreen>
    with AutomaticKeepAliveClientMixin {
  bool notifIsThere = false;
  bool isReloadingNotifications = false;
  bool isLoadingMoreNotifications = false;
  bool isResultNotifications = false;

  late StreamSubscription notificationsListener;

  List<NotificationUser> notifications = [];
  List<NotificationUser> notifComments = [];
  List<NotificationUser> notifFollows = [];
  List<NotificationUser> notifUpDown = [];

  scrollNotifListener() {
    if (widget.notifScrollController.offset <=
            (widget.notifScrollController.position.minScrollExtent - 50.0) &&
        !isReloadingNotifications) {
      reloadNotifications();
    } else if (widget.notifScrollController.offset >=
            (widget.notifScrollController.position.maxScrollExtent + 50) &&
        !isLoadingMoreNotifications) {
      loadMoreNotifications();
    }
  }

  getNotifications() async {
    notificationsListener = FirebaseFirestore.instance
        .collection('notifications')
        .doc(me!.uid)
        .collection("singleNotif")
        .orderBy('date', descending: true)
        .limit(10)
        .snapshots()
        .listen((notifData) {
      print('listen notif');
      if (notifications.length != 0) {
        notifications.clear();
        notifComments.clear();
        notifFollows.clear();
        notifUpDown.clear();
      }
      for (var item in notifData.docs) {
        notifications.add(NotificationUser.fromMap(item, item.data()));
      }
      for (var notif in notifications) {
        if (notif.type == "comment") {
          notifComments.add(notif);
        } else if (notif.type == "follow") {
          notifFollows.add(notif);
        } else {
          notifUpDown.add(notif);
        }
      }
      setState(() {});
    });

    if (!notifIsThere && mounted) {
      setState(() {
        notifIsThere = true;
      });
    }
  }

  reloadNotifications() async {
    setState(() {
      isReloadingNotifications = true;
      if (isReloadingNotifications) {
        isResultNotifications = false;
      }
    });

    await Future.delayed(Duration(seconds: 1));

    notifications.clear();
    notifComments.clear();
    notifFollows.clear();
    notifUpDown.clear();

    await FirebaseFirestore.instance
        .collection('notifications')
        .doc(me!.uid)
        .collection("singleNotif")
        .orderBy('date', descending: true)
        .limit(10)
        .get()
        .then((notifData) {
      for (var item in notifData.docs) {
        notifications.add(NotificationUser.fromMap(item, item.data()));
      }
      for (var notif in notifications) {
        if (notif.type == "comment") {
          notifComments.add(notif);
        } else if (notif.type == "follow") {
          notifFollows.add(notif);
        } else {
          notifUpDown.add(notif);
        }
      }
    });

    setState(() {
      isReloadingNotifications = false;
      notifIsThere = false;
    });

    await Future.delayed(Duration(seconds: 1));

    setState(() {
      notifIsThere = true;
    });
  }

  loadMoreNotifications() async {
    List<NotificationUser> newNotifications = [];
    bool add;

    setState(() {
      isLoadingMoreNotifications = true;
      if (isResultNotifications) {
        isResultNotifications = false;
      }
    });

    await Future.delayed(Duration(seconds: 1));

    NotificationUser notification = notifications.last;

    await FirebaseFirestore.instance
        .collection('notifications')
        .doc(me!.uid)
        .collection('singleNotif')
        .orderBy('date', descending: true)
        .startAfterDocument(notification.snapshot)
        .limit(5)
        .get()
        .then((notifData) {
      for (var item in notifData.docs) {
        newNotifications.add(NotificationUser.fromMap(item, item.data()));
      }
    });

    for (var i = 0; i < newNotifications.length; i++) {
      if (notifications
          .any((element) => element.id == newNotifications[i].id)) {
        add = false;
      } else {
        add = true;
      }
      if (add) {
        notifications.add(newNotifications[i]);
        if (newNotifications[i].type == "comment") {
          notifComments.add(newNotifications[i]);
        } else if (newNotifications[i].type == "follow") {
          notifFollows.add(newNotifications[i]);
        } else {
          notifUpDown.add(newNotifications[i]);
        }
      }
    }
    setState(() {
      isLoadingMoreNotifications = false;
      if (newNotifications.length == 0) {
        isResultNotifications = true;
      }
    });
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    getNotifications();
    widget.notifScrollController.addListener(scrollNotifListener);
  }

  @override
  void deactivate() {
    widget.notifScrollController.removeListener(scrollNotifListener);
    super.deactivate();
  }

  @override
  void dispose() {
    notificationsListener.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    switch (widget.whatActivity) {
      case "All notifications":
        return notifIsThere
            ? notificationsAllNotifications(notifications)
            : loadNotifications();
      case "Comments":
        return notifIsThere
            ? notificationsComments(notifications)
            : loadNotifications();
      case "Follows":
        return notifIsThere
            ? notificationsFollows(notifications)
            : loadNotifications();
      case "Up&Down":
        return notifIsThere
            ? notificationsUpDown(notifications)
            : loadNotifications();
      default:
        return Center(
            child: Text(
          'Pas de notifications actuellement',
          style: mystyle(12),
        ));
    }
  }

  Widget loadNotifications() {
    return Center(
      child: CircularProgressIndicator(
        color: Theme.of(context).primaryColor,
        strokeWidth: 1.5,
      ),
    );
  }

  Widget notificationsAllNotifications(List<NotificationUser> notifications) {
    return SingleChildScrollView(
      controller: widget.notifScrollController,
      physics: AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(top: 10.0),
            child: Container(
              height: isReloadingNotifications ? 50 : 0,
              child: Center(
                  child: SizedBox(
                height: 30.0,
                width: 30.0,
                child: CircularProgressIndicator(
                  color: Theme.of(context).primaryColor,
                  strokeWidth: 1.5,
                ),
              )),
            ),
          ),
          notifications.length == 0
              ? Container(
                  height: MediaQuery.of(context).size.height - 150,
                  child: Center(
                    child: Text(
                      'Pas de notifications',
                      style: mystyle(12),
                    ),
                  ),
                )
              : ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: notifications.length,
                  itemBuilder: (context, index) {
                    return NotifTile(
                        notifications: notifications,
                        notification: notifications[index]);
                  }),
          Stack(
            children: [
              Padding(
                padding: EdgeInsets.only(top: 10.0),
                child: Container(
                  height: isLoadingMoreNotifications ? 50.0 : 0.0,
                  child: Center(
                    child: SizedBox(
                      height: 30.0,
                      width: 30.0,
                      child: CircularProgressIndicator(
                        color: Theme.of(context).primaryColor,
                        strokeWidth: 1.5,
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 10.0),
                child: Container(
                  height: isResultNotifications ? 50.0 : 0.0,
                  child: Center(
                    child: Text(
                      'C\'est tout pour le moment',
                      style: mystyle(11),
                    ),
                  ),
                ),
              )
            ],
          )
        ],
      ),
    );
  }

  Widget notificationsComments(List<NotificationUser> notifications) {
    return SingleChildScrollView(
      controller: widget.notifScrollController,
      physics: AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(top: 10.0),
            child: Container(
              height: isReloadingNotifications ? 50 : 0,
              child: Center(
                  child: SizedBox(
                height: 30.0,
                width: 30.0,
                child: CircularProgressIndicator(
                  color: Theme.of(context).primaryColor,
                  strokeWidth: 1.5,
                ),
              )),
            ),
          ),
          notifComments.length == 0
              ? Container(
                  height: MediaQuery.of(context).size.height - 150,
                  child: Center(
                    child: Text(
                      'Pas de notifications',
                      style: mystyle(12),
                    ),
                  ),
                )
              : ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: notifComments.length,
                  itemBuilder: (context, index) {
                    return NotifTile(
                        notifications: notifComments,
                        notification: notifComments[index]);
                  },
                ),
          Stack(
            children: [
              Padding(
                padding: EdgeInsets.only(top: 10.0),
                child: Container(
                  height: isLoadingMoreNotifications ? 50.0 : 0.0,
                  child: Center(
                    child: SizedBox(
                      height: 30.0,
                      width: 30.0,
                      child: CircularProgressIndicator(
                        color: Theme.of(context).primaryColor,
                        strokeWidth: 1.5,
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 10.0),
                child: Container(
                  height: isResultNotifications ? 50.0 : 0.0,
                  child: Center(
                    child: Text(
                      'C\'est tout pour le moment',
                      style: mystyle(11),
                    ),
                  ),
                ),
              )
            ],
          )
        ],
      ),
    );
  }

  Widget notificationsFollows(List<NotificationUser> notifications) {
    return SingleChildScrollView(
      controller: widget.notifScrollController,
      physics: AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(top: 10.0),
            child: Container(
              height: isReloadingNotifications ? 50 : 0,
              child: Center(
                  child: SizedBox(
                height: 30.0,
                width: 30.0,
                child: CircularProgressIndicator(
                  color: Theme.of(context).primaryColor,
                  strokeWidth: 1.5,
                ),
              )),
            ),
          ),
          notifFollows.length == 0
              ? Container(
                  height: MediaQuery.of(context).size.height - 150,
                  child: Center(
                    child: Text(
                      'Pas de notifications',
                      style: mystyle(12),
                    ),
                  ),
                )
              : ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: notifFollows.length,
                  itemBuilder: (context, index) {
                    return NotifTile(
                        notifications: notifFollows,
                        notification: notifFollows[index]);
                  },
                ),
          Stack(
            children: [
              Padding(
                padding: EdgeInsets.only(top: 10.0),
                child: Container(
                  height: isLoadingMoreNotifications ? 50.0 : 0.0,
                  child: Center(
                    child: SizedBox(
                      height: 30.0,
                      width: 30.0,
                      child: CircularProgressIndicator(
                        color: Theme.of(context).primaryColor,
                        strokeWidth: 1.5,
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 10.0),
                child: Container(
                  height: isResultNotifications ? 50.0 : 0.0,
                  child: Center(
                    child: Text(
                      'C\'est tout pour le moment',
                      style: mystyle(11),
                    ),
                  ),
                ),
              )
            ],
          )
        ],
      ),
    );
  }

  Widget notificationsUpDown(List<NotificationUser> notifications) {
    return SingleChildScrollView(
      controller: widget.notifScrollController,
      physics: AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(top: 10.0),
            child: Container(
              height: isReloadingNotifications ? 50 : 0,
              child: Center(
                  child: SizedBox(
                height: 30.0,
                width: 30.0,
                child: CircularProgressIndicator(
                  color: Theme.of(context).primaryColor,
                  strokeWidth: 1.5,
                ),
              )),
            ),
          ),
          notifUpDown.length == 0
              ? Container(
                  height: MediaQuery.of(context).size.height - 150,
                  child: Center(
                    child: Text(
                      'Pas de notifications',
                      style: mystyle(12),
                    ),
                  ),
                )
              : ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: notifUpDown.length,
                  itemBuilder: (context, index) {
                    return NotifTile(
                        notifications: notifUpDown,
                        notification: notifUpDown[index]);
                  },
                ),
          Stack(
            children: [
              Padding(
                padding: EdgeInsets.only(top: 10.0),
                child: Container(
                  height: isLoadingMoreNotifications ? 50.0 : 0.0,
                  child: Center(
                    child: SizedBox(
                      height: 30.0,
                      width: 30.0,
                      child: CircularProgressIndicator(
                        color: Theme.of(context).primaryColor,
                        strokeWidth: 1.5,
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 10.0),
                child: Container(
                  height: isResultNotifications ? 50.0 : 0.0,
                  child: Center(
                    child: Text(
                      'C\'est tout pour le moment',
                      style: mystyle(11),
                    ),
                  ),
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}
