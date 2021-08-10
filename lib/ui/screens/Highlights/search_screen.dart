import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:gemu/ui/constants/constants.dart';

import 'package:gemu/ui/screens/Games/game_focus_screen.dart';
import 'package:gemu/models/game.dart';

class SearchScreen extends StatefulWidget {
  @override
  SearchScreenState createState() => SearchScreenState();
}

class SearchScreenState extends State<SearchScreen>
    with SingleTickerProviderStateMixin {
  TextEditingController _searchController = TextEditingController();

  TabController? _tabController;
  int? currentTabIndex;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    currentTabIndex = 0;
    _tabController!.addListener(_onTabChanged);
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _tabController!.removeListener(_onTabChanged);
    _tabController!.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (!_tabController!.indexIsChanging) {
      setState(() {
        print('Changing to Tab: ${_tabController!.index}');
        currentTabIndex = _tabController!.index;
      });
    }
  }

  _onSearchChanged() {
    if (_tabController!.index == 0) {}
    if (_tabController!.index == 1) {}
    if (_tabController!.index == 2) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 6,
        leading: IconButton(
            icon: Icon(Icons.arrow_back_ios),
            onPressed: () => Navigator.pop(context)),
        title: TextFormField(
          controller: _searchController,
          autofocus: false,
          cursorColor: Theme.of(context).primaryColor,
          decoration: InputDecoration(
              labelText: 'Search',
              labelStyle: TextStyle(color: Theme.of(context).primaryColor),
              focusedBorder: InputBorder.none,
              enabledBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              disabledBorder: InputBorder.none),
        ),
        actions: [
          IconButton(
              icon: Icon(Icons.clear),
              onPressed: () => _searchController.clear())
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(25),
          child: TabBar(
              controller: _tabController,
              labelPadding: EdgeInsets.only(bottom: 5.0),
              labelColor: Theme.of(context).primaryColor,
              indicatorColor: Theme.of(context).primaryColor,
              unselectedLabelColor: Colors.grey,
              tabs: [Text('All'), Text('User'), Text('Game'), Text('Hashtag')]),
        ),
      ),
      body: TabBarView(
          physics: AlwaysScrollableScrollPhysics(),
          controller: _tabController,
          children: [searchAll(), searchUser(), searchGame(), searchHastag()]),
    );
  }

  Widget searchAll() {
    return Center(
        child: Text(
      'Search game, user, hashtag',
      style: mystyle(13),
    ));
  }

  Widget searchUser() {
    return Center(
        child: Text(
      'Search user',
      style: mystyle(13),
    ));
  }

  Widget searchGame() {
    return Center(
        child: Text(
      'Search game',
      style: mystyle(13),
    ));
  }

  Widget searchHastag() {
    return Center(
        child: Text(
      'Search hashtag',
      style: mystyle(13),
    ));
  }
}
