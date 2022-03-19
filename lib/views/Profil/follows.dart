import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:gemu/models/user.dart';
import 'package:gemu/constants/constants.dart';
import 'package:gemu/views/Profil/profil_screen.dart';
import 'package:gemu/widgets/app_bar_custom.dart';

class Follows extends StatefulWidget {
  final String idUser;

  Follows({required this.idUser});

  @override
  FollowsState createState() => FollowsState();
}

class FollowsState extends State<Follows> {
  bool dataIsThere = false;

  List result = [];
  List<UserModel> resultFinal = [];

  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    getFollows();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  getFollows() async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.idUser)
        .collection('following')
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
        title: 'Follows',
        actions: [],
      ),
      body: dataIsThere
          ? resultFinal.length == 0
              ? Center(
                  child: Text(
                    'Pas encore de follows',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10.0, vertical: 5.0),
                  controller: _scrollController,
                  physics: AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics()),
                  itemCount: resultFinal.length,
                  itemBuilder: (context, index) {
                    UserModel user = resultFinal[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 15.0),
                      child: ListTile(
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    ProfilUser(userPostID: user.uid))),
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
                                          user.imageUrl!)),
                                )),
                        title: Text(user.username),
                      ),
                    );
                  },
                )
          : Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
    );
  }
}
