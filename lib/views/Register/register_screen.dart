import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:algolia/algolia.dart';
import 'package:country_calling_code_picker/picker.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gemu/providers/dayMood_provider.dart';
import 'package:sticky_headers/sticky_headers/widget.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';

import 'package:gemu/services/auth_service.dart';
import 'package:gemu/constants/constants.dart';
import 'package:gemu/views/Welcome/welcome_screen.dart';
import 'package:gemu/widgets/alert_dialog_custom.dart';
import 'package:gemu/widgets/snack_bar_custom.dart';
import 'package:gemu/widgets/text_field_custom.dart';
import 'package:gemu/services/algolia_service.dart';
import 'package:gemu/models/game.dart';
import 'package:gemu/helpers/helpers.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  ScrollController _firstPageScrollController = ScrollController();
  ScrollController _secondPageScrollController = ScrollController();
  ScrollController _mainScrollController = ScrollController();
  ScrollController _gamesScrollController = ScrollController();

  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late TextEditingController _confirmPasswordController;
  late TextEditingController _usernameController;

  late FocusNode _focusNodeEmail;
  late FocusNode _focusNodePassword;
  late FocusNode _focusNodeConfirmPassword;
  late FocusNode _focusNodeUsername;
  late FocusNode _focusNodeSearch;

  String value = "";
  bool isSearching = false;
  late TextEditingController _searchController;
  Algolia algolia = AlgoliaService.algolia;
  List<AlgoliaObjectSnapshot> gamesAlgolia = [];

  bool dataIsThere = false;
  bool isLoading = false;
  bool isLoadingMoreData = false;
  bool isResultLoading = false;
  bool isStickyOnTop = false;

  List<Game> allGames = [];
  List<Game> gamesFollow = [];
  List<Game> newGames = [];

  Country? _selectedCountry;
  DateTime? _dateBirthday;

  void initCountry() async {
    final country = await getCountryByCountryCode(context, 'FR');
    setState(() {
      _selectedCountry = country;
    });
  }

  void _onPressedShowBottomSheet() async {
    final country = await showCountryPickerSheet(context,
        title: Text(
          'Sélectionne ta nationnalité',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        heightFactor: 0.79,
        cornerRadius: 15.0);
    if (country != null) {
      setState(() {
        _selectedCountry = country;
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
    _tabController = TabController(length: 3, vsync: this);

    initCountry();
    getGames();

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
    _tabController.dispose();

    _focusNodeEmail.dispose();
    _focusNodePassword.dispose();
    _focusNodeUsername.dispose();
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();

    _searchController.dispose();
    _focusNodeSearch.dispose();

    _firstPageScrollController.dispose();
    _secondPageScrollController.dispose();
    _mainScrollController.dispose();
    _gamesScrollController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child: Scaffold(
            resizeToAvoidBottomInset: false,
            body: AnnotatedRegion<SystemUiOverlayStyle>(
                value: SystemUiOverlayStyle(
                    statusBarColor: Colors.transparent,
                    statusBarIconBrightness:
                        Theme.of(context).brightness == Brightness.dark
                            ? Brightness.light
                            : Brightness.dark),
                child: GestureDetector(
                  onTap: () => Helpers.hideKeyboard(context),
                  child: Column(children: [
                    topRegisterEmail(),
                    Expanded(child: bodyRegister()),
                  ]),
                ))),
        onWillPop: () => Helpers.willPopCallback(context, WelcomeScreen()));
  }

  Widget topRegisterEmail() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      child: AppBar(
        elevation: 0,
        shadowColor: Colors.transparent,
        leading: IconButton(
            onPressed: () {
              Helpers.hideKeyboard(context);
              showDialog(
                  context: context,
                  builder: (_) {
                    return AlertDialogCustom(context, "Annuler l'inscription",
                        "Êtes-vous sur de vouloir annuler votre inscription?", [
                      TextButton(
                          onPressed: () => Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      WelcomeScreen()),
                              (route) => false),
                          child: Text(
                            "Oui",
                            style: TextStyle(color: Colors.blue[200]),
                          )),
                      TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            "Non",
                            style: TextStyle(color: Colors.red[200]),
                          ))
                    ]);
                  });
            },
            icon: Icon(Icons.arrow_back_ios,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black,
                size: 25)),
        title: Text(
          "Inscription",
          style: TextStyle(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 23),
        ),
        centerTitle: false,
        actions: [stepsRegister()],
      ),
    );
  }

  Widget stepsRegister() {
    return Consumer(builder: (_, ref, child) {
      ref.read(dayMoodNotifierProvider.notifier).timeMood();
      bool isDayMood = ref.watch(dayMoodNotifierProvider);
      return TabPageSelector(
        controller: _tabController,
        selectedColor: isDayMood ? cPinkBtn : cPurpleBtn,
        color: Colors.transparent,
        indicatorSize: 14,
      );
    });
  }

  Widget bodyRegister() {
    final country = _selectedCountry;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 15.0),
      child: Consumer(builder: (_, ref, child) {
        ref.read(dayMoodNotifierProvider.notifier).timeMood();
        bool isDayMood = ref.watch(dayMoodNotifierProvider);
        return TabBarView(
            controller: _tabController,
            physics: NeverScrollableScrollPhysics(),
            children: [
              Column(
                children: [
                  Expanded(child: firstPage(isDayMood)),
                  btnNext(isDayMood),
                ],
              ),
              Column(
                children: [
                  Expanded(child: secondPage(country, isDayMood)),
                  btnPrevious(),
                  btnNext(isDayMood),
                ],
              ),
              Column(
                children: [
                  Expanded(child: thirdPage(isDayMood)),
                  btnPrevious(),
                  btnFinish(isDayMood),
                ],
              )
            ]);
      }),
    );
  }

  Widget btnNext(bool isDayMood) {
    return Container(
      height: MediaQuery.of(context).size.height / 12,
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
      child: ElevatedButton(
        onPressed: () {
          if (_tabController.index != _tabController.length - 1) {
            Helpers.hideKeyboard(context);
            setState(() {
              _tabController.index += 1;
            });
          }
        },
        style: ElevatedButton.styleFrom(
            elevation: 6,
            primary: isDayMood ? cPinkBtn : cPurpleBtn,
            onPrimary: Theme.of(context).canvasColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            )),
        child: Text(
          "Suivant",
          style: TextStyle(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : Colors.black,
              fontSize: 15,
              fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  btnPrevious() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            text: "Précédent",
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                if (_tabController.index != 0) {
                  Helpers.hideKeyboard(context);
                  setState(() {
                    _tabController.index -= 1;
                  });
                }
              },
            style: TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.w500,
                decoration: TextDecoration.underline),
          )),
    );
  }

  Widget btnFinish(bool isDayMood) {
    return Container(
      height: MediaQuery.of(context).size.height / 12,
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
      child: ElevatedButton(
        onPressed: () {
          Helpers.hideKeyboard(context);
          print("s'inscrire");
        },
        style: ElevatedButton.styleFrom(
            elevation: 6,
            primary: isDayMood ? cPinkBtn : cPurpleBtn,
            onPrimary: Theme.of(context).canvasColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            )),
        child: Text(
          "Terminer",
          style: TextStyle(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : Colors.black,
              fontSize: 15,
              fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  Widget firstPage(bool isDayMood) {
    return Column(
      children: [
        Text(
          "Allez c'est parti pour ton inscription, la première étape étant de renseigner les informations personnelles pour te connecter à ton compte!",
          style: TextStyle(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : Colors.black,
              fontWeight: FontWeight.w500,
              fontSize: 12),
        ),
        Expanded(
            child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          shrinkWrap: true,
          physics:
              AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          controller: _firstPageScrollController,
          children: [
            Padding(
              padding: EdgeInsets.only(top: 20.0, bottom: 5.0),
              child: Text(
                'Renseigne ton email',
                style: mystyle(12),
              ),
            ),
            Container(
              height: MediaQuery.of(context).size.height / 12,
              child: TextFieldCustomRegister(
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
                isDayMood: isDayMood,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 20.0, bottom: 5.0),
              child: Text(
                'Renseigne ton mot de passe',
                style: mystyle(12),
              ),
            ),
            Container(
                height: MediaQuery.of(context).size.height / 12,
                child: TextFieldCustomRegister(
                  context: context,
                  controller: _passwordController,
                  focusNode: _focusNodePassword,
                  label: 'Mot de passe',
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
                    FocusScope.of(context)
                        .requestFocus(_focusNodeConfirmPassword);
                  },
                  isDayMood: isDayMood,
                )),
            const SizedBox(
              height: 10.0,
            ),
            Container(
                height: MediaQuery.of(context).size.height / 12,
                child: TextFieldCustomRegister(
                  context: context,
                  controller: _confirmPasswordController,
                  focusNode: _focusNodeConfirmPassword,
                  label: 'Confirme ton mot de passe',
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
                  isDayMood: isDayMood,
                )),
          ],
        ))
      ],
    );
  }

  Widget secondPage(Country? country, bool isDayMood) {
    return Column(
      children: [
        Text(
          "La seconde étape est pour te reconnaître et te retrouver au sein de la communauté, renseigne ton pseudonyme, ta date d'anniversaire et ta nationnalité",
          style: TextStyle(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : Colors.black,
              fontWeight: FontWeight.w500,
              fontSize: 12),
        ),
        Expanded(
            child: ListView(
          controller: _secondPageScrollController,
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          shrinkWrap: true,
          physics:
              AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          children: [
            Padding(
              padding: EdgeInsets.only(top: 20.0, bottom: 5.0),
              child: Text(
                'Entre ton pseudonyme',
                style: mystyle(12),
              ),
            ),
            Container(
              height: MediaQuery.of(context).size.height / 12,
              child: TextFieldCustomRegister(
                context: context,
                controller: _usernameController,
                focusNode: _focusNodeUsername,
                label: 'Pseudonyme',
                obscure: false,
                icon: Icons.person,
                textInputAction: TextInputAction.go,
                clear: () {
                  setState(() {
                    _usernameController.clear();
                  });
                },
                submit: (value) {
                  value = _usernameController.text;
                  _focusNodeUsername.unfocus();
                },
                isDayMood: isDayMood,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 20.0, bottom: 5.0),
              child: Text(
                "Sélectionne ta date d'anniversaire",
                style: mystyle(12),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(
                  _dateBirthday == null
                      ? "01 Janvier 1997"
                      : Helpers.dateBirthday(_dateBirthday!),
                  textAlign: TextAlign.center,
                  style: mystyle(12),
                ),
                const SizedBox(
                  width: 5.0,
                ),
                MaterialButton(
                  child: Text('Sélectionner'),
                  color: Theme.of(context).canvasColor,
                  onPressed: () {
                    DatePicker.showDatePicker(context,
                        showTitleActions: true,
                        theme: DatePickerTheme(
                          backgroundColor: Theme.of(context).canvasColor,
                          cancelStyle:
                              TextStyle(color: Colors.red[200], fontSize: 16),
                          doneStyle:
                              TextStyle(color: Colors.blue[200], fontSize: 16),
                          itemStyle: TextStyle(
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.white
                                  : Colors.black,
                              fontSize: 18),
                        ),
                        minTime: DateTime(1900, 1, 1),
                        maxTime: DateTime.now(), onChanged: (date) {
                      setState(() {
                        _dateBirthday = date;
                      });
                    }, onConfirm: (date) {
                      setState(() {
                        _dateBirthday = date;
                      });
                    }, currentTime: DateTime.now(), locale: LocaleType.fr);
                  },
                  elevation: 6,
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.only(top: 20.0, bottom: 5.0),
              child: Text(
                'Sélectionne ta nationnalité',
                style: mystyle(12),
              ),
            ),
            Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  country == null
                      ? Container()
                      : Row(
                          children: [
                            Container(
                              height: 50,
                              width: 50,
                              child: Image.asset(
                                country.flag,
                                package: countryCodePackageName,
                              ),
                            ),
                            SizedBox(
                              width: 10.0,
                            ),
                            Text(
                              '${country.name}',
                              textAlign: TextAlign.center,
                              style: mystyle(12),
                            ),
                          ],
                        ),
                  MaterialButton(
                    child: Text('Sélectionner'),
                    color: Theme.of(context).canvasColor,
                    onPressed: _onPressedShowBottomSheet,
                    elevation: 6,
                  ),
                ],
              ),
            ),
          ],
        ))
      ],
    );
  }

  Widget thirdPage(bool isDayMood) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 10.0),
          child: Text(
            "Une seule étape et c'est parti pour une grande aventure, tu es prêt? Il suffit que tu renseignes au minimum deux jeux auquels tu joues et/ou que tu voudrais suivre sur Gemu",
            style: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black,
                fontWeight: FontWeight.w500,
                fontSize: 12),
          ),
        ),
        _getStickyWidget(isDayMood),
        Expanded(
            child: ListView(
          controller: _mainScrollController,
          shrinkWrap: true,
          physics:
              AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          children: [
            dataIsThere
                ? searchGames()
                : Center(
                    child: CircularProgressIndicator(),
                  ),
          ],
        ))
      ],
    );
  }

  Widget _getStickyWidget(bool isDayMood) {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: Container(
        height: MediaQuery.of(context).size.height / 14,
        child: TextFieldCustomRegister(
          context: context,
          controller: _searchController,
          focusNode: _focusNodeSearch,
          label: 'Chercher un jeu',
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
          isDayMood: isDayMood,
        ),
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
                                    Container(
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
                                                        begin: Alignment
                                                            .topLeft,
                                                        end: Alignment
                                                            .bottomRight,
                                                        colors: [
                                                          Theme.of(context)
                                                              .colorScheme
                                                              .primary,
                                                          Theme.of(context)
                                                              .colorScheme
                                                              .secondary
                                                        ]),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                    border: Border.all(
                                                        color: Colors.black),
                                                    image: DecorationImage(
                                                        fit: BoxFit.cover,
                                                        image:
                                                            CachedNetworkImageProvider(
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
                                                        color: Colors.red[400],
                                                        shape: BoxShape.circle,
                                                        border: Border.all(
                                                            color:
                                                                Colors.black)),
                                                    child: Icon(
                                                      Icons.remove,
                                                      size: 20,
                                                      color: Colors.black,
                                                    )),
                                              )),
                                        ],
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
                                    Container(
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
                                                  gamesFollow.add(gameAlgolia);
                                                });

                                                _focusNodeSearch.unfocus();
                                                _searchController.clear();
                                              },
                                              child: Container(
                                                height: 60,
                                                width: 60,
                                                decoration: BoxDecoration(
                                                    gradient: LinearGradient(
                                                        begin: Alignment
                                                            .topLeft,
                                                        end: Alignment
                                                            .bottomRight,
                                                        colors: [
                                                          Theme.of(context)
                                                              .colorScheme
                                                              .primary,
                                                          Theme.of(context)
                                                              .colorScheme
                                                              .secondary
                                                        ]),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                    border: Border.all(
                                                        color: Colors.black),
                                                    image: DecorationImage(
                                                        fit: BoxFit.cover,
                                                        image:
                                                            CachedNetworkImageProvider(
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
                                                        shape: BoxShape.circle,
                                                        border: Border.all(
                                                            color:
                                                                Colors.black)),
                                                    child: Icon(
                                                      Icons.add,
                                                      size: 20,
                                                      color: Colors.black,
                                                    )),
                                              )),
                                        ],
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
                                            Theme.of(context)
                                                .colorScheme
                                                .primary,
                                            Theme.of(context)
                                                .colorScheme
                                                .secondary
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
                    child: Text("C'est tout pour le moment"),
                  ),
                )
              ],
            )),
      ],
    );
  }
}
