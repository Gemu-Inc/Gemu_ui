import 'package:Gemu/screensmodels/Profil/profil_screen_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

class ProfilMenu extends StatefulWidget {
  @override
  _ProfilMenuState createState() => _ProfilMenuState();
}

class _ProfilMenuState extends State<ProfilMenu>
    with SingleTickerProviderStateMixin {
  int selectedIndex = 0;

  TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: 2, initialIndex: 0);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<ProfilScreenModel>.reactive(
      viewModelBuilder: () => ProfilScreenModel(),
      builder: (context, model, child) => Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: PreferredSize(
              child: Container(
                height: 280,
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                      Theme.of(context).primaryColor,
                      Theme.of(context).accentColor
                    ])),
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
                                  onPressed: () =>
                                      model.navigateToNavigation())),
                          Align(
                              alignment: Alignment.center,
                              child: StreamBuilder(
                                  stream: FirebaseFirestore.instance
                                      .collection('users')
                                      .doc(
                                          FirebaseAuth.instance.currentUser.uid)
                                      .snapshots(),
                                  builder: (context, snapshot) {
                                    if (snapshot.hasData) {
                                      return snapshot.data['photoURL'] == null
                                          ? Container(
                                              height: 90,
                                              width: 90,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                    color: Colors.black,
                                                    width: 2.0),
                                              ),
                                              child: Icon(
                                                Icons.person,
                                                size: 50,
                                              ))
                                          : Container(
                                              margin: EdgeInsets.all(3.0),
                                              width: 90,
                                              height: 90,
                                              decoration: BoxDecoration(
                                                  color: Colors.transparent,
                                                  shape: BoxShape.circle,
                                                  border: Border.all(
                                                      color: Color(0xFF222831)),
                                                  image: DecorationImage(
                                                      fit: BoxFit.cover,
                                                      image: NetworkImage(
                                                          snapshot.data[
                                                              'photoURL']))),
                                            );
                                    } else {
                                      return CircularProgressIndicator();
                                    }
                                  })),
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
                      Align(
                          alignment: Alignment.center,
                          child: StreamBuilder(
                              stream: FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(FirebaseAuth.instance.currentUser.uid)
                                  .snapshots(),
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  return Text(
                                    snapshot.data['pseudo'],
                                    style: TextStyle(fontSize: 23),
                                  );
                                } else {
                                  return CircularProgressIndicator(
                                    strokeWidth: 3,
                                    valueColor: AlwaysStoppedAnimation(
                                        Theme.of(context).primaryColor),
                                  );
                                }
                              })),
                      SizedBox(
                        height: 20,
                      ),
                      Padding(
                        padding: EdgeInsets.only(right: 15.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Container(
                              height: 60,
                              width: 70,
                              child: Stack(
                                children: [
                                  Align(
                                      alignment: Alignment.topCenter,
                                      child: Text(
                                        'Followers',
                                      )),
                                  Align(
                                    alignment: Alignment.bottomCenter,
                                    child: Text(
                                      '0',
                                      style: TextStyle(fontSize: 23),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Container(
                              height: 60,
                              width: 50,
                              child: Stack(
                                children: [
                                  Align(
                                      alignment: Alignment.topCenter,
                                      child: Text(
                                        'Points',
                                      )),
                                  Align(
                                    alignment: Alignment.bottomCenter,
                                    child: Text(
                                      '0',
                                      style: TextStyle(fontSize: 23),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Container(
                              height: 60,
                              width: 50,
                              child: Stack(
                                children: [
                                  Align(
                                      alignment: Alignment.topCenter,
                                      child: Text(
                                        'Follows',
                                      )),
                                  Align(
                                    alignment: Alignment.bottomCenter,
                                    child: Text(
                                      '0',
                                      style: TextStyle(fontSize: 23),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              preferredSize: Size.fromHeight(280)),
          body: CustomScrollView(
            physics: BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                  child: PreferredSize(
                      child: Container(
                          alignment: Alignment.center,
                          width: MediaQuery.of(context).size.width,
                          child: Padding(
                            padding: EdgeInsets.only(top: 10.0),
                            child: TabBar(
                                controller: _tabController,
                                isScrollable: true,
                                indicatorSize: TabBarIndicatorSize.tab,
                                labelColor: Theme.of(context).primaryColor,
                                unselectedLabelColor: Colors.grey,
                                indicator: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: Theme.of(context).canvasColor),
                                tabs: [
                                  Tab(
                                    text: 'Publications',
                                  ),
                                  Tab(
                                    text: 'Statistics',
                                  )
                                ]),
                          )),
                      preferredSize: Size.fromHeight(100))),
              SliverFillRemaining(
                child: TabBarView(controller: _tabController, children: [
                  Center(
                    child: Text('Publication\'s content'),
                  ),
                  Center(
                    child: Text('Statistics\'s content'),
                  )
                ]),
              )
            ],
          )),
    );
  }
}
