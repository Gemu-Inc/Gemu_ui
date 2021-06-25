import 'package:Gemu/constants/variables.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:Gemu/ui/screens/Home/components/actions_postbar.dart';
import 'package:Gemu/ui/screens/Home/components/content_postdescription.dart';
import 'package:Gemu/ui/screens/Home/components/picture_item.dart';
import 'package:Gemu/ui/screens/Home/components/video_player_item.dart';

class HashtagPostView extends StatefulWidget {
  final DocumentSnapshot<Map<String, dynamic>>? hashtag;
  final int? index;
  final AsyncSnapshot? snapshot;

  HashtagPostView({this.hashtag, this.index, this.snapshot});

  @override
  HashtagPostViewState createState() => HashtagPostViewState();
}

class HashtagPostViewState extends State<HashtagPostView> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.index!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
              icon: Icon(
                Icons.arrow_back_ios,
                color: Colors.white,
              ),
              onPressed: () => Navigator.pop(context)),
          title: Container(
            padding: EdgeInsets.only(top: 10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.tag,
                      color: Colors.white,
                    ),
                    Text(
                      widget.hashtag!.data()!['name'],
                      style: TextStyle(color: Colors.white),
                    )
                  ],
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 25.0),
                  child: Text(
                    '${widget.hashtag!.data()!['postsCount']} publications',
                    style: mystyle(11),
                  ),
                )
              ],
            ),
          )),
      body: PageView.builder(
          scrollDirection: Axis.vertical,
          controller: _pageController,
          itemCount: widget.snapshot!.data.docs.length,
          itemBuilder: (BuildContext context, int index) {
            DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
                widget.snapshot!.data.docs[index];

            return Stack(
              children: [
                documentSnapshot.data()!['pictureUrl'] != null
                    ? PictureItem(
                        idUser: documentSnapshot.data()!['uid'],
                        idPost: documentSnapshot.data()!['id'],
                        pictureUrl: documentSnapshot.data()!['pictureUrl'],
                      )
                    : VideoPlayerItem(
                        idUser: documentSnapshot.data()!['uid'],
                        idPost: documentSnapshot.data()!['id'],
                        videoUrl: documentSnapshot.data()!['videoUrl'],
                      ),
                Positioned(
                    bottom: 30,
                    left: 0,
                    child: ContentPostDescription(
                      idUser: documentSnapshot.data()!['uid'],
                      username: documentSnapshot.data()!['username'],
                      caption: documentSnapshot.data()!['caption'],
                      hashtags: documentSnapshot.data()!['hashtags'],
                    )),
                Positioned(
                    bottom: 30,
                    right: 0,
                    child: ActionsPostBar(
                      idUser: documentSnapshot.data()!['uid'],
                      idPost: documentSnapshot.data()!['id'],
                      profilPicture: documentSnapshot.data()!['profilepicture'],
                      commentsCounts:
                          documentSnapshot.data()!['commentcount'].toString(),
                      up: documentSnapshot.data()!['up'],
                      down: documentSnapshot.data()!['down'],
                    ))
              ],
            );
          }),
    );
  }
}
