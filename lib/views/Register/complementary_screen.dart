import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gemu/views/Welcome/welcome_screen.dart';
import 'package:gemu/widgets/alert_dialog_custom.dart';

class ComplementaryScreen extends StatefulWidget {
  const ComplementaryScreen({Key? key}) : super(key: key);

  @override
  _ComplementaryScreenState createState() => _ComplementaryScreenState();
}

class _ComplementaryScreenState extends State<ComplementaryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    _tabController = TabController(length: 3, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          systemOverlayStyle: SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness:
                  Theme.of(context).brightness == Brightness.dark
                      ? Brightness.light
                      : Brightness.dark),
          leading: IconButton(
              onPressed: () => showDialog(
                  context: context,
                  builder: (_) {
                    return AlertDialogCustom(context, "Annuler l'inscription",
                        "Êtes-vous sur de vouloir annuler votre inscription?", [
                      TextButton(
                          onPressed: () => Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => WelcomeScreen()),
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
                  }),
              icon: Icon(
                Icons.clear,
                size: 30,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black,
              )),
          title: Container(
            width: MediaQuery.of(context).size.width / 2,
            child: Text(
              "Finaliser l'inscription",
              style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : Colors.black,
                  fontSize: 23,
                  fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
              maxLines: 2,
            ),
          ),
          centerTitle: true,
        ),
        body: Column(
          children: [Expanded(child: bodySteps()), bottomSteps()],
        ));
  }

  Widget bodySteps() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
      child: TabBarView(
          controller: _tabController,
          physics: NeverScrollableScrollPhysics(),
          children: [
            Column(
              children: [
                Expanded(child: Container()),
                btnNext(),
              ],
            ),
            Column(
              children: [
                Expanded(child: Container()),
                btnPrevious(),
                btnNext(),
              ],
            ),
            Column(
              children: [
                Expanded(child: Container()),
                btnPrevious(),
                btnFinish(),
              ],
            )
          ]),
    );
  }

  Widget bottomSteps() {
    return Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        padding: const EdgeInsets.only(bottom: 5),
        child: TabPageSelector(
          controller: _tabController,
          selectedColor: Theme.of(context).primaryColor,
          color: Colors.transparent,
          indicatorSize: 14,
        ));
  }

  Widget btnNext() {
    return Container(
      height: MediaQuery.of(context).size.height / 12,
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 10.0),
      child: ElevatedButton(
        onPressed: () {
          if (_tabController.index != _tabController.length - 1) {
            setState(() {
              _tabController.index += 1;
            });
          }
        },
        style: ElevatedButton.styleFrom(
            elevation: 6,
            shadowColor: Theme.of(context).primaryColor,
            primary: Theme.of(context).primaryColor,
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
    return TextButton(
        onPressed: () {
          if (_tabController.index != 0) {
            setState(() {
              _tabController.index -= 1;
            });
          }
        },
        child: Text("Précédent",
            style: TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.w500,
                decoration: TextDecoration.underline),
            textAlign: TextAlign.center));
  }

  Widget btnFinish() {
    return Container(
      height: MediaQuery.of(context).size.height / 12,
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 10.0),
      child: ElevatedButton(
        onPressed: () {
          print("s'inscrire");
        },
        style: ElevatedButton.styleFrom(
            elevation: 6,
            shadowColor: Theme.of(context).primaryColor,
            primary: Theme.of(context).primaryColor,
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
}

// AnimatedContainer(
//             duration: _duration,
//             curve: Curves.easeInOut,
//             height: MediaQuery.of(context).size.height,
//             width: MediaQuery.of(context).size.width,
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 begin: Alignment.topCenter,
//                 end: Alignment.bottomCenter,
//                 colors: isDayMood ? lightBgColors : darkBgColors,
//               ),
//             ),
//             child: SafeArea(
//               child: Container(
//                   decoration: BoxDecoration(
//                       gradient: LinearGradient(
//                           begin: Alignment.topCenter,
//                           end: Alignment.bottomCenter,
//                           colors: [
//                         Theme.of(context)
//                             .scaffoldBackgroundColor
//                             .withOpacity(0.1),
//                         Theme.of(context)
//                             .scaffoldBackgroundColor
//                             .withOpacity(0.8)
//                       ])),
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.start,
//                     children: [
//                       Container(
//                         height: MediaQuery.of(context).size.height / 8,
//                         child: Row(
//                           children: [
//                             Container(
//                               width: MediaQuery.of(context).size.width / 6,
//                               alignment: Alignment.center,
//                               child: IconButton(
//                                   onPressed: () =>
//                                       Navigator.pushAndRemoveUntil(
//                                           context,
//                                           MaterialPageRoute(
//                                               builder:
//                                                   (BuildContext context) =>
//                                                       WelcomeScreen()),
//                                           (route) => false),
//                                   icon: Icon(
//                                     Icons.arrow_back_ios,
//                                     color: Theme.of(context).canvasColor,
//                                   )),
//                             ),
//                             Expanded(
//                                 child: Container(
//                               alignment: Alignment.center,
//                               child: Padding(
//                                 padding: EdgeInsets.only(
//                                     right: MediaQuery.of(context).size.width /
//                                         6),
//                                 child: Text('Register',
//                                     style: mystyle(25, Colors.white)),
//                               ),
//                             ))
//                           ],
//                         ),
//                       ),
//                       Expanded(
//                           child: PageView(
//                         controller: _pageController,
//                         onPageChanged: (index) {
//                           if (index == 0) {
//                             _hideKeyboard();
//                             setState(() {
//                               currentPageIndex = 0;
//                             });
//                           } else {
//                             _hideKeyboard();
//                             setState(() {
//                               currentPageIndex = 1;
//                             });
//                           }
//                         },
//                         children: [firstPage(country), secondPage()],
//                       )),
//                       Container(
//                         height: MediaQuery.of(context).size.height / 14,
//                         alignment: Alignment.center,
//                         child: bottomBar(country),
//                       ),
//                     ],
//                   )),
//             )),

// Widget firstPage(Country? country) {
//   return ListView(
//     padding: EdgeInsets.zero,
//     shrinkWrap: true,
//     physics: AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
//     children: [
//       Container(
//         width: MediaQuery.of(context).size.width,
//         padding: EdgeInsets.only(left: 20.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             Text(
//               'User information',
//               style: mystyle(28),
//             ),
//             const SizedBox(
//               height: 5.0,
//             ),
//             Text('Enter your personnal information'),
//           ],
//         ),
//       ),
//       Padding(
//         padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
//         child: Text(
//           'Enter your username',
//           style: mystyle(12),
//         ),
//       ),
//       Container(
//         width: MediaQuery.of(context).size.width,
//         margin: EdgeInsets.only(left: 20.0, right: 20.0),
//         child: TextFieldCustom(
//           context: context,
//           controller: _usernameController,
//           focusNode: _focusNodeUsername,
//           label: 'Username',
//           obscure: false,
//           icon: Icons.person,
//           textInputAction: TextInputAction.next,
//           clear: () {
//             setState(() {
//               _usernameController.clear();
//             });
//           },
//           submit: (value) {
//             value = _usernameController.text;
//             _focusNodeUsername.unfocus();
//             FocusScope.of(context).requestFocus(_focusNodeEmail);
//           },
//         ),
//       ),
//       const SizedBox(
//         height: 20,
//       ),
//       Padding(
//         padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
//         child: Text(
//           'Enter your email',
//           style: mystyle(12),
//         ),
//       ),
//       Container(
//         width: MediaQuery.of(context).size.width,
//         margin: EdgeInsets.only(left: 20.0, right: 20.0),
//         child: TextFieldCustom(
//           context: context,
//           controller: _emailController,
//           focusNode: _focusNodeEmail,
//           label: 'Email',
//           obscure: false,
//           icon: Icons.mail,
//           textInputAction: TextInputAction.next,
//           textInputType: TextInputType.emailAddress,
//           clear: () {
//             setState(() {
//               _emailController.clear();
//             });
//           },
//           submit: (value) {
//             value = _emailController.text;
//             _focusNodeEmail.unfocus();
//             FocusScope.of(context).requestFocus(_focusNodePassword);
//           },
//         ),
//       ),
//       const SizedBox(
//         height: 20.0,
//       ),
//       Padding(
//         padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
//         child: Text(
//           'Enter your password',
//           style: mystyle(12),
//         ),
//       ),
//       Container(
//           width: MediaQuery.of(context).size.width,
//           margin: EdgeInsets.only(left: 20.0, right: 20.0),
//           child: TextFieldCustom(
//             context: context,
//             controller: _passwordController,
//             focusNode: _focusNodePassword,
//             label: 'Password',
//             obscure: true,
//             icon: Icons.lock,
//             textInputAction: TextInputAction.next,
//             clear: () {
//               setState(() {
//                 _passwordController.clear();
//               });
//             },
//             submit: (value) {
//               value = _passwordController.text;
//               _focusNodePassword.unfocus();
//               FocusScope.of(context).requestFocus(_focusNodeConfirmPassword);
//             },
//           )),
//       const SizedBox(
//         height: 10.0,
//       ),
//       Container(
//           width: MediaQuery.of(context).size.width,
//           margin: EdgeInsets.only(left: 20.0, right: 20.0),
//           child: TextFieldCustom(
//             context: context,
//             controller: _confirmPasswordController,
//             focusNode: _focusNodeConfirmPassword,
//             label: 'Confirm password',
//             obscure: true,
//             icon: Icons.lock,
//             textInputAction: TextInputAction.go,
//             clear: () {
//               setState(() {
//                 _confirmPasswordController.clear();
//               });
//             },
//             submit: (value) {
//               value = _confirmPasswordController.text;
//               _focusNodeConfirmPassword.unfocus();
//             },
//           )),
//       const SizedBox(
//         height: 20.0,
//       ),
//       Padding(
//         padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
//         child: Text(
//           'Select your nationnality',
//           style: mystyle(11),
//         ),
//       ),
//       Container(
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//           children: [
//             country == null
//                 ? Container()
//                 : Column(
//                     children: <Widget>[
//                       Container(
//                         height: 30,
//                         width: 50,
//                         child: Image.asset(
//                           country.flag,
//                           package: countryCodePackageName,
//                         ),
//                       ),
//                       SizedBox(
//                         height: 5.0,
//                       ),
//                       Text(
//                         '${country.name} (${country.countryCode})',
//                         textAlign: TextAlign.center,
//                         style: mystyle(11),
//                       ),
//                     ],
//                   ),
//             MaterialButton(
//               child: Text('Select'),
//               color: Theme.of(context).canvasColor,
//               onPressed: _onPressedShowBottomSheet,
//             ),
//           ],
//         ),
//       ),
//     ],
//   );
// }

// Widget secondPage() {
//   return ListView(
//     controller: _mainScrollController,
//     padding: EdgeInsets.zero,
//     shrinkWrap: true,
//     physics: AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
//     children: [
//       topSelectionGames(),
//       StickyHeader(
//         controller: _mainScrollController,
//         header: _getStickyWidget(),
//         content: dataIsThere
//             ? Padding(
//                 padding: EdgeInsets.symmetric(vertical: 15.0),
//                 child: searchGames(),
//               )
//             : Center(
//                 child: CircularProgressIndicator(),
//               ),
//       ),
//     ],
//   );
// }

// Widget topSelectionGames() {
//   return gamesFollow.length != 0
//       ? Container(
//           height: 250,
//           width: MediaQuery.of(context).size.width,
//           padding: EdgeInsets.only(left: 20.0),
//           child: Column(
//             children: [
//               Text(
//                 'Selected games',
//                 style: mystyle(28),
//               ),
//               const SizedBox(
//                 height: 5.0,
//               ),
//               Text('Selects at least two games'),
//               const SizedBox(
//                 height: 10.0,
//               ),
//               Container(
//                   height: MediaQuery.of(context).size.height / 8,
//                   child: ListView.builder(
//                     shrinkWrap: true,
//                     scrollDirection: Axis.horizontal,
//                     itemCount: gamesFollow.length,
//                     itemBuilder: (_, index) {
//                       Game game = gamesFollow[index];
//                       return Container(
//                         child: Padding(
//                           padding: EdgeInsets.symmetric(
//                               vertical: 5.0, horizontal: 5.0),
//                           child: Container(
//                             height: 70,
//                             width: 70,
//                             child: Stack(
//                               children: [
//                                 Align(
//                                   alignment: Alignment.center,
//                                   child: GestureDetector(
//                                     onTap: () {
//                                       setState(() {
//                                         gamesFollow.remove(game);
//                                         allGames.add(game);
//                                       });
//                                     },
//                                     child: Container(
//                                       height: 60,
//                                       width: 60,
//                                       decoration: BoxDecoration(
//                                           gradient: LinearGradient(
//                                               begin: Alignment.topLeft,
//                                               end: Alignment.bottomRight,
//                                               colors: [
//                                                 Theme.of(context)
//                                                     .colorScheme
//                                                     .primary,
//                                                 Theme.of(context)
//                                                     .colorScheme
//                                                     .secondary
//                                               ]),
//                                           border:
//                                               Border.all(color: Colors.black),
//                                           borderRadius:
//                                               BorderRadius.circular(10),
//                                           image: DecorationImage(
//                                               image:
//                                                   CachedNetworkImageProvider(
//                                                       game.imageUrl),
//                                               fit: BoxFit.cover)),
//                                     ),
//                                   ),
//                                 ),
//                                 Positioned(
//                                     bottom: 0,
//                                     right: 0,
//                                     child: GestureDetector(
//                                       onTap: () {
//                                         setState(() {
//                                           gamesFollow.remove(game);
//                                           allGames.add(game);
//                                         });
//                                       },
//                                       child: Container(
//                                           height: 25,
//                                           width: 25,
//                                           decoration: BoxDecoration(
//                                               color: Colors.red[400],
//                                               shape: BoxShape.circle,
//                                               border: Border.all(
//                                                   color: Colors.black)),
//                                           child: Icon(
//                                             Icons.remove,
//                                             size: 20,
//                                             color: Colors.black,
//                                           )),
//                                     )),
//                               ],
//                             ),
//                           ),
//                         ),
//                       );
//                     },
//                   )),
//               const SizedBox(
//                 height: 10.0,
//               ),
//               Text(
//                 'Selection games',
//                 style: mystyle(28),
//               ),
//               const SizedBox(
//                 height: 5.0,
//               ),
//               Text('Choose the games you want to follow'),
//               const SizedBox(
//                 height: 5.0,
//               ),
//             ],
//           ),
//         )
//       : Container(
//           height: 100,
//           width: MediaQuery.of(context).size.width,
//           padding: EdgeInsets.only(left: 20.0),
//           child: Column(
//             children: [
//               Text(
//                 'Selection games',
//                 style: mystyle(28),
//               ),
//               const SizedBox(
//                 height: 5.0,
//               ),
//               Text('Choose the games you want to follow'),
//             ],
//           ),
//         );
// }

// Widget _getStickyWidget() {
//   return Padding(
//     padding: const EdgeInsets.symmetric(horizontal: 10.0),
//     child: TextFieldCustom(
//       context: context,
//       controller: _searchController,
//       focusNode: _focusNodeSearch,
//       label: 'Search',
//       obscure: false,
//       icon: Icons.search,
//       textInputAction: TextInputAction.search,
//       clear: () {
//         setState(() {
//           _searchController.clear();
//         });
//       },
//       submit: (value) {
//         value = _searchController.text;
//         _searchGames(value);
//       },
//     ),
//   );
// }

// Widget searchGames() {
//   return Container(
//     child: isSearching
//         ? Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               Container(
//                 height: 15.0,
//                 width: 15.0,
//                 child: CircularProgressIndicator(
//                   color: Theme.of(context).primaryColor,
//                 ),
//               ),
//               SizedBox(
//                 width: 5.0,
//               ),
//               Text(
//                 _searchController.text.length < 10
//                     ? 'Recherche de "${_searchController.text}.."'
//                     : 'Recherche de "${_searchController.text.substring(0, 10)}.."',
//                 style: mystyle(11),
//               )
//             ],
//           )
//         : _searchController.text.isEmpty
//             ? selectionGames()
//             : gamesAlgolia.length == 0
//                 ? Center(
//                     child: Text(
//                       'No games found',
//                       style: mystyle(12),
//                     ),
//                   )
//                 : GridView.builder(
//                     gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                         crossAxisCount: 3,
//                         childAspectRatio: 1.0,
//                         crossAxisSpacing: 6,
//                         mainAxisSpacing: 6),
//                     shrinkWrap: true,
//                     itemCount: gamesAlgolia.length,
//                     itemBuilder: (_, index) {
//                       Game gameAlgolia = Game.fromMapAlgolia(
//                           gamesAlgolia[index], gamesAlgolia[index].data);
//                       return gamesFollow.any(
//                               (element) => element.name == gameAlgolia.name)
//                           ? Container(
//                               child: Column(
//                                 children: [
//                                   Padding(
//                                     padding: const EdgeInsets.symmetric(
//                                         vertical: 5.0),
//                                     child: Container(
//                                       height: 70,
//                                       width: 70,
//                                       child: Stack(
//                                         children: [
//                                           Align(
//                                             alignment: Alignment.center,
//                                             child: GestureDetector(
//                                               onTap: () {
//                                                 setState(() {
//                                                   gamesFollow.removeWhere(
//                                                       (element) =>
//                                                           element.name ==
//                                                           gameAlgolia.name);
//                                                   allGames.add(gameAlgolia);
//                                                 });

//                                                 _focusNodeSearch.unfocus();
//                                                 _searchController.clear();
//                                               },
//                                               child: Container(
//                                                 height: 60,
//                                                 width: 60,
//                                                 decoration: BoxDecoration(
//                                                     gradient: LinearGradient(
//                                                         begin:
//                                                             Alignment.topLeft,
//                                                         end: Alignment
//                                                             .bottomRight,
//                                                         colors: [
//                                                           Theme.of(context)
//                                                               .colorScheme
//                                                               .primary,
//                                                           Theme.of(context)
//                                                               .colorScheme
//                                                               .secondary
//                                                         ]),
//                                                     borderRadius:
//                                                         BorderRadius.circular(
//                                                             10),
//                                                     border: Border.all(
//                                                         color: Colors.black),
//                                                     image: DecorationImage(
//                                                         fit: BoxFit.cover,
//                                                         image: CachedNetworkImageProvider(
//                                                             gameAlgolia
//                                                                 .imageUrl))),
//                                               ),
//                                             ),
//                                           ),
//                                           Positioned(
//                                               bottom: 0,
//                                               right: 0,
//                                               child: GestureDetector(
//                                                 onTap: () {
//                                                   setState(() {
//                                                     gamesFollow.removeWhere(
//                                                         (element) =>
//                                                             element.name ==
//                                                             gameAlgolia.name);
//                                                     allGames.add(gameAlgolia);
//                                                   });
//                                                   _focusNodeSearch.unfocus();
//                                                   _searchController.clear();
//                                                 },
//                                                 child: Container(
//                                                     height: 25,
//                                                     width: 25,
//                                                     decoration: BoxDecoration(
//                                                         color:
//                                                             Colors.red[400],
//                                                         shape:
//                                                             BoxShape.circle,
//                                                         border: Border.all(
//                                                             color: Colors
//                                                                 .black)),
//                                                     child: Icon(
//                                                       Icons.remove,
//                                                       size: 20,
//                                                       color: Colors.black,
//                                                     )),
//                                               )),
//                                         ],
//                                       ),
//                                     ),
//                                   ),
//                                   Text(
//                                     gameAlgolia.name,
//                                     textAlign: TextAlign.center,
//                                   )
//                                 ],
//                               ),
//                             )
//                           : Container(
//                               child: Column(
//                                 children: [
//                                   Padding(
//                                     padding: const EdgeInsets.symmetric(
//                                         vertical: 5.0),
//                                     child: Container(
//                                       height: 70,
//                                       width: 70,
//                                       child: Stack(
//                                         children: [
//                                           Align(
//                                             alignment: Alignment.center,
//                                             child: GestureDetector(
//                                               onTap: () {
//                                                 setState(() {
//                                                   allGames.removeWhere(
//                                                       (element) =>
//                                                           element.name ==
//                                                           gameAlgolia.name);
//                                                   gamesFollow
//                                                       .add(gameAlgolia);
//                                                 });

//                                                 _focusNodeSearch.unfocus();
//                                                 _searchController.clear();
//                                               },
//                                               child: Container(
//                                                 height: 60,
//                                                 width: 60,
//                                                 decoration: BoxDecoration(
//                                                     gradient: LinearGradient(
//                                                         begin:
//                                                             Alignment.topLeft,
//                                                         end: Alignment
//                                                             .bottomRight,
//                                                         colors: [
//                                                           Theme.of(context)
//                                                               .colorScheme
//                                                               .primary,
//                                                           Theme.of(context)
//                                                               .colorScheme
//                                                               .secondary
//                                                         ]),
//                                                     borderRadius:
//                                                         BorderRadius.circular(
//                                                             10),
//                                                     border: Border.all(
//                                                         color: Colors.black),
//                                                     image: DecorationImage(
//                                                         fit: BoxFit.cover,
//                                                         image: CachedNetworkImageProvider(
//                                                             gameAlgolia
//                                                                 .imageUrl))),
//                                               ),
//                                             ),
//                                           ),
//                                           Positioned(
//                                               bottom: 0,
//                                               right: 0,
//                                               child: GestureDetector(
//                                                 onTap: () {
//                                                   setState(() {
//                                                     allGames.removeWhere(
//                                                         (element) =>
//                                                             element.name ==
//                                                             gameAlgolia.name);
//                                                     gamesFollow
//                                                         .add(gameAlgolia);
//                                                   });
//                                                   _focusNodeSearch.unfocus();
//                                                   _searchController.clear();
//                                                 },
//                                                 child: Container(
//                                                     height: 25,
//                                                     width: 25,
//                                                     decoration: BoxDecoration(
//                                                         color:
//                                                             Colors.green[400],
//                                                         shape:
//                                                             BoxShape.circle,
//                                                         border: Border.all(
//                                                             color: Colors
//                                                                 .black)),
//                                                     child: Icon(
//                                                       Icons.add,
//                                                       size: 20,
//                                                       color: Colors.black,
//                                                     )),
//                                               )),
//                                         ],
//                                       ),
//                                     ),
//                                   ),
//                                   Text(
//                                     gameAlgolia.name,
//                                     textAlign: TextAlign.center,
//                                   )
//                                 ],
//                               ),
//                             );
//                     }),
//   );
// }

// Widget selectionGames() {
//   return Column(
//     children: [
//       GridView.builder(
//           shrinkWrap: true,
//           scrollDirection: Axis.vertical,
//           controller: _gamesScrollController,
//           gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//               crossAxisCount: 3,
//               childAspectRatio: 1.0,
//               crossAxisSpacing: 6,
//               mainAxisSpacing: 6),
//           itemCount: allGames.length,
//           itemBuilder: (_, int index) {
//             Game game = allGames[index];
//             return Container(
//               child: Column(
//                 children: [
//                   Padding(
//                     padding: const EdgeInsets.symmetric(vertical: 5.0),
//                     child: Container(
//                       height: 70,
//                       width: 70,
//                       child: Stack(
//                         children: [
//                           Align(
//                             alignment: Alignment.center,
//                             child: GestureDetector(
//                               onTap: () {
//                                 setState(() {
//                                   allGames.remove(game);
//                                   gamesFollow.add(game);
//                                 });
//                               },
//                               child: Container(
//                                 height: 60,
//                                 width: 60,
//                                 decoration: BoxDecoration(
//                                     gradient: LinearGradient(
//                                         begin: Alignment.topLeft,
//                                         end: Alignment.bottomRight,
//                                         colors: [
//                                           Theme.of(context)
//                                               .colorScheme
//                                               .primary,
//                                           Theme.of(context)
//                                               .colorScheme
//                                               .secondary
//                                         ]),
//                                     borderRadius: BorderRadius.circular(10),
//                                     border: Border.all(color: Colors.black),
//                                     image: DecorationImage(
//                                         fit: BoxFit.cover,
//                                         image: CachedNetworkImageProvider(
//                                             game.imageUrl))),
//                               ),
//                             ),
//                           ),
//                           Positioned(
//                               bottom: 0,
//                               right: 0,
//                               child: GestureDetector(
//                                 onTap: () {
//                                   setState(() {
//                                     allGames.remove(game);
//                                     gamesFollow.add(game);
//                                   });
//                                 },
//                                 child: Container(
//                                     height: 25,
//                                     width: 25,
//                                     decoration: BoxDecoration(
//                                         color: Colors.green[400],
//                                         shape: BoxShape.circle,
//                                         border:
//                                             Border.all(color: Colors.black)),
//                                     child: Icon(
//                                       Icons.add,
//                                       size: 20,
//                                       color: Colors.black,
//                                     )),
//                               )),
//                         ],
//                       ),
//                     ),
//                   ),
//                   Text(
//                     game.name,
//                     textAlign: TextAlign.center,
//                   )
//                 ],
//               ),
//             );
//           }),
//       Padding(
//           padding: const EdgeInsets.only(bottom: 30.0),
//           child: Stack(
//             children: [
//               Container(
//                 height: isLoadingMoreData ? 50.0 : 0.0,
//                 child: Center(
//                   child: SizedBox(
//                     height: 30.0,
//                     width: 30.0,
//                     child: CircularProgressIndicator(
//                       color: Theme.of(context).primaryColor,
//                       strokeWidth: 1.5,
//                     ),
//                   ),
//                 ),
//               ),
//               Container(
//                 height: isResultLoading && newGames.length == 0 ? 50.0 : 0.0,
//                 child: Center(
//                   child: Text('C\'est tout pour le moment'),
//                 ),
//               )
//             ],
//           )),
//     ],
//   );
// }
