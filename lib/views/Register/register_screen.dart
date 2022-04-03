import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:algolia/algolia.dart';
import 'package:country_calling_code_picker/picker.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:gemu/riverpod/Connectivity/auth_provider.dart';
import 'package:gemu/riverpod/Register/register_provider.dart';
import 'package:gemu/services/database_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loader/loader.dart';
import "package:email_validator/email_validator.dart";

import 'package:gemu/services/auth_service.dart';
import 'package:gemu/constants/constants.dart';
import 'package:gemu/widgets/alert_dialog_custom.dart';
import 'package:gemu/widgets/snack_bar_custom.dart';
import 'package:gemu/widgets/text_field_custom.dart';
import 'package:gemu/services/algolia_service.dart';
import 'package:gemu/models/game.dart';
import 'package:gemu/helpers/helpers.dart';
import 'package:gemu/riverpod/Theme/dayMood_provider.dart';
import 'package:sticky_headers/sticky_headers/widget.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int currentIndex = 0;

  ScrollController _firstPageScrollController = ScrollController();
  ScrollController _secondPageScrollController = ScrollController();
  ScrollController _mainScrollController = ScrollController();
  ScrollController _gamesScrollController = ScrollController();
  ScrollController _fourthPageScrollController = ScrollController();

  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late TextEditingController _confirmPasswordController;
  late TextEditingController _usernameController;

  late FocusNode currentFocus;
  late FocusNode _focusNodeEmail;
  late FocusNode _focusNodePassword;
  late FocusNode _focusNodeConfirmPassword;
  late FocusNode _focusNodeUsername;
  late FocusNode _focusNodeSearch;

  late TextEditingController _searchController;
  Algolia algolia = AlgoliaService.algolia;
  List<AlgoliaObjectSnapshot> gamesAlgolia = [];

  bool isSearching = false;
  bool isLoadingMoreData = false;
  bool isResultLoading = false;
  bool stopLoad = false;

  List<Game> allGames = [];
  List<Game> gamesFollow = [];
  List<Game> newGames = [];

  Country? _selectedCountry;
  DateTime? _dateBirthday;

  bool isComplete = false;

  void initCountry() async {
    final country = await getCountryByCountryCode(context, 'FR');
    _selectedCountry = country;
  }

  void _onPressedShowBottomSheet() async {
    final country = await showCountryPickerSheet(context,
        title: Text(
          'Sélectionne ta nationnalité',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        heightFactor: 0.79,
        cornerRadius: 15.0);
    if (country != null) {
      setState(() {
        _selectedCountry = country;
      });
    }
  }

  Future<bool> getGames() async {
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

    return true;
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
        allGames.add(Game.fromMap(item, item.data()));
        newGames.add(Game.fromMap(item, item.data()));
      }
    });

    await Future.delayed(Duration(seconds: 1));

    setState(() {
      isLoadingMoreData = false;
      isResultLoading = true;
      if (newGames.length == 0) {
        stopLoad = true;
      }
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

      setState(() {
        isSearching = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    initCountry();

    _tabController = TabController(length: 4, vsync: this);

    _emailController = TextEditingController();
    _usernameController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
    _searchController = TextEditingController();

    _focusNodeEmail = FocusNode();
    _focusNodeUsername = FocusNode();
    _focusNodePassword = FocusNode();
    _focusNodeConfirmPassword = FocusNode();
    _focusNodeSearch = FocusNode();

    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        currentIndex = _tabController.index;
      }
    });

    _mainScrollController.addListener(() {
      if (_mainScrollController.offset >=
              _mainScrollController.position.maxScrollExtent &&
          !_mainScrollController.position.outOfRange &&
          !stopLoad) {
        loadMoreData();
      }
    });

    _searchController.addListener(() {
      Timer(Duration(milliseconds: 500), () {
        if (_searchController.text != "") {
          _searchGames(_searchController.text);
        }
      });
    });

    _emailController.addListener(() {
      if (_emailController.text.trim().isNotEmpty &&
          EmailValidator.validate(_emailController.text)) {
        ref
            .read(emailValidRegisterNotifierProvider.notifier)
            .updateValidity(true);
      } else {
        ref
            .read(emailValidRegisterNotifierProvider.notifier)
            .updateValidity(false);
      }
    });
    _passwordController.addListener(() {
      if (_passwordController.text.trim().isNotEmpty &&
          _passwordController.text == _confirmPasswordController.text) {
        ref
            .read(passwordValidRegisterNotifierProvider.notifier)
            .updateValidity(true);
        ref
            .read(confirmPasswordValidRegisterNotifierProvider.notifier)
            .updateValidity(true);
      } else {
        ref
            .read(passwordValidRegisterNotifierProvider.notifier)
            .updateValidity(false);
        ref
            .read(confirmPasswordValidRegisterNotifierProvider.notifier)
            .updateValidity(false);
      }
    });
    _confirmPasswordController.addListener(() {
      if (_confirmPasswordController.text.trim().isNotEmpty &&
          _confirmPasswordController.text == _passwordController.text) {
        ref
            .read(passwordValidRegisterNotifierProvider.notifier)
            .updateValidity(true);
        ref
            .read(confirmPasswordValidRegisterNotifierProvider.notifier)
            .updateValidity(true);
      } else {
        ref
            .read(passwordValidRegisterNotifierProvider.notifier)
            .updateValidity(false);
        ref
            .read(confirmPasswordValidRegisterNotifierProvider.notifier)
            .updateValidity(false);
      }
    });
    _usernameController.addListener(() {
      if (_usernameController.text.trim().isNotEmpty) {
        ref
            .read(pseudonymeValidRegisterNotifierProvider.notifier)
            .updateValidity(true);
      } else {
        ref
            .read(pseudonymeValidRegisterNotifierProvider.notifier)
            .updateValidity(false);
      }
    });
  }

  @override
  void deactivate() {
    _tabController.removeListener(() {
      if (!_tabController.indexIsChanging) {
        currentIndex = _tabController.index;
      }
    });

    _mainScrollController.removeListener(() {
      if (_mainScrollController.offset >=
              _mainScrollController.position.maxScrollExtent &&
          !_mainScrollController.position.outOfRange) {
        loadMoreData();
      }
    });

    _searchController.removeListener(() {
      Timer(Duration(milliseconds: 500), () {
        if (_searchController.text != "") {
          _searchGames(_searchController.text);
        }
      });
    });

    _emailController.removeListener(() {
      if (_emailController.text.trim().isNotEmpty &&
          EmailValidator.validate(_emailController.text)) {
        ref
            .read(emailValidRegisterNotifierProvider.notifier)
            .updateValidity(true);
      } else {
        ref
            .read(emailValidRegisterNotifierProvider.notifier)
            .updateValidity(false);
      }
    });
    _passwordController.removeListener(() {
      if (_passwordController.text.trim().isNotEmpty &&
          _passwordController.text == _confirmPasswordController.text) {
        ref
            .read(passwordValidRegisterNotifierProvider.notifier)
            .updateValidity(true);
        ref
            .read(confirmPasswordValidRegisterNotifierProvider.notifier)
            .updateValidity(true);
      } else {
        ref
            .read(passwordValidRegisterNotifierProvider.notifier)
            .updateValidity(false);
        ref
            .read(confirmPasswordValidRegisterNotifierProvider.notifier)
            .updateValidity(false);
      }
    });
    _confirmPasswordController.removeListener(() {
      if (_confirmPasswordController.text.trim().isNotEmpty &&
          _confirmPasswordController.text == _passwordController.text) {
        ref
            .read(passwordValidRegisterNotifierProvider.notifier)
            .updateValidity(true);
        ref
            .read(confirmPasswordValidRegisterNotifierProvider.notifier)
            .updateValidity(true);
      } else {
        ref
            .read(passwordValidRegisterNotifierProvider.notifier)
            .updateValidity(false);
        ref
            .read(confirmPasswordValidRegisterNotifierProvider.notifier)
            .updateValidity(false);
      }
    });
    _usernameController.removeListener(() {
      if (_usernameController.text.trim().isNotEmpty) {
        ref
            .read(pseudonymeValidRegisterNotifierProvider.notifier)
            .updateValidity(true);
      } else {
        ref
            .read(pseudonymeValidRegisterNotifierProvider.notifier)
            .updateValidity(false);
      }
    });

    super.deactivate();
  }

  @override
  void dispose() {
    _tabController.dispose();

    _focusNodeEmail.dispose();
    _focusNodePassword.dispose();
    _focusNodeConfirmPassword.dispose();
    _focusNodeUsername.dispose();
    _focusNodeSearch.dispose();

    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _searchController.dispose();

    _firstPageScrollController.dispose();
    _secondPageScrollController.dispose();
    _mainScrollController.dispose();
    _gamesScrollController.dispose();
    _fourthPageScrollController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    currentFocus = FocusScope.of(context);
    final isDayMood = ref.watch(dayMoodNotifierProvider);
    final isLoading = ref.watch(loadingRegisterNotifierProvider);
    final isSuccess = ref.watch(successRegisterNotifierProvider);
    final emailValid = ref.watch(emailValidRegisterNotifierProvider);
    final passwordValid = ref.watch(passwordValidRegisterNotifierProvider);
    final usernameValid = ref.watch(pseudonymeValidRegisterNotifierProvider);
    final anniversaryValid =
        ref.watch(anniversaryValidRegisterNotifierProvider);
    final gamesValid = ref.watch(gamesValidRegisterNotifierProvider);
    final cgu = ref.watch(cguValidRegisterNotifierProvider);
    final policyPrivacy = ref.watch(policyPrivacyRegisterNotifierProvider);
    final creationComplete = ref.watch(registerCompleteProvider);
    if (creationComplete.asData != null) {
      isComplete = creationComplete.asData!.value;
    }

    return Scaffold(
        resizeToAvoidBottomInset: currentIndex == 2 ? false : true,
        body: Loader<bool>(
          load: () => getGames(),
          loadingWidget: Center(
            child: CircularProgressIndicator(
              strokeWidth: 1.0,
              color: isDayMood ? cPrimaryPink : cSecondaryPurple,
            ),
          ),
          builder: (_, value) {
            return GestureDetector(
              onTap: () {
                Helpers.hideKeyboard(context);
              },
              child: Column(children: [
                topRegisterEmail(isDayMood),
                Expanded(
                    child: bodyRegister(
                        isDayMood,
                        isLoading,
                        isSuccess,
                        emailValid,
                        passwordValid,
                        usernameValid,
                        anniversaryValid,
                        gamesValid,
                        cgu,
                        policyPrivacy)),
              ]),
            );
          },
        ));
  }

  Widget topRegisterEmail(bool isDayMood) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      child: AppBar(
        elevation: 0,
        shadowColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            systemNavigationBarColor: Theme.of(context).scaffoldBackgroundColor,
            statusBarIconBrightness:
                Theme.of(context).brightness == Brightness.dark
                    ? Brightness.light
                    : Brightness.dark,
            systemNavigationBarIconBrightness:
                Theme.of(context).brightness == Brightness.dark
                    ? Brightness.light
                    : Brightness.dark),
        leading: IconButton(
            onPressed: () {
              Helpers.hideKeyboard(context);
              showDialog(
                  context: navNonAuthKey.currentContext!,
                  builder: (_) {
                    return AlertDialogCustom(_, "Annuler l'inscription",
                        "Êtes-vous sur de vouloir annuler votre inscription?", [
                      TextButton(
                          onPressed: () {
                            Navigator.pop(mainKey.currentContext!);
                            navNonAuthKey.currentState!.pushNamedAndRemoveUntil(
                                Welcome, (route) => false);
                          },
                          child: Text(
                            "Oui",
                            style: textStyleCustom(Colors.blue[200]!, 12),
                          )),
                      TextButton(
                          onPressed: () =>
                              Navigator.pop(mainKey.currentContext!),
                          child: Text(
                            "Non",
                            style: textStyleCustom(Colors.red[200]!, 12),
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
          style: Theme.of(context).textTheme.titleLarge,
        ),
        centerTitle: false,
        actions: [stepsRegister(isDayMood)],
      ),
    );
  }

  Widget stepsRegister(bool isDayMood) {
    return TabPageSelector(
      controller: _tabController,
      selectedColor: isDayMood ? cPrimaryPink : cPrimaryPurple,
      color: Colors.transparent,
      indicatorSize: 14,
    );
  }

  Widget bodyRegister(
      final isDayMood,
      final isLoading,
      final isSuccess,
      final emailValid,
      final passwordValid,
      final usernameValid,
      final anniversaryValid,
      final gamesValid,
      final cgu,
      final policyPrivacy) {
    final country = _selectedCountry;
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 15.0),
        child: TabBarView(
            controller: _tabController,
            physics: AlwaysScrollableScrollPhysics(),
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
                  btnNext(isDayMood),
                ],
              ),
              Column(
                children: [
                  Expanded(
                      child: fourthPage(
                          isDayMood,
                          country,
                          emailValid,
                          passwordValid,
                          usernameValid,
                          anniversaryValid,
                          gamesValid,
                          cgu,
                          policyPrivacy)),
                  btnPrevious(),
                  btnFinish(isDayMood, isLoading, isSuccess),
                ],
              )
            ]));
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
            primary: isDayMood ? cPrimaryPink : cPrimaryPurple,
            onPrimary: Theme.of(context).canvasColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            )),
        child: Text(
          "Suivant",
          style: Theme.of(context).textTheme.titleSmall,
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
            style: GoogleFonts.fredokaOne(
                color: Colors.grey,
                fontWeight: FontWeight.w500,
                decoration: TextDecoration.underline),
          )),
    );
  }

  Widget btnFinish(final isDayMood, final isLoading, final isSuccess) {
    return Container(
      height: MediaQuery.of(context).size.height / 12,
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
      child: ElevatedButton(
        onPressed: () async {
          Helpers.hideKeyboard(context);
          if (isComplete && !isSuccess) {
            ref.read(loadingRegisterNotifierProvider.notifier).updateLoader();
            final verif =
                await DatabaseService.verifPseudo(_usernameController.text);
            if (verif.docs != null && verif.docs.isNotEmpty) {
              messageUser(context, "Ce pseudonyme existe déjà");
            } else {
              ref
                  .read(waitingAuthNotifierProvider.notifier)
                  .updateWaiting(true);
              await AuthService.registerUser(
                  context,
                  _emailController.text,
                  _passwordController.text,
                  _usernameController.text,
                  _dateBirthday!,
                  _selectedCountry!.countryCode,
                  gamesFollow,
                  ref);
              ref
                  .read(waitingAuthNotifierProvider.notifier)
                  .updateWaiting(false);
            }
            if (mounted) {
              ref.read(loadingRegisterNotifierProvider.notifier).updateLoader();
            }
          }
        },
        style: ElevatedButton.styleFrom(
            elevation: 6,
            primary: isDayMood ? cPrimaryPink : cPrimaryPurple,
            onPrimary: Theme.of(context).canvasColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            )),
        child: isLoading
            ? SizedBox(
                height: 15,
                width: 15,
                child: CircularProgressIndicator(
                    strokeWidth: 1.0, color: Theme.of(context).iconTheme.color),
              )
            : Text(
                "Terminer",
                style: Theme.of(context).textTheme.titleSmall,
              ),
      ),
    );
  }

  Widget firstPage(bool isDayMood) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      shrinkWrap: true,
      physics: AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
      controller: _firstPageScrollController,
      children: [
        Text(
            "Allez c'est parti pour ton inscription, la première étape étant de renseigner les informations personnelles pour te connecter à ton compte!",
            style: Theme.of(context).textTheme.bodySmall),
        Padding(
          padding: EdgeInsets.only(top: 20.0, bottom: 5.0),
          child: Text(
            'Renseigne ton email*',
            style: Theme.of(context).textTheme.bodySmall,
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
            changed: (value) {
              setState(() {
                value = _emailController.text;
              });
            },
            submit: (value) {
              value = _emailController.text;
              currentFocus.unfocus();
              currentFocus.requestFocus(_focusNodePassword);
            },
            isDayMood: isDayMood,
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: 20.0, bottom: 5.0),
          child: Text(
            'Renseigne ton mot de passe*',
            style: Theme.of(context).textTheme.bodySmall,
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
              changed: (value) {
                setState(() {
                  value = _passwordController.text;
                });
              },
              submit: (value) {
                value = _passwordController.text;
                currentFocus.unfocus();
                currentFocus.requestFocus(_focusNodeConfirmPassword);
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
              changed: (value) {
                setState(() {
                  value = _confirmPasswordController.text;
                });
              },
              submit: (value) {
                value = _confirmPasswordController.text;
                currentFocus.unfocus();
              },
              isDayMood: isDayMood,
            )),
      ],
    );
  }

  Widget secondPage(Country? country, bool isDayMood) {
    return ListView(
      controller: _secondPageScrollController,
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      shrinkWrap: true,
      physics: AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
      children: [
        Text(
          "La seconde étape est pour te reconnaître et te retrouver au sein de la communauté, renseigne ton pseudonyme, ta date d'anniversaire et ta nationnalité.",
          style: Theme.of(context).textTheme.bodySmall,
        ),
        Padding(
          padding: EdgeInsets.only(top: 20.0, bottom: 5.0),
          child: Text(
            'Entre ton pseudonyme*',
            style: Theme.of(context).textTheme.bodySmall,
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
            changed: (value) {
              setState(() {
                value = _usernameController.text;
              });
            },
            submit: (value) {
              value = _usernameController.text;
              currentFocus.unfocus();
            },
            isDayMood: isDayMood,
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: 20.0, bottom: 5.0),
          child: Text(
            "Sélectionne ta date d'anniversaire*",
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(
              Helpers.dateBirthday(_dateBirthday ?? DateTime.now()),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(
              width: 5.0,
            ),
            MaterialButton(
              child: Text(
                'Sélectionner',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              color: Theme.of(context).canvasColor,
              onPressed: () {
                DatePicker.showDatePicker(context,
                    showTitleActions: true,
                    theme: DatePickerTheme(
                      backgroundColor: Theme.of(context).canvasColor,
                      cancelStyle: textStyleCustom(Colors.red[200]!, 14),
                      doneStyle: textStyleCustom(Colors.blue[200]!, 14),
                      itemStyle: textStyleCustom(
                          Theme.of(context).iconTheme.color!, 15),
                    ),
                    minTime: DateTime(1900, 1, 1),
                    maxTime: DateTime.now(), onConfirm: (date) {
                  _dateBirthday = date;
                  final verif =
                      DateTime.now().subtract(const Duration(days: 4745));
                  if (_dateBirthday!.isBefore(verif)) {
                    ref
                        .read(anniversaryValidRegisterNotifierProvider.notifier)
                        .updateValidity(true);
                  } else {
                    ref
                        .read(anniversaryValidRegisterNotifierProvider.notifier)
                        .updateValidity(false);
                  }
                },
                    currentTime: _dateBirthday ?? DateTime.now(),
                    locale: LocaleType.fr);
              },
              elevation: 6,
            ),
          ],
        ),
        Padding(
          padding: EdgeInsets.only(top: 20.0, bottom: 5.0),
          child: Text(
            'Sélectionne ta nationnalité*',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
        Row(
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
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
            MaterialButton(
              child: Text(
                'Sélectionner',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              color: Theme.of(context).canvasColor,
              onPressed: _onPressedShowBottomSheet,
              elevation: 6,
            ),
          ],
        ),
      ],
    );
  }

  Widget thirdPage(bool isDayMood) {
    return ListView(
      controller: _mainScrollController,
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      shrinkWrap: true,
      physics: AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
      children: [
        Text(
          "Une seule étape et c'est parti pour une grande aventure, tu es prêt? Il suffit que tu renseignes au minimum deux jeux auquels tu joues et/ou que tu voudrais suivre sur Gemu.",
          style: Theme.of(context).textTheme.bodySmall,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 5.0),
          child: StickyHeader(
              controller: _mainScrollController,
              header: _searchBar(isDayMood),
              content: _searchController.text.isNotEmpty
                  ? _searchListGames(isDayMood)
                  : _listGames(isDayMood)),
        )
      ],
    );
  }

  Widget _searchBar(bool isDayMood) {
    return Container(
        height: MediaQuery.of(context).size.height / 12,
        color: Theme.of(context).scaffoldBackgroundColor,
        alignment: Alignment.center,
        child: Padding(
          padding: const EdgeInsets.all(4.0),
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
              if (gamesAlgolia.length != 0) {
                gamesAlgolia.clear();
              }
            },
            changed: (value) {
              setState(() {
                value = _searchController.text;
              });
            },
            submit: (value) {
              value = _searchController.text;
              _searchGames(value);
            },
            isDayMood: isDayMood,
          ),
        ));
  }

  Widget _listGames(bool isDayMood) {
    return Column(
      children: [
        GridView.builder(
            shrinkWrap: true,
            controller: _gamesScrollController,
            padding: const EdgeInsets.symmetric(vertical: 15.0),
            physics: NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 0.6,
                crossAxisSpacing: 6,
                mainAxisSpacing: 6),
            itemCount: allGames.length,
            itemBuilder: (_, index) {
              Game game = allGames[index];
              return _itemGame(game, isDayMood);
            }),
        Stack(
          children: [
            Container(
              height: MediaQuery.of(context).size.height / 14,
              child: isLoadingMoreData
                  ? Center(
                      child: SizedBox(
                        height: 30.0,
                        width: 30.0,
                        child: CircularProgressIndicator(
                          color: Theme.of(context).colorScheme.primary,
                          strokeWidth: 1.5,
                        ),
                      ),
                    )
                  : SizedBox(),
            ),
            Container(
              height: isResultLoading && newGames.length == 0
                  ? MediaQuery.of(context).size.height / 14
                  : 0.0,
              child: Center(
                child: Text(
                  "C'est tout pour le moment",
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            )
          ],
        )
      ],
    );
  }

  Widget _searchListGames(bool isDayMood) {
    return isSearching
        ? Padding(
            padding: const EdgeInsets.symmetric(vertical: 25.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  height: 15.0,
                  width: 15.0,
                  child: CircularProgressIndicator(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                SizedBox(
                  width: 5.0,
                ),
                Text(
                  _searchController.text.length < 10
                      ? 'Recherche de "${_searchController.text}.."'
                      : 'Recherche de "${_searchController.text.substring(0, 10)}.."',
                  style: Theme.of(context).textTheme.bodySmall,
                )
              ],
            ),
          )
        : gamesAlgolia.length == 0
            ? Padding(
                padding: const EdgeInsets.symmetric(vertical: 25.0),
                child: Center(
                  child: Text(
                    'No games found',
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            : GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 0.6,
                    crossAxisSpacing: 6,
                    mainAxisSpacing: 6),
                shrinkWrap: true,
                controller: _gamesScrollController,
                padding: const EdgeInsets.symmetric(vertical: 15.0),
                physics: NeverScrollableScrollPhysics(),
                itemCount: gamesAlgolia.length,
                itemBuilder: (_, index) {
                  Game gameAlgolia = Game.fromMapAlgolia(
                      gamesAlgolia[index], gamesAlgolia[index].data);
                  return _itemGame(gameAlgolia, isDayMood);
                });
  }

  Widget _itemGame(Game game, bool isDayMood) {
    return InkWell(
      onTap: () {
        if (gamesFollow.any((element) => element.name == game.name)) {
          setState(() {
            gamesFollow.removeWhere((element) => element.name == game.name);
          });
          if (gamesFollow.length < 2) {
            ref
                .read(gamesValidRegisterNotifierProvider.notifier)
                .updateValidity(false);
          }
        } else {
          setState(() {
            gamesFollow.add(game);
          });
          if (gamesFollow.length >= 2) {
            ref
                .read(gamesValidRegisterNotifierProvider.notifier)
                .updateValidity(true);
          }
        }
      },
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5.0),
                gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isDayMood ? lightBgColors : darkBgColors)),
          ),
          Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5.0),
                gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.3),
                      Colors.black.withOpacity(0.5)
                    ])),
          ),
          Center(
            child: Icon(
              Icons.videogame_asset,
              size: 35,
              color: Colors.white,
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Container(
                padding: const EdgeInsets.only(right: 10.0, bottom: 10.0),
                child: Text(
                  game.name,
                  style: Theme.of(context).textTheme.titleSmall,
                  textAlign: TextAlign.end,
                )),
          ),
          if (gamesFollow.any((element) => element.name == game.name))
            Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5.0),
                  color: Colors.green[200]!.withOpacity(0.7)),
              alignment: Alignment.topRight,
              child: Icon(
                Icons.check,
                color: Colors.white,
              ),
            ),
        ],
      ),
    );
  }

  Widget fourthPage(
      bool isDayMood,
      Country? country,
      final emailValid,
      final passwordValid,
      final usernameValid,
      final anniversaryValid,
      final gamesValid,
      final cgu,
      final policyPrivacy) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 5.0),
      shrinkWrap: true,
      controller: _fourthPageScrollController,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 5.0),
          child: Text(
            "Nous voici dans le récapitulatif d'inscription, vérifie bien que tu as tout saisi correctement pour ton compte et n'hésite pas à vérifier être en accord avec les cgu et la politique de confidentialité de Gemu.",
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 20.0, bottom: 5.0),
          child: Text(
            "Ton email*",
            style: Theme.of(context).textTheme.bodySmall,
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
              textInputAction: TextInputAction.go,
              clear: () {
                setState(() {
                  _emailController.clear();
                });
              },
              changed: (value) {
                setState(() {
                  value = _emailController.text;
                });
              },
              submit: (value) {
                value = _emailController.text;
                currentFocus.unfocus();
              },
              isDayMood: isDayMood,
            )),
        Padding(
          padding: const EdgeInsets.only(left: 5.0, top: 1.0),
          child: Visibility(
              visible: !emailValid ? true : false,
              child: Text(
                "Ton email n'est pas valide",
                style: textStyleCustom(Colors.red[200]!, 11),
              )),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 20.0, bottom: 5.0),
          child: Text(
            "Ton mot de passe*",
            style: Theme.of(context).textTheme.bodySmall,
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
              textInputAction: TextInputAction.go,
              clear: () {
                setState(() {
                  _passwordController.clear();
                });
              },
              changed: (value) {
                setState(() {
                  value = _passwordController.text;
                });
              },
              submit: (value) {
                value = _passwordController.text;
                currentFocus.unfocus();
              },
              isDayMood: isDayMood,
            )),
        Padding(
          padding: const EdgeInsets.only(left: 5.0, top: 1.0),
          child: Visibility(
              visible: !passwordValid ? true : false,
              child: Text(
                "Ton mot de passe n'est pas valide",
                style: textStyleCustom(Colors.red[200]!, 11),
              )),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 20.0, bottom: 5.0),
          child: Text(
            "Ton pseudonyme*",
            style: Theme.of(context).textTheme.bodySmall,
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
              changed: (value) {
                setState(() {
                  value = _usernameController.text;
                });
              },
              submit: (value) {
                value = _usernameController.text;
                currentFocus.unfocus();
              },
              isDayMood: isDayMood,
            )),
        Padding(
          padding: const EdgeInsets.only(left: 5.0, top: 1.0),
          child: Visibility(
              visible: !usernameValid ? true : false,
              child: Text(
                "Ton pseudonyme n'est pas valide",
                style: textStyleCustom(Colors.red[200]!, 11),
              )),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 20.0, bottom: 5.0),
          child: Text(
            "Ta date de naissance*",
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(
              Helpers.dateBirthday(_dateBirthday ?? DateTime.now()),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(
              width: 5.0,
            ),
            MaterialButton(
              child: Text(
                'Sélectionner',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              color: Theme.of(context).canvasColor,
              onPressed: () {
                DatePicker.showDatePicker(context,
                    showTitleActions: true,
                    theme: DatePickerTheme(
                      backgroundColor: Theme.of(context).canvasColor,
                      cancelStyle: textStyleCustom(Colors.red[200]!, 14),
                      doneStyle: textStyleCustom(Colors.blue[200]!, 14),
                      itemStyle: textStyleCustom(
                          Theme.of(context).iconTheme.color!, 15),
                    ),
                    minTime: DateTime(1900, 1, 1),
                    maxTime: DateTime.now(), onConfirm: (date) {
                  _dateBirthday = date;
                  final verif =
                      DateTime.now().subtract(const Duration(days: 4745));
                  if (_dateBirthday!.isBefore(verif)) {
                    ref
                        .read(anniversaryValidRegisterNotifierProvider.notifier)
                        .updateValidity(true);
                  } else {
                    ref
                        .read(anniversaryValidRegisterNotifierProvider.notifier)
                        .updateValidity(false);
                  }
                },
                    currentTime: _dateBirthday ?? DateTime.now(),
                    locale: LocaleType.fr);
              },
              elevation: 6,
            ),
          ],
        ),
        Padding(
            padding: const EdgeInsets.only(left: 5.0, top: 1.0),
            child: Visibility(
                visible: !anniversaryValid ? true : false,
                child: Text(
                  "Il faut impérativement avoir minimum 13 ans",
                  style: textStyleCustom(Colors.red[200]!, 11),
                ))),
        Padding(
          padding: const EdgeInsets.only(top: 20.0, bottom: 5.0),
          child: Text(
            "Ta nationnalité*",
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
        Row(
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
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
            MaterialButton(
              child: Text(
                'Sélectionner',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              color: Theme.of(context).canvasColor,
              onPressed: _onPressedShowBottomSheet,
              elevation: 6,
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(top: 20.0, bottom: 5.0),
          child: Text(
            "Les jeux que tu veux suivre*",
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
        gamesFollow.length == 0
            ? Padding(
                padding: const EdgeInsets.only(top: 5.0, bottom: 5.0),
                child: Column(
                  children: [
                    Text(
                      "Pas de jeux suivis actuellement",
                      style: textStyleRegular(Colors.red[200]!, 12),
                      textAlign: TextAlign.center,
                    ),
                    MaterialButton(
                      child: Text(
                        'Vers les jeux',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      color: Theme.of(context).canvasColor,
                      onPressed: () => {
                        setState(() {
                          _tabController.index -= 1;
                        })
                      },
                      elevation: 6,
                    ),
                  ],
                ))
            : GridView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 0.6,
                    crossAxisSpacing: 6,
                    mainAxisSpacing: 6),
                itemCount: gamesFollow.length,
                itemBuilder: (_, index) {
                  Game game = gamesFollow[index];
                  return _itemGameFollow(game, isDayMood);
                }),
        CheckboxListTile(
          dense: false,
          value: cgu,
          title: RichText(
              text: TextSpan(
                  text: "Accepter les ",
                  style: Theme.of(context).textTheme.bodySmall,
                  children: [
                TextSpan(
                  text: "termes et conditions",
                  style: textStyleRegular(
                      isDayMood ? cPrimaryPink : cPrimaryPurple, 12),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () => print("voir les cgu"),
                ),
                TextSpan(text: "*")
              ])),
          onChanged: (value) {
            ref
                .read(cguValidRegisterNotifierProvider.notifier)
                .updateValidity();
          },
          activeColor: isDayMood ? cPrimaryPink : cPrimaryPurple,
        ),
        CheckboxListTile(
          dense: false,
          value: policyPrivacy,
          title: RichText(
              text: TextSpan(
                  text: "Accepter la ",
                  style: Theme.of(context).textTheme.bodySmall,
                  children: [
                TextSpan(
                    text: "politique de confidentialité",
                    style: textStyleRegular(
                        isDayMood ? cPrimaryPink : cPrimaryPurple, 12),
                    recognizer: TapGestureRecognizer()
                      ..onTap =
                          () => print("voir la politique de confidentialité")),
                TextSpan(text: "*")
              ])),
          onChanged: (value) {
            ref
                .read(policyPrivacyRegisterNotifierProvider.notifier)
                .updateValidity();
          },
          activeColor: isDayMood ? cPrimaryPink : cPrimaryPurple,
        )
      ],
    );
  }

  Widget _itemGameFollow(Game game, bool isDayMood) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5.0),
              gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDayMood ? lightBgColors : darkBgColors)),
        ),
        Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5.0),
              gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.3),
                    Colors.black.withOpacity(0.5)
                  ])),
        ),
        Center(
          child: Icon(
            Icons.videogame_asset,
            size: 35,
            color: Colors.white,
          ),
        ),
        Align(
          alignment: Alignment.bottomRight,
          child: Container(
              padding: const EdgeInsets.only(right: 10.0, bottom: 10.0),
              child: Text(
                game.name,
                style: Theme.of(context).textTheme.titleSmall,
                textAlign: TextAlign.end,
              )),
        ),
      ],
    );
  }
}
