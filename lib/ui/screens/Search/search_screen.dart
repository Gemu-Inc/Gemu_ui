import 'package:Gemu/screensmodels/Search/search_screen_model.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final List<Widget> _screens = [
    Scaffold(
        body: CustomScrollView(
      slivers: [
        SliverPadding(
          padding: EdgeInsets.symmetric(vertical: 10.0),
          sliver: SliverToBoxAdapter(
              child: Container(
            child: Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding:
                      EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
                  child: Text(
                    'Recherches récentes',
                    style: TextStyle(
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.bold,
                        fontSize: 16),
                  ),
                )),
          )),
        )
      ],
    )),
    Scaffold(
        body: CustomScrollView(
      slivers: [
        SliverPadding(
          padding: EdgeInsets.symmetric(vertical: 10.0),
          sliver: SliverToBoxAdapter(
              child: Container(
            child: Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding:
                      EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
                  child: Text(
                    'Recherches récentes',
                    style: TextStyle(
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.bold,
                        fontSize: 16),
                  ),
                )),
          )),
        )
      ],
    )),
    Scaffold(
        body: CustomScrollView(
      slivers: [
        SliverPadding(
          padding: EdgeInsets.symmetric(vertical: 10.0),
          sliver: SliverToBoxAdapter(
              child: Container(
            child: Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding:
                      EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
                  child: Text(
                    'Recherches récentes',
                    style: TextStyle(
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.bold,
                        fontSize: 16),
                  ),
                )),
          )),
        )
      ],
    )),
    Scaffold(
        body: CustomScrollView(
      slivers: [
        SliverPadding(
          padding: EdgeInsets.symmetric(vertical: 10.0),
          sliver: SliverToBoxAdapter(
              child: Container(
            child: Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding:
                      EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
                  child: Text(
                    'Recherches récentes',
                    style: TextStyle(
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.bold,
                        fontSize: 16),
                  ),
                )),
          )),
        )
      ],
    ))
  ];
  final List<IconData> _icons = [
    Icons.all_inclusive,
    Icons.person,
    Icons.people,
    Icons.videogame_asset
  ];
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<SearchScreenModel>.reactive(
      viewModelBuilder: () => SearchScreenModel(),
      builder: (context, model, child) => DefaultTabController(
        initialIndex: 0,
        length: _icons.length,
        child: Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0.0,
            leading: IconButton(
                icon: Icon(Icons.arrow_back_ios),
                onPressed: () => Navigator.pop(context)),
            title: Container(
                child: TextFormField(
              decoration: const InputDecoration(
                hintText: 'Rechercher',
              ),
              keyboardType: TextInputType.text,
            )),
            bottom: PreferredSize(
                child: SearchCategorie(
                    icons: _icons,
                    selectedIndex: _selectedIndex,
                    onTap: (index) => setState(() => _selectedIndex = index)),
                preferredSize: Size.fromHeight(60)),
          ),
          body: TabBarView(
              physics: NeverScrollableScrollPhysics(), children: _screens),
        ),
      ),
    );
  }
}

class SearchCategorie extends StatelessWidget {
  final List<IconData> icons;
  final int selectedIndex;
  final Function(int) onTap;

  const SearchCategorie(
      {Key key,
      @required this.icons,
      @required this.selectedIndex,
      @required this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(5.0),
      height: 50,
      decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(10.0)),
      child: TabBar(
        indicatorPadding: EdgeInsets.only(left: 15.0, right: 15.0),
        indicatorColor: Theme.of(context).accentColor,
        tabs: icons
            .asMap()
            .map(
              (i, e) => MapEntry(
                i,
                Tab(
                  icon: Icon(
                    e,
                    size: 40,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
            )
            .values
            .toList(),
        onTap: onTap,
      ),
    );
  }
}
