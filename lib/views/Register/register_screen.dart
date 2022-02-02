import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:algolia/algolia.dart';
import 'package:country_calling_code_picker/picker.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:gemu/services/auth_service.dart';
import 'package:gemu/constants/constants.dart';
import 'package:gemu/views/Register/complementary_screen.dart';
import 'package:gemu/views/Welcome/welcome_screen.dart';
import 'package:gemu/widgets/custom_clipper.dart';
import 'package:gemu/widgets/snack_bar_custom.dart';
import 'package:gemu/widgets/text_field_custom.dart';
import 'package:gemu/services/algolia_service.dart';
import 'package:gemu/models/game.dart';
import 'package:sticky_headers/sticky_headers/widget.dart';

class RegisterScreen extends StatefulWidget {
  @override
  Registerviewstate createState() => Registerviewstate();
}

class Registerviewstate extends State<RegisterScreen> {
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
        .doc('verified')
        .collection('games_verified')
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
        .doc('verified')
        .collection('games_verified')
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
      ));
    } else if (gamesFollow.length == 0 || gamesFollow.length == 1) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBarCustom(
        context: context,
        error: 'Selects at least two games',
      ));
    } else {
      AuthService.registerUser(context, gamesFollow, username, email, password,
          confirmPassword, country);
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
    List<Color> lightBgColors = [
      Color(0xFF947B8F),
      Color(0xFFB27D75),
      Color(0xFFE38048),
    ];
    List<Color> darkBgColors = [
      Color(0xFF4075DA),
      Color(0xFF6E78B1),
      Color(0xFF947B8F),
    ];

    final country = _selectedCountry;

    return WillPopScope(
        child: Scaffold(
            body: AnnotatedRegion<SystemUiOverlayStyle>(
                value: SystemUiOverlayStyle(
                    statusBarColor: Colors.transparent,
                    statusBarIconBrightness:
                        Theme.of(context).brightness == Brightness.dark
                            ? Brightness.light
                            : Brightness.dark),
                child: Column(children: [
                  Container(
                      height: MediaQuery.of(context).size.height / 2.25,
                      child: topRegister(lightBgColors, darkBgColors)),
                  Expanded(child: bodyRegister(lightBgColors, darkBgColors)),
                ]))),
        onWillPop: () => _willPopCallback());
  }

  Widget topRegister(List<Color> lightBgColors, List<Color> darkBgColors) {
    return Stack(
      children: [
        ClipPath(
          clipper: MyClipper(),
          child: Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isDayMood ? lightBgColors : darkBgColors)),
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: MediaQuery.of(context).size.height / 10,
              alignment: Alignment.bottomLeft,
              padding:
                  const EdgeInsets.symmetric(horizontal: 15.0, vertical: 5.0),
              child: Container(
                child: InkWell(
                  onTap: () => Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                          builder: (BuildContext context) => WelcomeScreen()),
                      (route) => false),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(Icons.arrow_back_ios,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : Colors.black,
                          size: 25),
                      Text(
                        "Retour",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white
                                    : Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 19),
                      )
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
                flex: 2,
                child: Container(
                  width: MediaQuery.of(context).size.width / 1.5,
                  alignment: Alignment.bottomCenter,
                  padding:
                      EdgeInsets.symmetric(horizontal: 5.0, vertical: 15.0),
                  child: Text(
                    "Inscription",
                    style: TextStyle(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 36),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                  ),
                )),
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 20),
                      child: Image.asset("assets/images/gameuse.png"),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 75),
                      child: Image.asset("assets/images/gamer.png"),
                    ),
                  ),
                ],
              ),
            )
          ],
        )
      ],
    );
  }

  Widget bodyRegister(List<Color> lightBgColors, List<Color> darkBgColors) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 25.0, horizontal: 15.0),
      child: Column(
        children: [
          Expanded(child: registerFournisseurNatifs()),
          Expanded(child: registerEmail())
        ],
      ),
    );
  }

  Widget registerFournisseurNatifs() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Text(
          "Inscrivez-vous directement avec vos identifiants et créer votre compte:",
          style: TextStyle(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : Colors.black,
              fontSize: 13,
              fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 5.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                  onPressed: () => print("sign up google"),
                  style: ElevatedButton.styleFrom(
                      elevation: 6,
                      shadowColor: Theme.of(context).shadowColor,
                      primary: Theme.of(context).canvasColor,
                      onPrimary: Theme.of(context).primaryColor,
                      shape: CircleBorder()),
                  child: Container(
                    height: 60,
                    width: 60,
                    alignment: Alignment.center,
                    child: SvgPicture.asset(
                      "assets/images/Google_line.svg",
                      height: 25,
                      width: 25,
                      color: Theme.of(context).primaryColor,
                    ),
                  )),
              ElevatedButton(
                  onPressed: () => print("sign up facebook"),
                  style: ElevatedButton.styleFrom(
                      elevation: 6,
                      shadowColor: Theme.of(context).shadowColor,
                      primary: Theme.of(context).canvasColor,
                      onPrimary: Theme.of(context).primaryColor,
                      shape: CircleBorder()),
                  child: Container(
                    height: 60,
                    width: 60,
                    alignment: Alignment.center,
                    child: SvgPicture.asset("assets/images/Facebook_line.svg",
                        height: 25,
                        width: 25,
                        color: Theme.of(context).primaryColor),
                  )),
              if (Platform.isIOS)
                ElevatedButton(
                    onPressed: () => print("sign up apple"),
                    style: ElevatedButton.styleFrom(
                        elevation: 6,
                        shadowColor: Theme.of(context).shadowColor,
                        primary: Theme.of(context).canvasColor,
                        onPrimary: Theme.of(context).primaryColor,
                        shape: CircleBorder()),
                    child: Container(
                      height: 60,
                      width: 60,
                      alignment: Alignment.center,
                      child: SvgPicture.asset("assets/images/Apple_line.svg",
                          height: 25,
                          width: 25,
                          color: Theme.of(context).primaryColor),
                    )),
            ],
          ),
        )
      ],
    );
  }

  Widget registerEmail() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Text(
          "Créer votre propre compte à partir de votre email:",
          style: TextStyle(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : Colors.black,
              fontSize: 13,
              fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0),
          child: Container(
            height: MediaQuery.of(context).size.height / 12,
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 10.0),
            child: ElevatedButton(
              onPressed: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => ComplementaryScreen())),
              style: ElevatedButton.styleFrom(
                  elevation: 12,
                  shadowColor: Theme.of(context).primaryColor,
                  primary: Theme.of(context).primaryColor,
                  onPrimary: Theme.of(context).canvasColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  )),
              child: Text(
                "Commencer",
                style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : Colors.black,
                    fontSize: 15,
                    fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
