import 'package:Gemu/models/models.dart';
import 'package:Gemu/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:Gemu/data/data.dart';

class ClansScreen extends StatefulWidget {
  ClansScreen({Key key}) : super(key: key);

  @override
  _ClansScreenState createState() => _ClansScreenState();
}

class _ClansScreenState extends State<ClansScreen> {
  @override
  Widget build(BuildContext context) {
    return CustomScrollScreen(
        widgets: [ClansUtilisateursScreen(), ClassementScreen()]);
  }
}

class ClansUtilisateursScreen extends StatefulWidget {
  ClansUtilisateursScreen({Key key}) : super(key: key);

  @override
  _ClansUtilisateursScreenState createState() =>
      _ClansUtilisateursScreenState();
}

class _ClansUtilisateursScreenState extends State<ClansUtilisateursScreen> {
  List<Clan> triClanName() {
    List<Clan> clan = panelClans;
    clan.sort((a, b) => a.nameClan.compareTo(b.nameClan));
    return clan;
  }

  @override
  Widget build(BuildContext context) {
    List<Clan> clan = triClanName();
    return Container(
      height: 150,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          Row(
            children: clan
                .map((e) => GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MyClan(
                            clan: e,
                          ),
                        ),
                      );
                    },
                    child: Container(
                        margin: EdgeInsets.all(10.0),
                        width: 100,
                        child: Stack(
                          alignment: Alignment.topRight,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Theme.of(context).primaryColor,
                                      Theme.of(context).accentColor
                                    ]),
                                borderRadius: BorderRadius.circular(20.0),
                                boxShadow: [
                                  BoxShadow(
                                    color: Theme.of(context).cardColor,
                                    offset: Offset(10.0, 10.0),
                                    blurRadius: 4.0,
                                  ),
                                ],
                              ),
                              child: Stack(
                                children: [
                                  Positioned(
                                      left: 1.0,
                                      bottom: 5.0,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            e.nameClan,
                                            style: TextStyle(
                                              fontSize: 22.0,
                                              fontWeight: FontWeight.w600,
                                              letterSpacing: 1.2,
                                            ),
                                          ),
                                          Row(
                                            children: [
                                              SizedBox(width: 5.0),
                                              Text(
                                                '${e.pointsClan}',
                                              ),
                                            ],
                                          )
                                        ],
                                      ))
                                ],
                              ),
                            ),
                            Positioned(
                                top: 0.0,
                                right: 0.0,
                                child: Container(
                                    height: 80,
                                    width: 80,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(20),
                                          bottomLeft: Radius.circular(20),
                                          topRight: Radius.circular(20.0)),
                                      image: DecorationImage(
                                          fit: BoxFit.cover,
                                          image: AssetImage(e.imageUrl)),
                                    )))
                          ],
                        ))))
                .toList(),
          ),
          GestureDetector(
            onTap: () => print('Création d\'un clan'),
            child: Container(
              margin: EdgeInsets.all(10.0),
              width: 100,
              child: Stack(
                alignment: Alignment.topRight,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Theme.of(context).primaryColor,
                            Theme.of(context).accentColor
                          ]),
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                            left: 5.0,
                            bottom: 23.0,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Création',
                                  style: TextStyle(
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              ],
                            ))
                      ],
                    ),
                  ),
                  Positioned(
                      top: -14.0,
                      right: -14.0,
                      child: Container(
                          height: 90,
                          width: 90,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: Align(
                            alignment: Alignment.center,
                            child: Icon(
                              Icons.add,
                              size: 55,
                            ),
                          )))
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ClassementScreen extends StatelessWidget {
  const ClassementScreen({Key key}) : super(key: key);

  List<Clan> triClanPoints() {
    List<Clan> clan = panelClans;
    clan.sort((a, b) => b.pointsClan.compareTo(a.pointsClan));
    return clan;
  }

  @override
  Widget build(BuildContext context) {
    final List<Clan> clan = triClanPoints();
    return Container(
        height: 450,
        child: Column(
          children: [
            Padding(
                padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
                child: Container(
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text('Classement',
                        style: TextStyle(
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.bold,
                            fontSize: 20)),
                  ),
                )),
            Expanded(
              child: ListView.builder(
                  scrollDirection: Axis.vertical,
                  itemCount: clan.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Container(
                      margin: EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 0.0),
                      height: 40,
                      child: Stack(
                        children: [
                          Container(
                            height: 40,
                            decoration: BoxDecoration(
                                color: Theme.of(context).cardColor,
                                borderRadius: BorderRadius.circular(10)),
                            child: Row(
                              children: [
                                Spacer(
                                  flex: 1,
                                ),
                                Text('${index + 1}'),
                                Spacer(
                                  flex: 3,
                                ),
                                Text('${clan[index].nameClan}'),
                                Spacer(
                                  flex: 3,
                                ),
                                Text('${clan[index].pointsClan}'),
                                Spacer(
                                  flex: 1,
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    );
                  }),
            )
          ],
        ));
  }
}

class MyClan extends StatelessWidget {
  const MyClan({Key key, @required this.clan}) : super(key: key);

  final Clan clan;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: 200,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(45),
            ),
            gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF7C79A5), Color(0xFFDC804F)])),
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 15.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  height: 130,
                  width: 130,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: Theme.of(context).primaryColor, width: 5.0),
                      image: DecorationImage(
                          fit: BoxFit.cover, image: AssetImage(clan.imageUrl))),
                ),
              ),
            ),
            Align(
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Jeu'),
                    Text('${clan.pointsClan} Points'),
                    Text('Followers')
                  ],
                ))
          ],
        ),
      ),
    );
  }
}
