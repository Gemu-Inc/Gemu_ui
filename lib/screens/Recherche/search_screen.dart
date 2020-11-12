import 'package:Gemu/components/components.dart';
import 'package:flutter/material.dart';
import 'package:Gemu/core/data/data.dart';
import 'package:Gemu/core/models/models.dart';

class SearchScreen extends StatefulWidget {
  SearchScreen({Key key}) : super(key: key);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  @override
  Widget build(BuildContext context) {
    final List<Post> post = posts;
    return CustomScrollScreen(widgets: [
      Container(
          margin: EdgeInsets.only(left: 30.0, right: 30.0, bottom: 20.0),
          height: 50,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              border: Border.all(
                  color: Theme.of(context).secondaryHeaderColor, width: 2),
              borderRadius: BorderRadius.circular(50)),
          child: FlatButton(
              onPressed: () => Navigator.pushNamed(context, '/searchBar'),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.search,
                    color: Theme.of(context).secondaryHeaderColor,
                  ),
                  SizedBox(width: 5),
                  Text(
                    'Utilisateurs, clans ou jeux',
                    style: TextStyle(
                        color: Theme.of(context).secondaryHeaderColor,
                        fontSize: 19,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ))),
      Container(
          margin: EdgeInsets.only(top: 10.0, left: 20.0, right: 20.0),
          child: Column(
            children: [
              Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 10.0),
                    child: Text('Découvrir',
                        style: TextStyle(
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.bold,
                            fontSize: 20)),
                  )),
              Wrap(
                  direction: Axis.horizontal,
                  children: post
                      .map((e) => Container(
                          margin: EdgeInsets.all(5.0),
                          height: 150,
                          width: MediaQuery.of(context).size.width / 4,
                          child: e.imageUrl != null
                              ? Container(
                                  decoration: BoxDecoration(
                                      image: DecorationImage(
                                          fit: BoxFit.cover,
                                          image: NetworkImage(e.imageUrl))),
                                )
                              : e.videoUrl != null
                                  ? Container(
                                      color: Color(0xFF7C79A5),
                                    )
                                  : Container(
                                      color: Colors.red,
                                    )))
                      .toList())
            ],
          )),
    ]);
  }
}
