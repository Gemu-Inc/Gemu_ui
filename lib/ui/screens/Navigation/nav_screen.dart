import 'package:Gemu/screensmodels/Navigation/nav_screen_model.dart';
import 'package:Gemu/ui/widgets/bottom_toolbar_noopacity.dart';
import 'package:Gemu/ui/widgets/bottom_toolbar_withopacity.dart';
import 'package:flutter/material.dart';
import 'package:Gemu/ui/screens/screens.dart';
import 'package:Gemu/ui/screens/Direct/direct_screen.dart';
import 'package:Gemu/ui/widgets/widgets.dart';
import 'package:stacked/stacked.dart';

class NavScreen extends StatefulWidget {
  NavScreen({Key key}) : super(key: key);

  @override
  _NavScreenState createState() => _NavScreenState();
}

class _NavScreenState extends State<NavScreen>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKeyNav = GlobalKey<ScaffoldState>();

  TabController _tabController;
  int currentTabIndex = 0;

  final List<IconData> _icons = [
    Icons.home,
    Icons.map,
    Icons.videogame_asset,
    Icons.play_arrow
  ];

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: _icons.length, vsync: this);
    _tabController.addListener(_onTabChanged);
    currentTabIndex = 0;
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging)
      setState(() {
        print('Changing to Tab: ${_tabController.index}');
        currentTabIndex = _tabController.index;
      });
  }

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<NavScreenModel>.reactive(
        viewModelBuilder: () => NavScreenModel(),
        builder: (context, model, child) => Scaffold(
              key: _scaffoldKeyNav,
              backgroundColor: Color(0xFF1A1C25),
              endDrawer: MessagerieMenu(),
              body: Stack(
                children: [
                  TabBarView(
                      physics: NeverScrollableScrollPhysics(),
                      controller: _tabController,
                      children: [
                        HomeScreen(),
                        DiscoverScreen(),
                        GamesScreen(),
                        DirectScreen()
                      ]),
                  currentTabIndex == 0
                      ? BottomToolBarWithOpa(
                          icons: _icons, controller: _tabController)
                      : BottomToolBarNoOpa(
                          icons: _icons, controller: _tabController),
                  BottomShare()
                ],
              ),
            ));
  }
}
