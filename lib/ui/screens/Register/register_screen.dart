import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:algolia/algolia.dart';
import 'package:country_calling_code_picker/picker.dart';

import 'package:gemu/services/auth_service.dart';
import 'package:gemu/ui/constants/size_config.dart';
import 'package:gemu/ui/constants/constants.dart';
import 'package:gemu/ui/screens/Welcome/welcome_screen.dart';
import 'package:gemu/ui/widgets/snack_bar_custom.dart';
import 'package:gemu/ui/widgets/text_field_custom.dart';
import 'package:gemu/services/algolia_service.dart';
import 'package:gemu/models/game.dart';
import 'package:sticky_headers/sticky_headers/widget.dart';

class RegisterScreen extends StatefulWidget {
  @override
  RegisterScreenState createState() => RegisterScreenState();
}

class RegisterScreenState extends State<RegisterScreen> {
  Duration _duration = Duration(seconds: 1);
  bool isDayMood = false;
  bool dataIsThere = false;
  bool isLoading = false;
  bool isLoadingMoreData = false;
  bool isResultLoading = false;

  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late TextEditingController _confirmPasswordController;
  late TextEditingController _usernameController;

  String value = "";
  bool isSearching = false;
  late TextEditingController _searchController;
  Algolia algolia = AlgoliaService.algolia;
  List<AlgoliaObjectSnapshot> gamesAlgolia = [];

  late FocusNode _focusNodeEmail;
  late FocusNode _focusNodePassword;
  late FocusNode _focusNodeConfirmPassword;
  late FocusNode _focusNodeUsername;
  late FocusNode _focusNodeSearch;

  late PageController _pageController;
  int currentPageIndex = 0;

  List<Game> allGames = [];
  List<Game> gamesFollow = [];
  List<Game> newGames = [];

  ScrollController _mainScrollController = ScrollController();
  ScrollController _gamesScrollController = ScrollController();
  bool isStickyOnTop = false;

  Country? _selectedCountry;

  void initCountry() async {
    final country = await getDefaultCountry(context);
    setState(() {
      _selectedCountry = country;
    });
  }

  void _onPressedShowBottomSheet() async {
    final country = await showCountryPickerSheet(context,
        cornerRadius: 10.0,
        heightFactor: 0.8,
        title: Text(
          'Choose region',
          style: mystyle(15),
        ));
    if (country != null) {
      setState(() {
        _selectedCountry = country;
      });
    }
  }

  void timeMood() {
    int hour = DateTime.now().hour;

    if (hour >= 8 && hour <= 18) {
      setState(() {
        isDayMood = true;
      });
    } else {
      setState(() {
        isDayMood = false;
      });
    }
  }

  getGames() async {
    await FirebaseFirestore.instance
        .collection('games')
        .orderBy('name')
        .limit(12)
        .get()
        .then((value) {
      for (var item in value.docs) {
        allGames.add(Game.fromMap(item, item.data()));
      }
    });

    if (mounted && !dataIsThere) {
      setState(() {
        dataIsThere = true;
      });
    }
  }

  loadMoreData() async {
    setState(() {
      if (newGames.length != 0) {
        newGames.clear();
      }
      if (isResultLoading) {
        isResultLoading = false;
      }
      isLoadingMoreData = true;
    });

    Game game = allGames.last;
    bool add;

    await FirebaseFirestore.instance
        .collection('games')
        .orderBy('name')
        .startAfterDocument(game.snapshot!)
        .limit(12)
        .get()
        .then((value) {
      for (var item in value.docs) {
        newGames.add(Game.fromMap(item, item.data()));
      }
    });

    for (var i = 0; i < newGames.length; i++) {
      if (allGames.any((element) => element.name == newGames[i].name) ||
          gamesFollow.any((element) => element.name == newGames[i].name)) {
        add = false;
      } else {
        add = true;
      }

      if (add) {
        allGames.add(newGames[i]);
      }
    }

    await Future.delayed(Duration(seconds: 1));

    setState(() {
      isLoadingMoreData = false;
      isResultLoading = true;
    });
  }

  Future<bool> _willPopCallback() async {
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (BuildContext context) => WelcomeScreen()),
        (route) => false);
    return true;
  }

  _hideKeyboard() {
    FocusScope.of(context).requestFocus(FocusNode());
  }

  _searchGames(String value) async {
    if (gamesAlgolia.length != 0) {
      gamesAlgolia.clear();
    }

    if (value.isNotEmpty) {
      setState(() {
        isSearching = true;
      });

      AlgoliaQuery query = algolia.instance.index('games');
      query = query.query(value);

      gamesAlgolia = (await query.getObjects()).hits;

      print('${gamesAlgolia.length}');

      setState(() {
        isSearching = false;
      });
    }
  }

  _registerAccount(String email, String password, String confirmPassword,
      String username, List<Game> gamesFollow, String country) async {
    if (email.isEmpty ||
        username.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty ||
        password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBarCustom(
          context: context,
          error: 'Write user information',
          padddingVertical: 40.0));
    } else if (gamesFollow.length == 0 || gamesFollow.length == 1) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBarCustom(
          context: context,
          error: 'Selects at least two games',
          padddingVertical: 40.0));
    } else {
      AuthService.instance.registerUser(context, gamesFollow, username, email,
          password, confirmPassword, country);
    }
  }

  @override
  void initState() {
    super.initState();
    timeMood();
    initCountry();
    getGames();

    _pageController = PageController(initialPage: currentPageIndex);

    _emailController = TextEditingController();
    _focusNodeEmail = FocusNode();

    _usernameController = TextEditingController();
    _focusNodeUsername = FocusNode();

    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
    _focusNodePassword = FocusNode();
    _focusNodeConfirmPassword = FocusNode();

    _searchController = TextEditingController();
    _focusNodeSearch = FocusNode();

    _emailController.addListener(() {
      setState(() {});
    });
    _usernameController.addListener(() {
      setState(() {});
    });
    _passwordController.addListener(() {
      setState(() {});
    });
    _confirmPasswordController.addListener(() {
      setState(() {});
    });

    _focusNodeEmail.addListener(() {
      setState(() {});
    });
    _focusNodeUsername.addListener(() {
      setState(() {});
    });
    _focusNodePassword.addListener(() {
      setState(() {});
    });
    _focusNodeConfirmPassword.addListener(() {
      setState(() {});
    });

    _focusNodeSearch.addListener(() {
      if (_focusNodeSearch.hasFocus) {
        _mainScrollController.animateTo(
            _mainScrollController.position.maxScrollExtent,
            duration: Duration(milliseconds: 500),
            curve: Curves.easeOut);
      } else {
        _mainScrollController.animateTo(
            _mainScrollController.position.minScrollExtent,
            duration: Duration(milliseconds: 500),
            curve: Curves.easeOut);
      }
    });

    _mainScrollController.addListener(() {
      if (_mainScrollController.offset >=
              _mainScrollController.position.maxScrollExtent &&
          !_mainScrollController.position.outOfRange) {
        print('en bas');
        loadMoreData();
      }
    });
  }

  @override
  void deactivate() {
    _emailController.removeListener(() {
      setState(() {});
    });
    _usernameController.removeListener(() {
      setState(() {});
    });
    _passwordController.removeListener(() {
      setState(() {});
    });
    _confirmPasswordController.removeListener(() {
      setState(() {});
    });

    _focusNodeEmail.removeListener(() {
      setState(() {});
    });
    _focusNodeUsername.removeListener(() {
      setState(() {});
    });
    _focusNodePassword.removeListener(() {
      setState(() {});
    });
    _focusNodeConfirmPassword.addListener(() {
      setState(() {});
    });
    _focusNodeSearch.removeListener(() {
      if (_focusNodeSearch.hasFocus) {
        _mainScrollController.animateTo(
            _mainScrollController.position.maxScrollExtent,
            duration: Duration(milliseconds: 500),
            curve: Curves.easeOut);
      } else {
        _mainScrollController.animateTo(
            _mainScrollController.position.minScrollExtent,
            duration: Duration(milliseconds: 500),
            curve: Curves.easeOut);
      }
    });

    _mainScrollController.removeListener(() {
      if (_mainScrollController.offset >=
              _mainScrollController.position.maxScrollExtent &&
          !_mainScrollController.position.outOfRange) {
        print('en bas');
        loadMoreData();
      }
    });

    super.deactivate();
  }

  @override
  void dispose() {
    _focusNodeEmail.dispose();
    _focusNodePassword.dispose();
    _focusNodeUsername.dispose();
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _pageController.dispose();

    _searchController.dispose();
    _focusNodeSearch.dispose();

    _mainScrollController.dispose();
    _gamesScrollController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    List<Color> lightBgColors = [
      Color(0xFF947B8F),
      Color(0xFFB27D75),
      Color(0xFFE38048),
    ];
    var darkBgColors = [
      Color(0xFF4075DA),
      Color(0xFF6E78B1),
      Color(0xFF947B8F),
    ];

    final country = _selectedCountry;

    return WillPopScope(
        child: AnimatedContainer(
          duration: _duration,
          curve: Curves.easeInOut,
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: isDayMood ? lightBgColors : darkBgColors,
            ),
          ),
          child: Container(
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                    Theme.of(context).scaffoldBackgroundColor.withOpacity(0.1),
                    Theme.of(context).scaffoldBackgroundColor.withOpacity(0.8)
                  ])),
              child: Scaffold(
                backgroundColor: Colors.transparent,
                appBar: AppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  leading: Container(
                    padding: EdgeInsets.all(7.5),
                    child: ElevatedButton(
                      onPressed: () => Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (BuildContext context) =>
                                  WelcomeScreen()),
                          (route) => false),
                      style: TextButton.styleFrom(
                          alignment: Alignment.center,
                          backgroundColor: Colors.black.withOpacity(0.3),
                          elevation: 0,
                          shape: CircleBorder(
                              side: BorderSide(color: Colors.black))),
                      child: Icon(
                        Icons.arrow_back_ios,
                        size: 16,
                      ),
                    ),
                  ),
                  title: Text('Register', style: mystyle(25, Colors.white)),
                  centerTitle: true,
                ),
                body: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Expanded(
                        child: PageView(
                      controller: _pageController,
                      onPageChanged: (index) {
                        if (index == 0) {
                          _hideKeyboard();
                          setState(() {
                            currentPageIndex = 0;
                          });
                        } else {
                          _hideKeyboard();
                          setState(() {
                            currentPageIndex = 1;
                          });
                        }
                      },
                      children: [firstPage(country), secondPage()],
                    )),
                    Container(
                      height: MediaQuery.of(context).size.height / 14,
                      alignment: Alignment.center,
                      child: bottomBar(country),
                    ),
                  ],
                ),
              )),
        ),
        onWillPop: () => _willPopCallback());
  }

  Widget firstPage(Country? country) {
    return ListView(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      physics: AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
      children: [
        Container(
          width: MediaQuery.of(context).size.width,
          padding: EdgeInsets.only(left: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'User information',
                style: mystyle(28),
              ),
              VerticalSpacing(
                of: 5.0,
              ),
              Text('Enter your personnal information'),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
          child: Text(
            'Enter your username',
            style: mystyle(12),
          ),
        ),
        Container(
          width: SizeConfig.screenWidth,
          margin: EdgeInsets.only(left: 20.0, right: 20.0),
          child: TextFieldCustom(
            context: context,
            controller: _usernameController,
            focusNode: _focusNodeUsername,
            label: 'Username',
            obscure: false,
            icon: Icons.person,
            textInputAction: TextInputAction.next,
            clear: () {
              setState(() {
                _usernameController.clear();
              });
            },
            submit: (value) {
              value = _usernameController.text;
              _focusNodeUsername.unfocus();
              FocusScope.of(context).requestFocus(_focusNodeEmail);
            },
          ),
        ),
        VerticalSpacing(
          of: 20,
        ),
        Padding(
          padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
          child: Text(
            'Enter your email',
            style: mystyle(12),
          ),
        ),
        Container(
          width: SizeConfig.screenWidth,
          margin: EdgeInsets.only(left: 20.0, right: 20.0),
          child: TextFieldCustom(
            context: context,
            controller: _emailController,
            focusNode: _focusNodeEmail,
            label: 'Email',
            obscure: false,
            icon: Icons.mail,
            textInputAction: TextInputAction.next,
            textInputType: TextInputType.emailAddress,
            clear: () {
              setState(() {
                _emailController.clear();
              });
            },
            submit: (value) {
              value = _emailController.text;
              _focusNodeEmail.unfocus();
              FocusScope.of(context).requestFocus(_focusNodePassword);
            },
          ),
        ),
        VerticalSpacing(
          of: 20,
        ),
        Padding(
          padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
          child: Text(
            'Enter your password',
            style: mystyle(12),
          ),
        ),
        Container(
            width: SizeConfig.screenWidth,
            margin: EdgeInsets.only(left: 20.0, right: 20.0),
            child: TextFieldCustom(
              context: context,
              controller: _passwordController,
              focusNode: _focusNodePassword,
              label: 'Password',
              obscure: true,
              icon: Icons.lock,
              textInputAction: TextInputAction.next,
              clear: () {
                setState(() {
                  _passwordController.clear();
                });
              },
              submit: (value) {
                value = _passwordController.text;
                _focusNodePassword.unfocus();
                FocusScope.of(context).requestFocus(_focusNodeConfirmPassword);
              },
            )),
        VerticalSpacing(
          of: 10.0,
        ),
        Container(
            width: SizeConfig.screenWidth,
            margin: EdgeInsets.only(left: 20.0, right: 20.0),
            child: TextFieldCustom(
              context: context,
              controller: _confirmPasswordController,
              focusNode: _focusNodeConfirmPassword,
              label: 'Confirm password',
              obscure: true,
              icon: Icons.lock,
              textInputAction: TextInputAction.go,
              clear: () {
                setState(() {
                  _confirmPasswordController.clear();
                });
              },
              submit: (value) {
                value = _confirmPasswordController.text;
                _focusNodeConfirmPassword.unfocus();
              },
            )),
        VerticalSpacing(
          of: 20.0,
        ),
        Padding(
          padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
          child: Text(
            'Select your nationnality',
            style: mystyle(11),
          ),
        ),
        Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              country == null
                  ? Container()
                  : Column(
                      children: <Widget>[
                        Container(
                          height: 30,
                          width: 50,
                          child: Image.asset(
                            country.flag,
                            package: countryCodePackageName,
                          ),
                        ),
                        SizedBox(
                          height: 5.0,
                        ),
                        Text(
                          '${country.name} (${country.countryCode})',
                          textAlign: TextAlign.center,
                          style: mystyle(11),
                        ),
                      ],
                    ),
              MaterialButton(
                child: Text('Select'),
                color: Theme.of(context).canvasColor,
                onPressed: _onPressedShowBottomSheet,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget secondPage() {
    return ListView(
      controller: _mainScrollController,
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      physics: AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
      children: [
        topSelectionGames(),
        StickyHeader(
          controller: _mainScrollController,
          header: _getStickyWidget(),
          content: dataIsThere
              ? Padding(
                  padding: EdgeInsets.symmetric(vertical: 15.0),
                  child: searchGames(),
                )
              : Center(
                  child: CircularProgressIndicator(),
                ),
        ),
      ],
    );
  }

  Widget topSelectionGames() {
    return gamesFollow.length != 0
        ? Container(
            height: 250,
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.only(left: 20.0),
            child: Column(
              children: [
                Text(
                  'Selected games',
                  style: mystyle(28),
                ),
                VerticalSpacing(
                  of: 5.0,
                ),
                Text('Selects at least two games'),
                VerticalSpacing(
                  of: 10.0,
                ),
                Container(
                    height: MediaQuery.of(context).size.height / 8,
                    child: ListView.builder(
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      itemCount: gamesFollow.length,
                      itemBuilder: (_, index) {
                        Game game = gamesFollow[index];
                        return Container(
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: 5.0, horizontal: 5.0),
                            child: Container(
                              height: 70,
                              width: 70,
                              child: Stack(
                                children: [
                                  Align(
                                    alignment: Alignment.center,
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          gamesFollow.remove(game);
                                          allGames.add(game);
                                        });
                                      },
                                      child: Container(
                                        height: 60,
                                        width: 60,
                                        decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                                colors: [
                                                  Theme.of(context)
                                                      .primaryColor,
                                                  Theme.of(context).accentColor
                                                ]),
                                            border:
                                                Border.all(color: Colors.black),
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            image: DecorationImage(
                                                image:
                                                    CachedNetworkImageProvider(
                                                        game.imageUrl),
                                                fit: BoxFit.cover)),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                      bottom: 0,
                                      right: 0,
                                      child: GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            gamesFollow.remove(game);
                                            allGames.add(game);
                                          });
                                        },
                                        child: Container(
                                            height: 25,
                                            width: 25,
                                            decoration: BoxDecoration(
                                                color: Colors.red[400],
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                    color: Colors.black)),
                                            child: Icon(
                                              Icons.remove,
                                              size: 20,
                                              color: Colors.black,
                                            )),
                                      )),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    )),
                VerticalSpacing(of: 10.0),
                Text(
                  'Selection games',
                  style: mystyle(28),
                ),
                VerticalSpacing(
                  of: 5.0,
                ),
                Text('Choose the games you want to follow'),
                VerticalSpacing(
                  of: 5.0,
                ),
              ],
            ),
          )
        : Container(
            height: 100,
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.only(left: 20.0),
            child: Column(
              children: [
                Text(
                  'Selection games',
                  style: mystyle(28),
                ),
                VerticalSpacing(
                  of: 5.0,
                ),
                Text('Choose the games you want to follow'),
              ],
            ),
          );
  }

  Widget _getStickyWidget() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: TextFieldCustom(
        context: context,
        controller: _searchController,
        focusNode: _focusNodeSearch,
        label: 'Search',
        obscure: false,
        icon: Icons.search,
        textInputAction: TextInputAction.search,
        clear: () {
          setState(() {
            _searchController.clear();
          });
        },
        submit: (value) {
          value = _searchController.text;
          _searchGames(value);
        },
      ),
    );
  }

  Widget searchGames() {
    return Container(
      child: isSearching
          ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  height: 15.0,
                  width: 15.0,
                  child: CircularProgressIndicator(
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                SizedBox(
                  width: 5.0,
                ),
                Text(
                  _searchController.text.length < 10
                      ? 'Recherche de "${_searchController.text}.."'
                      : 'Recherche de "${_searchController.text.substring(0, 10)}.."',
                  style: mystyle(11),
                )
              ],
            )
          : _searchController.text.isEmpty
              ? selectionGames()
              : gamesAlgolia.length == 0
                  ? Center(
                      child: Text(
                        'No games found',
                        style: mystyle(12),
                      ),
                    )
                  : GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          childAspectRatio: 1.0,
                          crossAxisSpacing: 6,
                          mainAxisSpacing: 6),
                      shrinkWrap: true,
                      itemCount: gamesAlgolia.length,
                      itemBuilder: (_, index) {
                        Game gameAlgolia = Game.fromMapAlgolia(
                            gamesAlgolia[index], gamesAlgolia[index].data);
                        return gamesFollow.any(
                                (element) => element.name == gameAlgolia.name)
                            ? Container(
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 5.0),
                                      child: Container(
                                        height: 70,
                                        width: 70,
                                        child: Stack(
                                          children: [
                                            Align(
                                              alignment: Alignment.center,
                                              child: GestureDetector(
                                                onTap: () {
                                                  setState(() {
                                                    gamesFollow.removeWhere(
                                                        (element) =>
                                                            element.name ==
                                                            gameAlgolia.name);
                                                    allGames.add(gameAlgolia);
                                                  });

                                                  _focusNodeSearch.unfocus();
                                                  _searchController.clear();
                                                },
                                                child: Container(
                                                  height: 60,
                                                  width: 60,
                                                  decoration: BoxDecoration(
                                                      gradient: LinearGradient(
                                                          begin:
                                                              Alignment.topLeft,
                                                          end: Alignment
                                                              .bottomRight,
                                                          colors: [
                                                            Theme.of(context)
                                                                .primaryColor,
                                                            Theme.of(context)
                                                                .accentColor
                                                          ]),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                      border: Border.all(
                                                          color: Colors.black),
                                                      image: DecorationImage(
                                                          fit: BoxFit.cover,
                                                          image: CachedNetworkImageProvider(
                                                              gameAlgolia
                                                                  .imageUrl))),
                                                ),
                                              ),
                                            ),
                                            Positioned(
                                                bottom: 0,
                                                right: 0,
                                                child: GestureDetector(
                                                  onTap: () {
                                                    setState(() {
                                                      gamesFollow.removeWhere(
                                                          (element) =>
                                                              element.name ==
                                                              gameAlgolia.name);
                                                      allGames.add(gameAlgolia);
                                                    });
                                                    _focusNodeSearch.unfocus();
                                                    _searchController.clear();
                                                  },
                                                  child: Container(
                                                      height: 25,
                                                      width: 25,
                                                      decoration: BoxDecoration(
                                                          color:
                                                              Colors.red[400],
                                                          shape:
                                                              BoxShape.circle,
                                                          border: Border.all(
                                                              color: Colors
                                                                  .black)),
                                                      child: Icon(
                                                        Icons.remove,
                                                        size: 20,
                                                        color: Colors.black,
                                                      )),
                                                )),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Text(
                                      gameAlgolia.name,
                                      textAlign: TextAlign.center,
                                    )
                                  ],
                                ),
                              )
                            : Container(
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 5.0),
                                      child: Container(
                                        height: 70,
                                        width: 70,
                                        child: Stack(
                                          children: [
                                            Align(
                                              alignment: Alignment.center,
                                              child: GestureDetector(
                                                onTap: () {
                                                  setState(() {
                                                    allGames.removeWhere(
                                                        (element) =>
                                                            element.name ==
                                                            gameAlgolia.name);
                                                    gamesFollow
                                                        .add(gameAlgolia);
                                                  });

                                                  _focusNodeSearch.unfocus();
                                                  _searchController.clear();
                                                },
                                                child: Container(
                                                  height: 60,
                                                  width: 60,
                                                  decoration: BoxDecoration(
                                                      gradient: LinearGradient(
                                                          begin:
                                                              Alignment.topLeft,
                                                          end: Alignment
                                                              .bottomRight,
                                                          colors: [
                                                            Theme.of(context)
                                                                .primaryColor,
                                                            Theme.of(context)
                                                                .accentColor
                                                          ]),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                      border: Border.all(
                                                          color: Colors.black),
                                                      image: DecorationImage(
                                                          fit: BoxFit.cover,
                                                          image: CachedNetworkImageProvider(
                                                              gameAlgolia
                                                                  .imageUrl))),
                                                ),
                                              ),
                                            ),
                                            Positioned(
                                                bottom: 0,
                                                right: 0,
                                                child: GestureDetector(
                                                  onTap: () {
                                                    setState(() {
                                                      allGames.removeWhere(
                                                          (element) =>
                                                              element.name ==
                                                              gameAlgolia.name);
                                                      gamesFollow
                                                          .add(gameAlgolia);
                                                    });
                                                    _focusNodeSearch.unfocus();
                                                    _searchController.clear();
                                                  },
                                                  child: Container(
                                                      height: 25,
                                                      width: 25,
                                                      decoration: BoxDecoration(
                                                          color:
                                                              Colors.green[400],
                                                          shape:
                                                              BoxShape.circle,
                                                          border: Border.all(
                                                              color: Colors
                                                                  .black)),
                                                      child: Icon(
                                                        Icons.add,
                                                        size: 20,
                                                        color: Colors.black,
                                                      )),
                                                )),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Text(
                                      gameAlgolia.name,
                                      textAlign: TextAlign.center,
                                    )
                                  ],
                                ),
                              );
                      }),
    );
  }

  Widget selectionGames() {
    return Column(
      children: [
        GridView.builder(
            shrinkWrap: true,
            scrollDirection: Axis.vertical,
            controller: _gamesScrollController,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 1.0,
                crossAxisSpacing: 6,
                mainAxisSpacing: 6),
            itemCount: allGames.length,
            itemBuilder: (_, int index) {
              Game game = allGames[index];
              return Container(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5.0),
                      child: Container(
                        height: 70,
                        width: 70,
                        child: Stack(
                          children: [
                            Align(
                              alignment: Alignment.center,
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    allGames.remove(game);
                                    gamesFollow.add(game);
                                  });
                                },
                                child: Container(
                                  height: 60,
                                  width: 60,
                                  decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            Theme.of(context).primaryColor,
                                            Theme.of(context).accentColor
                                          ]),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: Colors.black),
                                      image: DecorationImage(
                                          fit: BoxFit.cover,
                                          image: CachedNetworkImageProvider(
                                              game.imageUrl))),
                                ),
                              ),
                            ),
                            Positioned(
                                bottom: 0,
                                right: 0,
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      allGames.remove(game);
                                      gamesFollow.add(game);
                                    });
                                  },
                                  child: Container(
                                      height: 25,
                                      width: 25,
                                      decoration: BoxDecoration(
                                          color: Colors.green[400],
                                          shape: BoxShape.circle,
                                          border:
                                              Border.all(color: Colors.black)),
                                      child: Icon(
                                        Icons.add,
                                        size: 20,
                                        color: Colors.black,
                                      )),
                                )),
                          ],
                        ),
                      ),
                    ),
                    Text(
                      game.name,
                      textAlign: TextAlign.center,
                    )
                  ],
                ),
              );
            }),
        Padding(
            padding: const EdgeInsets.only(bottom: 30.0),
            child: Stack(
              children: [
                Container(
                  height: isLoadingMoreData ? 50.0 : 0.0,
                  child: Center(
                    child: SizedBox(
                      height: 30.0,
                      width: 30.0,
                      child: CircularProgressIndicator(
                        color: Theme.of(context).primaryColor,
                        strokeWidth: 1.5,
                      ),
                    ),
                  ),
                ),
                Container(
                  height: isResultLoading && newGames.length == 0 ? 50.0 : 0.0,
                  child: Center(
                    child: Text('C\'est tout pour le moment'),
                  ),
                )
              ],
            )),
      ],
    );
  }

  Widget bottomBar(Country? country) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 10.0),
          child: currentPageIndex == 1
              ? GestureDetector(
                  onTap: () {
                    setState(() {
                      currentPageIndex = 0;
                    });
                    _pageController.previousPage(
                        duration: Duration(milliseconds: 500),
                        curve: Curves.ease);
                  },
                  child: Container(
                    height: 35,
                    width: 60,
                    child: Center(
                      child: Text('Prev', style: mystyle(16, Colors.white)),
                    ),
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.black),
                        borderRadius: BorderRadius.circular(15),
                        color: Color(0x33000000)),
                  ),
                )
              : SizedBox(
                  height: 30,
                  width: 60,
                ),
        ),
        Row(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 3.0),
              child: Container(
                height: currentPageIndex == 0 ? 15 : 15,
                width: currentPageIndex == 0 ? 15 : 15,
                decoration: BoxDecoration(
                    color: currentPageIndex == 0
                        ? Theme.of(context).primaryColor
                        : Theme.of(context).primaryColor.withOpacity(0.5),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.black)),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 3.0),
              child: Container(
                height: currentPageIndex == 1 ? 15 : 15,
                width: currentPageIndex == 1 ? 15 : 15,
                decoration: BoxDecoration(
                    color: currentPageIndex == 1
                        ? Theme.of(context).primaryColor
                        : Theme.of(context).primaryColor.withOpacity(0.5),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.black)),
              ),
            ),
          ],
        ),
        Padding(
          padding: EdgeInsets.only(right: 10.0),
          child: currentPageIndex == 0
              ? GestureDetector(
                  onTap: () {
                    _hideKeyboard();
                    setState(() {
                      currentPageIndex = 1;
                    });
                    _pageController.nextPage(
                        duration: Duration(milliseconds: 500),
                        curve: Curves.ease);
                  },
                  child: Container(
                    height: 35,
                    width: 60,
                    child: Center(
                      child: Text('Next', style: mystyle(16, Colors.white)),
                    ),
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.black),
                        borderRadius: BorderRadius.circular(15),
                        color: Color(0x33000000)),
                  ),
                )
              : GestureDetector(
                  onTap: () async {
                    setState(() {
                      isLoading = true;
                    });
                    await Future.delayed(Duration(seconds: 2));
                    _registerAccount(
                        _emailController.text,
                        _passwordController.text,
                        _confirmPasswordController.text,
                        _usernameController.text,
                        gamesFollow,
                        country!.countryCode);
                    setState(() {
                      isLoading = false;
                    });
                  },
                  child: Container(
                    height: 35,
                    width: 60,
                    child: Center(
                        child: isLoading
                            ? SizedBox(
                                height: 15.0,
                                width: 15.0,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 1.0,
                                ),
                              )
                            : Icon(
                                Icons.check,
                                color: Colors.white,
                              )),
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.black),
                        borderRadius: BorderRadius.circular(15),
                        color: Color(0x33000000)),
                  ),
                ),
        ),
      ],
    );
  }
}
