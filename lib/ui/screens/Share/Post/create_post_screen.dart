import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:Gemu/constants/variables.dart';
import 'confirmation_screen.dart';

class AddVideoScreen extends StatefulWidget {
  @override
  AddVideoScreenState createState() => AddVideoScreenState();
}

class AddVideoScreenState extends State<AddVideoScreen> {
  pickVideo(ImageSource src) async {
    final video = await ImagePicker().getVideo(source: src);
    if (video != null) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ConfirmationScreen(
                    file: File(video.path),
                    path: video.path,
                    imageSource: src,
                  )));
    }
  }

  pickImage(ImageSource src) async {
    final image = await ImagePicker().getImage(source: src);
  }

  showOptionsVideo() {
    return showModalBottomSheet(
        context: context,
        builder: (context) {
          return Container(
            height: 175,
            color: Theme.of(context).canvasColor,
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                ListTile(
                  onTap: () => pickVideo(ImageSource.camera),
                  leading: Icon(Icons.photo_camera),
                  title: Text('Camera'),
                ),
                ListTile(
                  onTap: () => pickVideo(ImageSource.gallery),
                  leading: Icon(Icons.photo),
                  title: Text('Gallery'),
                ),
                ListTile(
                  onTap: () => Navigator.pop(context),
                  leading: Icon(Icons.clear),
                  title: Text('Cancel'),
                )
              ],
            ),
          );
        });
  }

  showOptionsImage() {
    return showModalBottomSheet(
        context: context,
        builder: (context) {
          return Container(
            height: 175,
            color: Theme.of(context).canvasColor,
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                ListTile(
                  onTap: () => pickImage(ImageSource.camera),
                  leading: Icon(Icons.photo_camera),
                  title: Text('Camera'),
                ),
                ListTile(
                  onTap: () => pickImage(ImageSource.gallery),
                  leading: Icon(Icons.photo),
                  title: Text('Gallery'),
                ),
                ListTile(
                  onTap: () => Navigator.pop(context),
                  leading: Icon(Icons.clear),
                  title: Text('Cancel'),
                )
              ],
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
            icon: Icon(Icons.clear), onPressed: () => Navigator.pop(context)),
        title: Text(
          'Create post',
          style: mystyle(18),
        ),
      ),
      body: Column(
        children: [
          Container(
            height: (MediaQuery.of(context).size.height / 2) - 40,
            child: InkWell(
              splashColor: Theme.of(context).accentColor,
              onTap: () => showOptionsVideo(),
              child: Center(
                child: Container(
                  width: MediaQuery.of(context).size.width / 2,
                  height: 50,
                  decoration:
                      BoxDecoration(color: Theme.of(context).primaryColor),
                  child: Center(
                    child: Text(
                      'Add Video',
                      style: mystyle(23),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Container(
            height: (MediaQuery.of(context).size.height / 2) - 40,
            child: InkWell(
              splashColor: Theme.of(context).accentColor,
              onTap: () => showOptionsImage(),
              child: Center(
                child: Container(
                  width: MediaQuery.of(context).size.width / 2,
                  height: 50,
                  decoration:
                      BoxDecoration(color: Theme.of(context).primaryColor),
                  child: Center(
                    child: Text(
                      'Add Image',
                      style: mystyle(23),
                    ),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
