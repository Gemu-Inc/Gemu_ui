import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:gemu/ui/constants/constants.dart';

import 'Picture/picture_editor_screen.dart';
import 'Video/video_editor_screen.dart';

class AddPostScreen extends StatefulWidget {
  @override
  AddPostviewstate createState() => AddPostviewstate();
}

class AddPostviewstate extends State<AddPostScreen> {
  pickVideo(ImageSource src) async {
    try {
      final video = await ImagePicker()
          .getVideo(source: src, maxDuration: Duration(seconds: 10));
      if (video != null) {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => VideoEditorScreen(file: File(video.path)),
            ));
      } else {
        Navigator.pop(context);
      }
    } catch (e) {
      print(e);
    }
  }

  pickImage(ImageSource src) async {
    try {
      final image = await ImagePicker().getImage(source: src, imageQuality: 50);
      if (image != null) {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => PictureEditorScreen(
                      file: File(image.path),
                    )));
      } else {
        Navigator.pop(context);
      }
    } catch (e) {
      print(e);
    }
  }

  showOptionsVideo() {
    return showModalBottomSheet(
        context: context,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Theme.of(context).canvasColor,
        elevation: 6,
        builder: (context) {
          return Container(
            height: 175,
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Theme.of(context).canvasColor,
        elevation: 6,
        builder: (context) {
          return Container(
            height: 175,
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
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 6,
        leading: IconButton(
            icon: Icon(Icons.clear), onPressed: () => Navigator.pop(context)),
        title: Text(
          'Create post',
          style: mystyle(18),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: InkWell(
              splashColor: Theme.of(context).colorScheme.secondary,
              onTap: () => showOptionsImage(),
              child: Center(
                child: Container(
                  width: MediaQuery.of(context).size.width / 2,
                  height: 50,
                  decoration:
                      BoxDecoration(color: Theme.of(context).primaryColor),
                  child: Center(
                    child: Text(
                      'Add Picture',
                      style: mystyle(23),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: InkWell(
              splashColor: Theme.of(context).colorScheme.secondary,
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
        ],
      ),
    );
  }
}
