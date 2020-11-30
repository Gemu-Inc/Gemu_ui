import 'package:Gemu/screensmodels/Search/discover_screen_model.dart';
import 'package:Gemu/ui/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:Gemu/models/data.dart';
import 'package:Gemu/models/models.dart';
import 'package:stacked/stacked.dart';

class DiscoverScreen extends StatelessWidget {
  const DiscoverScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<Post> post = posts;
    return ViewModelBuilder<DiscoverScreenModel>.reactive(
      viewModelBuilder: () => DiscoverScreenModel(),
      builder: (context, model, child) => CustomScrollScreen(widgets: [
        Container(
            margin: EdgeInsets.only(
                left: 30.0, right: 30.0, bottom: 20.0, top: 20.0),
            height: 50,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                border: Border.all(
                    color: Theme.of(context).secondaryHeaderColor, width: 2),
                borderRadius: BorderRadius.circular(50)),
            child: FlatButton(
                onPressed: () => model.navigateToSearch(),
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
      ]),
    );
  }
}