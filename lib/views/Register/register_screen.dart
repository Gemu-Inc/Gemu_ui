import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:algolia/algolia.dart';
import 'package:country_calling_code_picker/picker.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:gemu/providers/Langue/device_language_provider.dart';
import 'package:gemu/providers/Navigation/nav_non_auth.dart';
import 'package:gemu/providers/Register/register_provider.dart';
import 'package:gemu/providers/Register/searching_game.dart';
import 'package:gemu/services/database_service.dart';
import 'package:gemu/translations/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import "package:email_validator/email_validator.dart";

import 'package:gemu/services/auth_service.dart';
import 'package:gemu/constants/constants.dart';
import 'package:gemu/components/alert_dialog_custom.dart';
import 'package:gemu/components/snack_bar_custom.dart';
import 'package:gemu/components/text_field_custom.dart';
import 'package:gemu/services/algolia_service.dart';
import 'package:gemu/models/game.dart';
import 'package:gemu/helpers/helpers.dart';
import 'package:gemu/providers/Theme/dayMood_provider.dart';
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

  late FocusNode _focusNodeEmail;
  late FocusNode _focusNodePassword;
  late FocusNode _focusNodeConfirmPassword;
  late FocusNode _focusNodeUsername;
  late FocusNode _focusNodeSearch;

  late TextEditingController _searchController;
  Algolia algolia = AlgoliaService.algolia;
  List<AlgoliaObjectSnapshot> gamesSearch = [];

  late bool isSearching;
  late bool isLoadingMoreData;
  late bool stopReached;

  late List<Game> allGames;
  late List<Game> newGames;
  late List<Game> gamesFollow;

  late bool gamesValid;

  Country? _selectedCountry;
  DateTime? _dateBirthday;

  bool isComplete = false;

  String deviceLanguage = "en";

  void initCountry() async {
    final country = await getCountryByCountryCode(context, 'FR');
    _selectedCountry = country;
  }

  void _onPressedShowBottomSheet() async {
    final country = await showCountryPickerSheet(context,
        title: Text(
          AppLocalization.of(context)
              .translate("register_screen", "dialog_nationnality"),
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

  loadMoreData() async {
    Game game = allGames.last;

    ref.read(loadingMoreGamesRegisterNotifierProvider.notifier).update(true);

    DatabaseService.loadMoreGamesRegister(ref, game);

    await Future.delayed(Duration(seconds: 1));

    ref.read(loadingMoreGamesRegisterNotifierProvider.notifier).update(false);
    if (newGames.length == 0) {
      ref.read(stopReachedRegisterNotifierProvider.notifier).update();
    }
  }

  _searchGames(String value) async {
    if (value.isNotEmpty) {
      ref.read(searchingRegisterNotifierProvider.notifier).update(true);

      AlgoliaQuery query = algolia.instance.index('games');
      query = query.query(value);

      gamesSearch = (await query.getObjects()).hits;

      ref.read(searchingRegisterNotifierProvider.notifier).update(false);
    }
  }

  @override
  void initState() {
    super.initState();
    DatabaseService.getGamesRegister(ref);

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
          !stopReached) {
        loadMoreData();
      }
    });

    // _searchController.addListener(() {
    //   Timer(Duration(milliseconds: 750), () {
    //     if (_searchController.text != "") {
    //       _searchGames(_searchController.text);
    //     }
    //   });
    // });

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
          !_mainScrollController.position.outOfRange &&
          !stopReached) {
        loadMoreData();
      }
    });

    // _searchController.removeListener(() {
    //   Timer(Duration(milliseconds: 500), () {
    //     if (_searchController.text != "") {
    //       _searchGames(_searchController.text);
    //     }
    //   });
    // });

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
    final isDayMood = ref.watch(dayMoodNotifierProvider);
    final isLoading = ref.watch(loadingRegisterNotifierProvider);
    final isSuccess = ref.watch(successRegisterNotifierProvider);
    final emailValid = ref.watch(emailValidRegisterNotifierProvider);
    final passwordValid = ref.watch(passwordValidRegisterNotifierProvider);
    final usernameValid = ref.watch(pseudonymeValidRegisterNotifierProvider);
    final anniversaryValid =
        ref.watch(anniversaryValidRegisterNotifierProvider);
    gamesValid = ref.watch(gamesValidRegisterNotifierProvider);
    final cgu = ref.watch(cguValidRegisterNotifierProvider);
    final policyPrivacy = ref.watch(policyPrivacyRegisterNotifierProvider);
    final creationComplete = ref.watch(registerCompleteProvider);
    if (creationComplete.asData != null) {
      isComplete = creationComplete.asData!.value;
    }

    allGames = ref.watch(allGamesRegisterNotifierProvider);
    newGames = ref.watch(newGamesRegisterNotifierProvider);
    gamesFollow = ref.watch(gamesFollowRegisterNotifierProvider);
    isLoadingMoreData = ref.watch(loadingMoreGamesRegisterNotifierProvider);
    stopReached = ref.watch(stopReachedRegisterNotifierProvider);
    isSearching = ref.watch(searchingRegisterNotifierProvider);

    deviceLanguage = ref.watch(deviceLanguageProvider);

    return Scaffold(
        resizeToAvoidBottomInset: currentIndex == 2 ? false : true,
        body: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
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
              FocusScope.of(context).unfocus();
              Helpers.hideKeyboard(context);
              showDialog(
                  context: navNonAuthKey.currentContext!,
                  barrierDismissible: false,
                  builder: (BuildContext context) {
                    return AlertDialogCustom(
                        context,
                        AppLocalization.of(context).translate(
                            "register_screen", "cancel_register_title"),
                        AppLocalization.of(context).translate(
                            "register_screen", "cancel_register_content"),
                        [
                          TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                                ref
                                    .read(currentRouteNonAuthNotifierProvider
                                        .notifier)
                                    .updateCurrentRoute("Welcome");
                                navNonAuthKey.currentState!
                                    .pushNamedAndRemoveUntil(
                                        Welcome, (route) => false);
                              },
                              child: Text(
                                AppLocalization.of(context).translate(
                                    "register_screen",
                                    "cancel_register_confirm"),
                                style: textStyleCustomBold(cGreenConfirm, 12),
                              )),
                          TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: Text(
                                AppLocalization.of(context).translate(
                                    "register_screen",
                                    "cancel_register_cancel"),
                                style: textStyleCustomBold(cRedCancel, 12),
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
          AppLocalization.of(context)
              .translate("register_screen", "register_title"),
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
            FocusScope.of(context).unfocus();

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
          AppLocalization.of(context).translate("register_screen", "next"),
          style: textStyleCustomBold(Colors.white, 14),
        ),
      ),
    );
  }

  btnPrevious() {
    return TextButton(
        onPressed: () {
          if (_tabController.index != 0) {
            FocusScope.of(context).unfocus();

            Helpers.hideKeyboard(context);
            setState(() {
              _tabController.index -= 1;
            });
          }
        },
        style: TextButton.styleFrom(
          minimumSize: Size.zero,
          padding: EdgeInsets.only(top: 6.0, bottom: 2.0),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: Text(
            AppLocalization.of(context)
                .translate("register_screen", "previous"),
            style: GoogleFonts.fredokaOne(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : Colors.grey,
                fontWeight: FontWeight.w500,
                decoration: TextDecoration.underline)));
  }

  Widget btnFinish(final isDayMood, final isLoading, final isSuccess) {
    return Container(
      height: MediaQuery.of(context).size.height / 12,
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
      child: ElevatedButton(
        onPressed: () async {
          FocusScope.of(context).unfocus();
          Helpers.hideKeyboard(context);
          if (isComplete && !isSuccess) {
            ref.read(loadingRegisterNotifierProvider.notifier).updateLoader();
            final verif =
                await DatabaseService.verifPseudo(_usernameController.text);
            if (verif.docs != null && verif.docs.isNotEmpty) {
              messageUser(
                  context,
                  AppLocalization.of(context)
                      .translate("message_user", "pseudo_already_exist"));
            } else {
              User? user = await AuthService.registerUser(
                  context,
                  _emailController.text,
                  _passwordController.text,
                  _usernameController.text,
                  _dateBirthday!,
                  _selectedCountry!.countryCode,
                  gamesFollow,
                  ref);

              if (user != null) {
                await AuthService.setUserToken(user);
                await DatabaseService.getUserData(user, ref);
              }
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
                    strokeWidth: 1.0, color: Colors.white),
              )
            : Text(
                AppLocalization.of(context)
                    .translate("register_screen", "finish"),
                style: textStyleCustomBold(Colors.white, 14),
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
            AppLocalization.of(context)
                .translate("register_screen", "register_first_step"),
            style: Theme.of(context).textTheme.bodyLarge),
        Padding(
          padding: EdgeInsets.only(top: 20.0, bottom: 5.0),
          child: Text(
            AppLocalization.of(context)
                .translate("register_screen", "inform_email"),
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
        TextFieldCustomRegister(
          context: context,
          controller: _emailController,
          focusNode: _focusNodeEmail,
          label: AppLocalization.of(context)
              .translate("register_screen", "placeholder_mail"),
          obscure: false,
          icon: Icons.mail,
          textInputAction: TextInputAction.next,
          textInputType: TextInputType.emailAddress,
          clear: () {
            setState(() {
              _emailController.clear();
            });
          },
          tap: () {
            FocusScope.of(context).requestFocus(_focusNodeEmail);
          },
          changed: (value) {
            setState(() {
              value = _emailController.text;
            });
          },
          editingComplete: () {
            FocusScope.of(context).requestFocus(_focusNodePassword);
          },
          isDayMood: isDayMood,
        ),
        Padding(
          padding: EdgeInsets.only(top: 20.0, bottom: 5.0),
          child: Text(
            AppLocalization.of(context)
                .translate("register_screen", "inform_password"),
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
        TextFieldCustomRegister(
          context: context,
          controller: _passwordController,
          focusNode: _focusNodePassword,
          label: AppLocalization.of(context)
              .translate("register_screen", "placeholder_password"),
          obscure: true,
          icon: Icons.lock,
          textInputAction: TextInputAction.next,
          clear: () {
            setState(() {
              _passwordController.clear();
            });
          },
          tap: () {
            FocusScope.of(context).requestFocus(_focusNodePassword);
          },
          changed: (value) {
            setState(() {
              value = _passwordController.text;
            });
          },
          editingComplete: () {
            FocusScope.of(context).requestFocus(_focusNodeConfirmPassword);
          },
          isDayMood: isDayMood,
        ),
        const SizedBox(
          height: 10.0,
        ),
        TextFieldCustomRegister(
          context: context,
          controller: _confirmPasswordController,
          focusNode: _focusNodeConfirmPassword,
          label: AppLocalization.of(context)
              .translate("register_screen", "placeholder_confirm_password"),
          obscure: true,
          icon: Icons.lock,
          textInputAction: TextInputAction.go,
          clear: () {
            setState(() {
              _confirmPasswordController.clear();
            });
          },
          tap: () {
            FocusScope.of(context).requestFocus(_focusNodeConfirmPassword);
          },
          changed: (value) {
            setState(() {
              value = _confirmPasswordController.text;
            });
          },
          editingComplete: () {
            FocusScope.of(context).unfocus();
          },
          isDayMood: isDayMood,
        ),
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
          AppLocalization.of(context)
              .translate("register_screen", "register_second_step"),
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        Padding(
          padding: EdgeInsets.only(top: 20.0, bottom: 5.0),
          child: Text(
            AppLocalization.of(context)
                .translate("register_screen", "inform_pseudo"),
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
        TextFieldCustomRegister(
          context: context,
          controller: _usernameController,
          focusNode: _focusNodeUsername,
          label: AppLocalization.of(context)
              .translate("register_screen", "placeholder_pseudo"),
          obscure: false,
          icon: Icons.person,
          textInputAction: TextInputAction.go,
          clear: () {
            setState(() {
              _usernameController.clear();
            });
          },
          tap: () {
            FocusScope.of(context).requestFocus(_focusNodeUsername);
          },
          changed: (value) {
            setState(() {
              value = _usernameController.text;
            });
          },
          editingComplete: () {
            FocusScope.of(context).unfocus();
          },
          isDayMood: isDayMood,
        ),
        Padding(
          padding: EdgeInsets.only(top: 20.0, bottom: 5.0),
          child: Text(
            AppLocalization.of(context)
                .translate("register_screen", "inform_birthday"),
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
        GestureDetector(
          onTap: () {
            DatePicker.showDatePicker(context,
                showTitleActions: true,
                theme: DatePickerTheme(
                  backgroundColor: Theme.of(context).canvasColor,
                  cancelStyle: textStyleCustomBold(cRedCancel, 14),
                  doneStyle: textStyleCustomBold(cGreenConfirm, 14),
                  itemStyle: textStyleCustomBold(
                      Theme.of(context).iconTheme.color!, 15),
                ),
                minTime: DateTime(1900, 1, 1),
                maxTime: DateTime.now(), onConfirm: (date) {
              _dateBirthday = date;
              final verif = DateTime.now().subtract(const Duration(days: 4745));
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
                locale: deviceLanguage == "fr" ? LocaleType.fr : LocaleType.en);
          },
          child: Container(
            height: 45,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: Theme.of(context).canvasColor,
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(5.0)),
            child: Text(
              Helpers.dateBirthday(_dateBirthday ?? DateTime.now()),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: 20.0, bottom: 5.0),
          child: Text(
            AppLocalization.of(context)
                .translate("register_screen", "inform_nationnality"),
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
        GestureDetector(
          onTap: () {
            _onPressedShowBottomSheet();
          },
          child: Container(
            height: 45,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: Theme.of(context).canvasColor,
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(5.0)),
            child: country == null
                ? Container()
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        height: 40,
                        width: 40,
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
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                    ],
                  ),
          ),
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
          AppLocalization.of(context)
              .translate("register_screen", "register_third_step"),
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 15.0),
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
        height: MediaQuery.of(context).size.height / 15,
        color: Theme.of(context).scaffoldBackgroundColor,
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(
            width: MediaQuery.of(context).size.width / 1.5,
            padding: const EdgeInsets.only(right: 4.0),
            child: TextFieldCustomRegister(
              context: context,
              controller: _searchController,
              focusNode: _focusNodeSearch,
              label: AppLocalization.of(context)
                  .translate("register_screen", "placeholder_search_game"),
              obscure: false,
              icon: Icons.search,
              textInputAction: TextInputAction.search,
              clear: () {
                setState(() {
                  _searchController.clear();
                  _focusNodeSearch.unfocus();
                });
                if (gamesSearch.length != 0) {
                  gamesSearch.clear();
                }
              },
              tap: () {
                FocusScope.of(context).requestFocus(_focusNodeSearch);
              },
              changed: (value) {
                setState(() {
                  value = _searchController.text;
                });
              },
              editingComplete: () {
                Helpers.hideKeyboard(context);
                _searchGames(_searchController.text);
              },
              isDayMood: isDayMood,
            ),
          ),
          Expanded(
            child: TextButton(
                onPressed: () {
                  if (_searchController.text.isNotEmpty) {
                    setState(() {
                      _searchController.clear();
                    });
                  }
                },
                child: Text(
                  AppLocalization.of(context)
                      .translate("register_screen", "cancel"),
                  textAlign: TextAlign.center,
                  style: textStyleCustomBold(
                      _searchController.text.isNotEmpty
                          ? isDayMood
                              ? cPrimaryPink
                              : cPrimaryPurple
                          : Colors.grey,
                      11),
                )),
          )
        ]));
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
                child: stopReached
                    ? Center(
                        child: Text(
                          AppLocalization.of(context)
                              .translate("register_screen", "no_more_games"),
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                      )
                    : isLoadingMoreData
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
                        : SizedBox()),
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
                    color: isDayMood ? cPrimaryPink : cPrimaryPurple,
                  ),
                ),
                SizedBox(
                  width: 5.0,
                ),
                Text(
                  _searchController.text.length < 10
                      ? '${AppLocalization.of(context).translate("register_screen", "search_game")} "${_searchController.text}.."'
                      : '${AppLocalization.of(context).translate("register_screen", "search_game")} "${_searchController.text.substring(0, 10)}.."',
                  style: Theme.of(context).textTheme.titleSmall,
                )
              ],
            ),
          )
        : gamesSearch.length == 0
            ? Padding(
                padding: const EdgeInsets.symmetric(vertical: 25.0),
                child: Center(
                  child: Text(
                    AppLocalization.of(context)
                        .translate("register_screen", "no_games_found"),
                    style: Theme.of(context).textTheme.titleSmall,
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
                itemCount: gamesSearch.length,
                itemBuilder: (_, index) {
                  Game gameAlgolia = Game.fromMapAlgolia(
                      gamesSearch[index], gamesSearch[index].data);
                  return _itemGame(gameAlgolia, isDayMood);
                });
  }

  Widget _itemGame(Game game, bool isDayMood) {
    return InkWell(
      onTap: () {
        if (gamesFollow.any((element) => element.name == game.name)) {
          setState(() {
            ref
                .read(gamesFollowRegisterNotifierProvider.notifier)
                .removeGame(game);
          });
          if (gamesFollow.length < 2 && gamesValid) {
            ref
                .read(gamesValidRegisterNotifierProvider.notifier)
                .updateValidity(false);
          }
        } else {
          setState(() {
            ref
                .read(gamesFollowRegisterNotifierProvider.notifier)
                .addGame(game);
          });
          if (gamesFollow.length >= 2 && !gamesValid) {
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
                  style: textStyleCustomBold(Colors.white, 14),
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
            AppLocalization.of(context)
                .translate("register_screen", "register_finish"),
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 20.0, bottom: 5.0),
          child: Text(
            AppLocalization.of(context).translate("register_screen", "email"),
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
        TextFieldCustomRegister(
          context: context,
          controller: _emailController,
          focusNode: _focusNodeEmail,
          label: AppLocalization.of(context)
              .translate("register_screen", "placeholder_mail"),
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
            _focusNodeEmail.unfocus();
          },
          isDayMood: isDayMood,
        ),
        Padding(
          padding: const EdgeInsets.only(left: 5.0, top: 1.0),
          child: Visibility(
              visible: !emailValid ? true : false,
              child: Text(
                AppLocalization.of(context)
                    .translate("register_screen", "invalid_email"),
                style: textStyleCustomBold(cRedCancel, 11),
              )),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 20.0, bottom: 5.0),
          child: Text(
            AppLocalization.of(context)
                .translate("register_screen", "password"),
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
        TextFieldCustomRegister(
          context: context,
          controller: _passwordController,
          focusNode: _focusNodePassword,
          label: AppLocalization.of(context)
              .translate("register_screen", "placeholder_password"),
          obscure: true,
          icon: Icons.lock,
          textInputAction: TextInputAction.next,
          clear: () {
            setState(() {
              _passwordController.clear();
            });
          },
          tap: () {
            FocusScope.of(context).requestFocus(_focusNodePassword);
          },
          changed: (value) {
            setState(() {
              value = _passwordController.text;
            });
          },
          editingComplete: () {
            FocusScope.of(context).requestFocus(_focusNodeConfirmPassword);
          },
          isDayMood: isDayMood,
        ),
        const SizedBox(
          height: 10.0,
        ),
        TextFieldCustomRegister(
          context: context,
          controller: _confirmPasswordController,
          focusNode: _focusNodeConfirmPassword,
          label: AppLocalization.of(context)
              .translate("register_screen", "placeholder_confirm_password"),
          obscure: true,
          icon: Icons.lock,
          textInputAction: TextInputAction.go,
          clear: () {
            setState(() {
              _confirmPasswordController.clear();
            });
          },
          tap: () {
            FocusScope.of(context).requestFocus(_focusNodeConfirmPassword);
          },
          changed: (value) {
            setState(() {
              value = _confirmPasswordController.text;
            });
          },
          editingComplete: () {
            FocusScope.of(context).unfocus();
          },
          isDayMood: isDayMood,
        ),
        Padding(
          padding: const EdgeInsets.only(left: 5.0, top: 1.0),
          child: Visibility(
              visible: !passwordValid ? true : false,
              child: Text(
                AppLocalization.of(context)
                    .translate("register_screen", "invalid_password"),
                style: textStyleCustomBold(cRedCancel, 11),
              )),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 20.0, bottom: 5.0),
          child: Text(
            AppLocalization.of(context).translate("register_screen", "pseudo"),
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
        TextFieldCustomRegister(
          context: context,
          controller: _usernameController,
          focusNode: _focusNodeUsername,
          label: AppLocalization.of(context)
              .translate("register_screen", "placeholder_pseudo"),
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
            _focusNodeUsername.unfocus();
          },
          isDayMood: isDayMood,
        ),
        Padding(
          padding: const EdgeInsets.only(left: 5.0, top: 1.0),
          child: Visibility(
              visible: !usernameValid ? true : false,
              child: Text(
                AppLocalization.of(context)
                    .translate("register_screen", "invalid_pseudo"),
                style: textStyleCustomBold(cRedCancel, 11),
              )),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 20.0, bottom: 5.0),
          child: Text(
            AppLocalization.of(context)
                .translate("register_screen", "birthday"),
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
        GestureDetector(
          onTap: () {
            DatePicker.showDatePicker(context,
                showTitleActions: true,
                theme: DatePickerTheme(
                  backgroundColor: Theme.of(context).canvasColor,
                  cancelStyle: textStyleCustomBold(cRedCancel, 14),
                  doneStyle: textStyleCustomBold(cGreenConfirm, 14),
                  itemStyle: textStyleCustomBold(
                      Theme.of(context).iconTheme.color!, 15),
                ),
                minTime: DateTime(1900, 1, 1),
                maxTime: DateTime.now(), onConfirm: (date) {
              _dateBirthday = date;
              final verif = DateTime.now().subtract(const Duration(days: 4745));
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
                locale: deviceLanguage == "fr" ? LocaleType.fr : LocaleType.en);
          },
          child: Container(
            height: 45,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: Theme.of(context).canvasColor,
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(5.0)),
            child: Text(
              Helpers.dateBirthday(_dateBirthday ?? DateTime.now()),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
        ),
        Padding(
            padding: const EdgeInsets.only(left: 5.0, top: 1.0),
            child: Visibility(
                visible: !anniversaryValid ? true : false,
                child: Text(
                  AppLocalization.of(context)
                      .translate("register_screen", "invalid_birthday"),
                  style: textStyleCustomBold(cRedCancel, 11),
                ))),
        Padding(
          padding: const EdgeInsets.only(top: 20.0, bottom: 5.0),
          child: Text(
            AppLocalization.of(context)
                .translate("register_screen", "nationnality"),
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
        GestureDetector(
          onTap: () {
            _onPressedShowBottomSheet();
          },
          child: Container(
            height: 45,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: Theme.of(context).canvasColor,
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(5.0)),
            child: country == null
                ? Container()
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        height: 40,
                        width: 40,
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
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                    ],
                  ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 20.0),
          child: Text(
            AppLocalization.of(context)
                .translate("register_screen", "follows_games"),
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
        Column(
          children: [
            gamesFollow.length != 0
                ? GridView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        childAspectRatio: 0.6,
                        crossAxisSpacing: 6,
                        mainAxisSpacing: 6),
                    padding: EdgeInsets.symmetric(vertical: 10.0),
                    itemCount: gamesFollow.length,
                    itemBuilder: (_, index) {
                      Game game = gamesFollow[index];
                      return _itemGameFollow(game, isDayMood);
                    })
                : const SizedBox(),
            gamesFollow.length < 2
                ? Padding(
                    padding: const EdgeInsets.only(top: 5.0),
                    child: Text(
                      AppLocalization.of(context)
                          .translate("register_screen", "invalid_games"),
                      style: textStyleCustomBold(cRedCancel, 12),
                    ),
                  )
                : const SizedBox(),
            MaterialButton(
              child: Text(
                AppLocalization.of(context)
                    .translate("register_screen", "redirect_games"),
                style: Theme.of(context).textTheme.titleSmall,
              ),
              color: isDayMood ? cPrimaryPink : cPrimaryPurple,
              onPressed: () => {
                setState(() {
                  _tabController.index -= 1;
                })
              },
              elevation: 6,
            ),
          ],
        ),
        CheckboxListTile(
          dense: false,
          value: cgu,
          title: RichText(
              text: TextSpan(
                  text: AppLocalization.of(context)
                      .translate("register_screen", "accept_cgu"),
                  style: textStyleCustomBold(
                      Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : Colors.black,
                      12),
                  children: [
                TextSpan(
                  text: AppLocalization.of(context)
                      .translate("register_screen", "cgu"),
                  style: textStyleCustomBold(
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
                  text: AppLocalization.of(context)
                      .translate("register_screen", "accept_confidentiality"),
                  style: textStyleCustomBold(
                      Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : Colors.black,
                      12),
                  children: [
                TextSpan(
                    text: AppLocalization.of(context)
                        .translate("register_screen", "confidentiality"),
                    style: textStyleCustomBold(
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
                style: textStyleCustomBold(Colors.white, 14),
                textAlign: TextAlign.end,
              )),
        ),
      ],
    );
  }
}
