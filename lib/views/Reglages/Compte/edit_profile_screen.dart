import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gemu/constants/constants.dart';

import 'package:gemu/models/user.dart';
import 'package:gemu/services/cloud_storage_service.dart';
import 'package:gemu/services/database_service.dart';
import 'package:gemu/views/Reglages/Compte/edit_email_screen.dart';
import 'package:gemu/views/Reglages/Compte/edit_password_screen.dart';
import 'package:gemu/views/Reglages/Compte/edit_user_name_screen.dart';
import 'package:gemu/components/alert_dialog_custom.dart';

// ignore: must_be_immutable
class EditProfileScreen extends StatefulWidget {
  UserModel user;

  EditProfileScreen({required this.user});

  @override
  _EditProfileviewstate createState() => _EditProfileviewstate();
}

class _EditProfileviewstate extends State<EditProfileScreen> {
  File? _selectedImage;

  late StreamSubscription userListener;

  Future selectImage() async {
    var tempImage = await CloudStorageService.selectImage();
    if (tempImage != null) {
      _selectedImage = File(tempImage.path);
      setState(() {});
    }
  }

  Future addImgProfile(
      {required String title, required var currentUserID}) async {
    CloudStorageResult storageResult;

    try {
      storageResult = await CloudStorageService.uploadImage(
          imageToUpload: _selectedImage!, title: title + currentUserID);
      await DatabaseService.updateUserImgProfile(
          storageResult.imageUrl, currentUserID);

      FirebaseFirestore.instance
          .collection('posts')
          .where('uid', isEqualTo: currentUserID)
          .get()
          .then((data) {
        for (var item in data.docs) {
          item.reference.update({'imageUrl': storageResult.imageUrl});
        }
      });

      alertUpdateProfile(
          'Profile image successfully added', 'Your image has been changed');
    } catch (e) {
      alertNotUpdateProfile('Could not change profile image', 'Try again');
    }

    if (_selectedImage != null) {
      setState(() {
        _selectedImage = null;
      });
    }
  }

  Future deleteImgProfile(
      {required String title, required var currentUserID}) async {
    String imageFileName = title + currentUserID;

    var storage;

    storage =
        await CloudStorageService.deleteImage(imageFileName: imageFileName);
    print(storage);

    var result;

    result = await DatabaseService.deleteUserImgProfile(currentUserID);

    if (result is String) {
      alertNotUpdateProfile('Could not delete profile image', result);
    } else {
      alertUpdateProfile(
          'Profile image successfully deleted', 'Your image has been deleted');
    }
    if (_selectedImage != null) {
      setState(() {
        _selectedImage = null;
      });
    }
  }

  Future alertSaveBeforeLeave() {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialogCustom(context, 'Sauvegarder',
              'Voulez-vous sauvegarder vos changements?', [
            TextButton(
                onPressed: () async {
                  await addImgProfile(
                      title: 'profileImg', currentUserID: widget.user.uid);
                  Navigator.popUntil(context, ModalRoute.withName("/Réglages"));
                },
                child: Text(
                  'Save',
                  style: TextStyle(color: cGreenConfirm),
                )),
            TextButton(
                onPressed: () {
                  Navigator.popUntil(context, ModalRoute.withName("/Réglages"));
                },
                child: Text(
                  'Leave',
                  style: TextStyle(color: cRedCancel),
                ))
          ]);
        });
  }

  Future alertUpdateProfile(String title, String content) {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialogCustom(context, title, content, [
            TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  'OK',
                  style: TextStyle(color: cGreenConfirm),
                ))
          ]);
        });
  }

  Future alertNotUpdateProfile(String title, String content) {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialogCustom(context, title, content, [
            TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  'OK',
                  style: TextStyle(color: cGreenConfirm),
                ))
          ]);
        });
  }

  Future alreadyImgDelete() {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialogCustom(context, 'Youhou',
              'Tu es au courant que ton icône est déjà supprimé?', [
            TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  'Message reçu',
                  style: TextStyle(color: cGreenConfirm),
                )),
            TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  'Chut d\'abord',
                  style: TextStyle(color: cRedCancel),
                ))
          ]);
        });
  }

  @override
  void initState() {
    super.initState();
    userListener = FirebaseFirestore.instance
        .collection('users')
        .doc(widget.user.uid)
        .snapshots()
        .listen((data) {
      print('change profil');
      setState(() {
        widget.user = UserModel.fromMap(data, data.data()!);
      });
    });
  }

  @override
  void dispose() {
    userListener.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
          elevation: 6,
          backgroundColor: Colors.transparent,
          flexibleSpace: Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.secondary
                ])),
          ),
          leading: IconButton(
              icon: Icon(Icons.arrow_back_ios),
              onPressed: () => {
                    if (_selectedImage != null)
                      {alertSaveBeforeLeave()}
                    else
                      {Navigator.pop(context)}
                  }),
          title: Text('Mon compte'),
          bottom: changePicture()),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          ListTile(
            title: Text('INFORMATIONS DU COMPTE'),
          ),
          TextButton(
              onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (BuildContext context) => EditUserNameScreen(
                            user: widget.user,
                          ))),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Nom d\'utilisateur',
                    style: TextStyle(color: Colors.green),
                  ),
                  Text(
                    widget.user.username,
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.grey),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 12,
                    color: Colors.green,
                  ),
                ],
              )),
          TextButton(
              onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (BuildContext context) => EditEmailScreen(
                            user: widget.user,
                          ))),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('E-mail', style: TextStyle(color: Colors.green)),
                  Text(
                    widget.user.email!,
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.grey),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 12,
                    color: Colors.green,
                  )
                ],
              )),
          TextButton(
              onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (BuildContext context) => EditPasswordScreen())),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Password', style: TextStyle(color: Colors.green)),
                  Text(
                    '**********',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.grey),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 12,
                    color: Colors.green,
                  ),
                ],
              )),
          Divider(),
          ListTile(
            title: Text('GESTION DU COMPTE'),
          ),
          TextButton(
              onPressed: () => print('Supprimer le compte'),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Supprimer le compte',
                  style: TextStyle(color: Colors.red),
                ),
              )),
        ],
      ),
      floatingActionButton: _selectedImage == null
          ? SizedBox()
          : FloatingActionButton(
              onPressed: () => addImgProfile(
                  title: 'profileImg', currentUserID: widget.user.uid),
              backgroundColor: Colors.transparent,
              elevation: 6.0,
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Theme.of(context).colorScheme.primary,
                              Theme.of(context).colorScheme.secondary
                            ])),
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.save,
                      size: 25,
                    ),
                  )
                ],
              )),
    );
  }

  PreferredSize changePicture() {
    return PreferredSize(
        child: Container(
          height: 120,
          width: MediaQuery.of(context).size.width,
          color: Theme.of(context).canvasColor.withOpacity(0.3),
          child: Row(
            children: [
              CircleAvatar(
                  radius: 90,
                  backgroundColor: Colors.transparent,
                  child: ClipOval(
                    child: Container(
                      color: Theme.of(context).canvasColor,
                      height: 90,
                      width: 90,
                      child: _selectedImage == null
                          ? widget.user.imageUrl == null
                              ? Icon(
                                  Icons.person,
                                  size: 55,
                                )
                              : Image.network(widget.user.imageUrl!,
                                  fit: BoxFit.cover)
                          : Image.file(_selectedImage!, fit: BoxFit.cover),
                    ),
                  )),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                      onPressed: () => selectImage(),
                      child: Text(
                        'Modifier l\'icône',
                        style: TextStyle(color: Colors.green),
                      )),
                  TextButton(
                      onPressed: () {
                        if (widget.user.imageUrl != null) {
                          deleteImgProfile(
                              title: 'profileImg',
                              currentUserID: widget.user.uid);
                        } else {
                          alreadyImgDelete();
                          if (_selectedImage != null) {
                            setState(() {
                              _selectedImage = null;
                            });
                          }
                        }
                      },
                      child: Text(
                        'Supprimer l\'icône',
                        style: TextStyle(color: Colors.red),
                      ))
                ],
              )
            ],
          ),
        ),
        preferredSize: Size.fromHeight(120));
  }
}
