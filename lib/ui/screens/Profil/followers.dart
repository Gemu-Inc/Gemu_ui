import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:gemu/models/user.dart';
import 'package:gemu/ui/widgets/app_bar_custom.dart';

class Followers extends StatefulWidget {
  final String idUser;

  Followers({required this.idUser});

  @override
  FollowersState createState() => FollowersState();
}

class FollowersState extends State<Followers> {
  bool dataIsThere = false;

  List result = [];
  List<UserModel> resultFinal = [];

  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    getFollowers();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  getFollowers() async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.idUser)
        .collection('followers')
        .get()
        .then((data) => result = data.docs);

    for (int i = 0; i < result.length; i++) {
      DocumentSnapshot docSnap = result[i];
      await FirebaseFirestore.instance
          .collection('users')
          .doc(docSnap.id)
          .get()
          .then(
              (data) => resultFinal.add(UserModel.fromMap(data, data.data()!)));
    }

    setState(() {
      dataIsThere = !dataIsThere;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBarCustom(
        context: context,
        title: 'Followers',
        actions: [],
      ),
      body: dataIsThere
          ? Padding(
              padding: EdgeInsets.symmetric(vertical: 10.0),
              child: Scrollbar(
                  controller: _scrollController,
                  isAlwaysShown: true,
                  child: ListView.builder(
                    controller: _scrollController,
                    itemCount: resultFinal.length,
                    itemBuilder: (context, index) {
                      UserModel user = resultFinal[index];
                      return ListTile(
                        /*onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ProfileView(
                                      idUser: user.uid,
                                    ))),*/
                        leading: user.imageUrl == null
                            ? Container(
                                height: 50,
                                width: 50,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).canvasColor,
                                  border: Border.all(color: Colors.black),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(Icons.person),
                              )
                            : Container(
                                height: 50,
                                width: 50,
                                decoration: BoxDecoration(
                                    border: Border.all(color: Colors.black),
                                    shape: BoxShape.circle,
                                    image: DecorationImage(
                                        fit: BoxFit.cover,
                                        image: CachedNetworkImageProvider(
                                            user.imageUrl!))),
                              ),
                        title: Text(user.username),
                      );
                    },
                  )),
            )
          : Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).primaryColor,
              ),
            ),
    );
  }
}
