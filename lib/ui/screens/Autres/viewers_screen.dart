import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:gemu/ui/constants/constants.dart';
import 'package:gemu/models/user.dart';
import 'package:gemu/models/post.dart';
import 'package:gemu/ui/screens/Profil/profil_screen.dart';

class ViewersScreen extends StatefulWidget {
  final Post post;

  const ViewersScreen({Key? key, required this.post}) : super(key: key);

  @override
  ViewersScreenState createState() => ViewersScreenState();
}

class ViewersScreenState extends State<ViewersScreen> {
  bool _viewersIsThere = false;

  List<UserModel> viewers = [];

  getViewersPost() async {
    await widget.post.reference.collection('viewers').get().then((value) async {
      for (var item in value.docs) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(item.id)
            .get()
            .then((userData) =>
                viewers.add(UserModel.fromMap(userData, userData.data()!)));
      }
    });

    if (!_viewersIsThere) {
      setState(() {
        _viewersIsThere = true;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getViewersPost();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 60.0,
          decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10.0),
                  topRight: Radius.circular(10.0)),
              boxShadow: [
                BoxShadow(
                    color: Colors.black,
                    blurRadius: 1.0,
                    spreadRadius: 1.0,
                    offset: Offset(0.0, 1.0))
              ]),
          child: Center(
            child: Padding(
              padding: EdgeInsets.only(left: 5.0),
              child: Row(
                children: [
                  IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.arrow_back_ios)),
                  Text(
                    'Viewers',
                    style: mystyle(16),
                  )
                ],
              ),
            ),
          ),
        ),
        Expanded(
            child: _viewersIsThere
                ? MediaQuery.removePadding(
                    context: context,
                    removeTop: true,
                    child: ListView.builder(
                        physics: AlwaysScrollableScrollPhysics(
                            parent: BouncingScrollPhysics()),
                        shrinkWrap: true,
                        itemCount: viewers.length,
                        itemBuilder: (_, index) {
                          UserModel viewer = viewers[index];
                          return Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 5.0, vertical: 5.0),
                            child: ListTile(
                              onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) =>
                                          ProfilUser(userPostID: viewer.uid))),
                              leading: viewer.imageUrl != null
                                  ? Container(
                                      height: 50,
                                      width: 50,
                                      decoration: BoxDecoration(
                                          color: Theme.of(context).canvasColor,
                                          border:
                                              Border.all(color: Colors.black),
                                          shape: BoxShape.circle,
                                          image: DecorationImage(
                                              image: CachedNetworkImageProvider(
                                                  viewer.imageUrl!),
                                              fit: BoxFit.cover)),
                                    )
                                  : Container(
                                      height: 50,
                                      width: 50,
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).canvasColor,
                                        border: Border.all(color: Colors.black),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.person,
                                        color: Colors.black,
                                      ),
                                    ),
                              title: Text(viewer.username, style: mystyle(14)),
                            ),
                          );
                        }))
                : Center(
                    child: CircularProgressIndicator(
                      color: Theme.of(context).primaryColor,
                      strokeWidth: 1.5,
                    ),
                  ))
      ],
    );
  }
}
