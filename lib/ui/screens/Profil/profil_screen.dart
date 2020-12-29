import 'package:Gemu/screensmodels/Profil/profil_screen_model.dart';
import 'package:Gemu/ui/widgets/custom_scroll_screen_animate.dart';
import 'package:Gemu/ui/widgets/profil_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:Gemu/models/user.dart';

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
                              child: StreamBuilder<UserC>(
                                  stream: model.userData,
                                  builder: (context, snapshot) {
                                    if (snapshot.hasData) {
                                      UserC _userC = snapshot.data;
                                      return _userC.photoURL == null
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
                                          : ProfilButton(
                                              currentUser: _userC.photoURL,
                                              width: 90,
                                              height: 90,
                                              colorFond: Colors.transparent,
                                              colorBorder: Colors.black,
                                              onPress: null,
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
                              stream: model.userData,
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  UserC _userC = snapshot.data;
                                  return Text(
                                    _userC.pseudo,
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
                        child: TabBar(
                            isScrollable: true,
                            controller: _tabController,
                            indicatorColor: Theme.of(context).accentColor,
                            indicatorSize: TabBarIndicatorSize.label,
                            labelPadding:
                                EdgeInsets.symmetric(horizontal: 30.0),
                            tabs: [
                              Tab(
                                text: 'Publications',
                              ),
                              Tab(
                                text: 'Statistics',
                              )
                            ]),
                      ),
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
