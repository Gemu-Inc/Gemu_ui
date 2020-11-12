import 'dart:io';
import 'package:flutter/material.dart';
import 'package:Gemu/components/components.dart';
import 'package:intl/intl.dart';
import 'package:gradient_app_bar/gradient_app_bar.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditProfileScreen extends StatefulWidget {
  EditProfileScreen({Key key}) : super(key: key);

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final FirebaseFirestore db = FirebaseFirestore.instance;
  File _image;
  final picker = ImagePicker();

  Future _imgFromCamera() async {
    final image =
        await picker.getImage(source: ImageSource.camera, imageQuality: 50);

    setState(() {
      if (image != null) {
        _image = File(image.path);
      } else {
        print('No image selected');
      }
    });
  }

  Future _imgFromGallery() async {
    final image =
        await picker.getImage(source: ImageSource.gallery, imageQuality: 50);

    setState(() {
      if (image != null) {
        _image = File(image.path);
      } else {
        print('No image selected');
      }
    });
  }

  void _showPicker(BuildContext context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
            child: Container(
              child: new Wrap(
                children: <Widget>[
                  new ListTile(
                      leading: new Icon(Icons.photo_library),
                      title: new Text('Photo Library'),
                      onTap: () {
                        _imgFromGallery();
                        Navigator.of(context).pop();
                      }),
                  new ListTile(
                    leading: new Icon(Icons.photo_camera),
                    title: new Text('Camera'),
                    onTap: () {
                      _imgFromCamera();
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    Future _savePic(context) async {
      StorageReference ref = FirebaseStorage.instance.ref();
      StorageTaskSnapshot addImg =
          await ref.child("users/profile_img").putFile(_image).onComplete;
      if (addImg.error == null) {
        final String downloadUrl = await addImg.ref.getDownloadURL();
        await FirebaseFirestore.instance
            .collection("users")
            .add({"url": downloadUrl, "name": "profile_img"});
        setState(() {
          print("Profile Picture uploaded");
          Scaffold.of(context).showSnackBar(
              SnackBar(content: Text('Profile Picture Uploaded')));
        });
      } else {
        print('Error from image repo ${addImg.error.toString()}');
      }
    }

    Future _deletePic(context) async {
      await FirebaseFirestore.instance
          .collection("users")
          .where("name", isEqualTo: "profile_img")
          .get()
          .then((res) {
        res.docs.forEach((result) {
          FirebaseStorage.instance
              .getReferenceFromUrl(result.data()["url"])
              .then((res) {
            res.delete().then((res) => print("Deleted"));
          });
        });
      });
    }

    Future getProfileImg() async {
      return db.collection("users").get();
    }

    return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: GradientAppBar(
          leading: IconButton(
              icon: Icon(Icons.arrow_back_ios),
              onPressed: () => Navigator.pop(context)),
          title: Text('Profil'),
          gradient: LinearGradient(
            colors: [
              Theme.of(context).primaryColor,
              Theme.of(context).accentColor
            ],
          ),
        ),
        body: Builder(
          builder: (context) => SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                FutureBuilder(
                    future: ProviderWidget.of(context).auth.getUser(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        return displayUserInformation(context, snapshot);
                      } else {
                        return CircularProgressIndicator();
                      }
                    }),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    RaisedButton(
                      onPressed: () {
                        print('Cancel');
                      },
                      color: Theme.of(context).primaryColor,
                      child: Text("Cancel"),
                    ),
                    RaisedButton(
                        onPressed: () {
                          if (_image != null) {
                            _deletePic(context);
                            //_savePic(context);
                          }
                        },
                        color: Theme.of(context).accentColor,
                        child: Text("Submit")),
                  ],
                )
              ],
            ),
          ),
        ));
  }

  Widget displayUserInformation(context, snapshot) {
    final authData = snapshot.data;

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SizedBox(
          height: 20,
        ),
        Padding(
            padding: EdgeInsets.all(8.0),
            child: GestureDetector(
              onTap: () {
                _showPicker(context);
              },
              child: CircleAvatar(
                radius: 100,
                backgroundColor: Theme.of(context).primaryColor,
                child: ClipOval(
                  child: SizedBox(
                    width: 180.0,
                    height: 180.0,
                    child: _image != null
                        ? Image.file(
                            _image,
                            fit: BoxFit.fitHeight,
                          )
                        : Container(
                            color: Theme.of(context).accentColor,
                            child: Icon(
                              Icons.photo_camera,
                              size: 30,
                              color: Colors.grey,
                            ),
                          ),
                  ),
                ),
              ),
            )),
        Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Username",
                        style:
                            TextStyle(color: Colors.blueGrey, fontSize: 18.0),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "${authData.displayName}",
                        style: TextStyle(fontSize: 18.0),
                      ),
                    )
                  ],
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () {},
                    iconSize: 18.0,
                    color: Colors.blueGrey,
                  ),
                )
              ],
            )),
        Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Email",
                        style:
                            TextStyle(color: Colors.blueGrey, fontSize: 18.0),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "${authData.email}",
                        style: TextStyle(fontSize: 18.0),
                      ),
                    )
                  ],
                ),
              ],
            )),
        Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Created",
                        style:
                            TextStyle(color: Colors.blueGrey, fontSize: 18.0),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "${DateFormat('dd/MM/yyyy').format(authData.metadata.creationTime)}",
                        style: TextStyle(fontSize: 18.0),
                      ),
                    )
                  ],
                ),
              ],
            )),
      ],
    );
  }
}
