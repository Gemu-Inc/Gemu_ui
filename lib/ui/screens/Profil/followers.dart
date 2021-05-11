import 'package:Gemu/constants/variables.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:Gemu/ui/screens/Home/profile_view.dart';

class Followers extends StatefulWidget {
  final String? idUser;

  Followers({this.idUser});

  @override
  FollowersState createState() => FollowersState();
}

class FollowersState extends State<Followers> {
  bool dataIsThere = false;

  List result = [];
  List resultFinal = [];

  ScrollController? _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    getAllData();
  }

  @override
  void dispose() {
    _scrollController!.dispose();
    super.dispose();
  }

  getAllData() async {
    var doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.idUser)
        .collection('followers')
        .get();
    setState(() {
      result = doc.docs;
    });

    for (int i = 0; i < result.length; i++) {
      DocumentSnapshot docSnap = result[i];
      var doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(docSnap.id)
          .get();
      resultFinal.add(doc);
    }

    setState(() {
      dataIsThere = !dataIsThere;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              elevation: 0,
              backgroundColor: Colors.transparent,
              leading: IconButton(
                  icon: Icon(Icons.arrow_back_ios),
                  onPressed: () => Navigator.pop(context)),
              title: Text(
                'Followers',
                style: mystyle(15),
              ),
            ),
          ),
          preferredSize: Size.fromHeight(60)),
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
                      DocumentSnapshot<Map<String, dynamic>>? documentSnapshot =
                          resultFinal[index];
                      return ListTile(
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ProfileView(
                                      idUser: documentSnapshot!.data()!['id'],
                                    ))),
                        leading: Container(
                          height: 50,
                          width: 50,
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.black),
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                  fit: BoxFit.cover,
                                  image: CachedNetworkImageProvider(
                                      documentSnapshot!.data()!['photoURL']))),
                        ),
                        title: Text(documentSnapshot.data()!['pseudo']),
                      );
                    },
                  )),
            )
          : Center(
              child: CircularProgressIndicator(),
            ),
    );
  }
}
