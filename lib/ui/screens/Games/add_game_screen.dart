import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:gemu/ui/constants/constants.dart';
import 'package:gemu/ui/controller/navigation_controller.dart';

class AddGameScreen extends StatefulWidget {
  @override
  AddGameScreenState createState() => AddGameScreenState();
}

class AddGameScreenState extends State<AddGameScreen> {
  bool dataIsThere = false;
  bool isSave = false;

  late TextEditingController _nameGameController;
  late FocusNode _nameGameFocusNode;

  File? fileLogo;
  List categories = [];
  List gameCategories = [];

  getData() async {
    var data = await FirebaseFirestore.instance.collection('categories').get();
    for (var item in data.docs) {
      categories.add(item);
    }

    setState(() {
      dataIsThere = !dataIsThere;
    });
  }

  pickLogo(ImageSource src) async {
    try {
      final image = await ImagePicker().getImage(source: src, imageQuality: 50);
      if (image != null) {
        setState(() {
          fileLogo = File(image.path);
        });
        Navigator.of(context);
      } else {
        Navigator.of(context);
      }
    } catch (e) {
      print(e);
    }
  }

  saveLogoToStorage() async {
    UploadTask storageUploadTask = FirebaseStorage.instance
        .ref()
        .child('games')
        .child(_nameGameController.text)
        .putFile(fileLogo!);
    TaskSnapshot storageTaskSnapshot =
        await storageUploadTask.whenComplete(() {});
    String downloadUrl = await storageTaskSnapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  saveNewGame() async {
    setState(() {
      isSave = !isSave;
    });

    String pictureLogo = await saveLogoToStorage();

    FirebaseFirestore.instance
        .collection('games')
        .doc(_nameGameController.text)
        .set({
      'id': _nameGameController.text,
      'imageUrl': pictureLogo,
      'name': _nameGameController.text,
      'categories': gameCategories,
      'verified': false
    });

    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
            builder: (_) => NavController(
                  uid: FirebaseAuth.instance.currentUser!.uid,
                )),
        (route) => false);
  }

  @override
  void initState() {
    super.initState();
    getData();
    _nameGameController = TextEditingController();
    _nameGameFocusNode = FocusNode();
  }

  @override
  void dispose() {
    categories.clear();
    _nameGameFocusNode.dispose();
    _nameGameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          flexibleSpace: Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                  Theme.of(context).primaryColor,
                  Theme.of(context).accentColor
                ])),
          ),
          elevation: 6,
          leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Icon(
                Icons.arrow_back_ios,
                color: Colors.white,
              )),
          title: Text(
            'Add game',
            style: mystyle(15, Colors.white),
          ),
        ),
        body: dataIsThere
            ? isSave
                ? Stack(
                    children: [
                      Container(
                        height: MediaQuery.of(context).size.height,
                        width: MediaQuery.of(context).size.width,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Expanded(
                                child: ListView(
                              physics: AlwaysScrollableScrollPhysics(),
                              shrinkWrap: true,
                              scrollDirection: Axis.vertical,
                              children: [
                                SizedBox(
                                  height: 40.0,
                                ),
                                nameGame(),
                                SizedBox(
                                  height: 40.0,
                                ),
                                addLogoGame(),
                                SizedBox(
                                  height: 40.0,
                                ),
                                categorieGame()
                              ],
                            )),
                            Container(
                                alignment: Alignment.centerRight,
                                width: MediaQuery.of(context).size.width,
                                height: 50,
                                child: Padding(
                                    padding: EdgeInsets.only(right: 10.0),
                                    child: GestureDetector(
                                      onTap: () {
                                        print(gameCategories);
                                      },
                                      child: Container(
                                        alignment: Alignment.center,
                                        height: 40,
                                        width: 70,
                                        decoration: BoxDecoration(
                                            border:
                                                Border.all(color: Colors.black),
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                            gradient: LinearGradient(
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                                colors: [
                                                  Theme.of(context)
                                                      .primaryColor,
                                                  Theme.of(context).accentColor
                                                ])),
                                        child: Text(
                                          'Save',
                                          style: mystyle(13),
                                        ),
                                      ),
                                    )))
                          ],
                        ),
                      ),
                      Center(
                          child: Container(
                        color: Theme.of(context)
                            .scaffoldBackgroundColor
                            .withOpacity(0.7),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Save..',
                                style: mystyle(18),
                              ),
                              SizedBox(
                                height: 20.0,
                              ),
                              CircularProgressIndicator(
                                color: Theme.of(context).primaryColor,
                              )
                            ],
                          ),
                        ),
                      ))
                    ],
                  )
                : GestureDetector(
                    onTap: () {
                      if (_nameGameFocusNode.hasFocus) {
                        _nameGameFocusNode.unfocus();
                      }
                    },
                    child: Container(
                      height: MediaQuery.of(context).size.height,
                      width: MediaQuery.of(context).size.width,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Expanded(
                              child: ListView(
                            physics: AlwaysScrollableScrollPhysics(
                                parent: BouncingScrollPhysics()),
                            shrinkWrap: true,
                            scrollDirection: Axis.vertical,
                            children: [
                              SizedBox(
                                height: 40.0,
                              ),
                              nameGame(),
                              SizedBox(
                                height: 40.0,
                              ),
                              addLogoGame(),
                              SizedBox(
                                height: 40.0,
                              ),
                              categorieGame()
                            ],
                          )),
                          Container(
                              alignment: Alignment.centerRight,
                              width: MediaQuery.of(context).size.width,
                              height: 50,
                              child: Padding(
                                  padding: EdgeInsets.only(right: 10.0),
                                  child: GestureDetector(
                                    onTap: () {
                                      if (_nameGameController.text != '' &&
                                          fileLogo != null &&
                                          gameCategories.length != 0) {
                                        saveNewGame();
                                      } else {
                                        print('Manque des choses');
                                      }
                                    },
                                    child: Container(
                                      alignment: Alignment.center,
                                      height: 40,
                                      width: 70,
                                      decoration: BoxDecoration(
                                          border:
                                              Border.all(color: Colors.black),
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                          gradient: LinearGradient(
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                              colors: [
                                                Theme.of(context).primaryColor,
                                                Theme.of(context).accentColor
                                              ])),
                                      child: Text(
                                        'Save',
                                        style: mystyle(13),
                                      ),
                                    ),
                                  )))
                        ],
                      ),
                    ))
            : Center(
                child: CircularProgressIndicator(
                  color: Theme.of(context).primaryColor,
                  strokeWidth: 1.5,
                ),
              ));
  }

  Widget nameGame() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Enter game name',
            style: mystyle(12),
          ),
          SizedBox(
            height: 25.0,
          ),
          TextFormField(
            controller: _nameGameController,
            focusNode: _nameGameFocusNode,
            maxLines: 1,
            decoration: InputDecoration(
                labelText: 'Game name',
                labelStyle: TextStyle(color: Theme.of(context).accentColor),
                suffixIcon: GestureDetector(
                  onTap: () => _nameGameController.clear(),
                  child: Icon(
                    Icons.clear,
                    color: Theme.of(context).accentColor,
                  ),
                ),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide:
                        BorderSide(color: Theme.of(context).accentColor))),
          )
        ],
      ),
    );
  }

  Widget addLogoGame() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Add logo game',
            style: mystyle(12),
          ),
          SizedBox(
            height: 25.0,
          ),
          Center(
            child: GestureDetector(
              onTap: () => pickLogo(ImageSource.gallery),
              child: fileLogo == null
                  ? Container(
                      height: 60,
                      width: 60,
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.black),
                          borderRadius: BorderRadius.circular(10.0),
                          gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Theme.of(context).primaryColor,
                                Theme.of(context).accentColor
                              ])),
                      child: Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 33,
                      ),
                    )
                  : Container(
                      height: 60,
                      width: 60,
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.black),
                          borderRadius: BorderRadius.circular(10.0),
                          gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Theme.of(context).primaryColor,
                                Theme.of(context).accentColor
                              ]),
                          image: DecorationImage(
                              fit: BoxFit.cover, image: FileImage(fileLogo!))),
                    ),
            ),
          )
        ],
      ),
    );
  }

  Widget categorieGame() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Choose game category',
            style: mystyle(12),
          ),
          SizedBox(
            height: 25.0,
          ),
          Center(
            child: GridView.builder(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 1,
                    crossAxisSpacing: 6,
                    mainAxisSpacing: 6),
                itemCount: categories.length,
                itemBuilder: (_, int index) {
                  DocumentSnapshot<Map<String, dynamic>> category =
                      categories[index];

                  return SelectCategory(
                    category: category,
                    gameCategories: gameCategories,
                  );
                }),
          )
        ],
      ),
    );
  }
}

class SelectCategory extends StatefulWidget {
  final DocumentSnapshot<Map<String, dynamic>> category;
  final List gameCategories;

  SelectCategory({required this.category, required this.gameCategories});

  @override
  SelectCategoryState createState() => SelectCategoryState();
}

class SelectCategoryState extends State<SelectCategory> {
  bool isSelect = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      width: 100,
      child: Column(
        children: [
          Stack(
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    isSelect = !isSelect;
                  });
                  if (isSelect == true &&
                      !widget.gameCategories
                          .contains(widget.category.data()!['name'])) {
                    widget.gameCategories.add(widget.category.data()!['name']);
                  }
                  if (isSelect == false &&
                      widget.gameCategories
                          .contains(widget.category.data()!['name'])) {
                    widget.gameCategories
                        .remove(widget.category.data()!['name']);
                  }
                },
                child: Container(
                  height: 60,
                  width: 60,
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.black),
                      borderRadius: BorderRadius.circular(10.0),
                      gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Theme.of(context).primaryColor,
                            Theme.of(context).accentColor
                          ])),
                  child: Icon(Icons.category),
                ),
              ),
              isSelect
                  ? Icon(
                      Icons.check,
                      color: Colors.green[100],
                    )
                  : SizedBox(),
            ],
          ),
          SizedBox(
            height: 15.0,
          ),
          Text(widget.category.data()!['name'])
        ],
      ),
    );
  }
}
