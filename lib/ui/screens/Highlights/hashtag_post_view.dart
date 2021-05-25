import 'package:Gemu/constants/variables.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:Gemu/ui/screens/Home/components/actions_postbar.dart';
import 'package:Gemu/ui/screens/Home/components/content_postdescription.dart';

class HashtagPostView extends StatefulWidget {
  final String? hashtag;
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
            icon: Icon(Icons.arrow_back_ios),
            onPressed: () => Navigator.pop(context)),
        title: ListTile(
          leading: Icon(Icons.tag),
          title: Text(
            widget.hashtag!,
            style: mystyle(15),
          ),
          subtitle: Text('4 publications'),
        ),
      ),
      body: PageView.builder(
          scrollDirection: Axis.vertical,
          controller: _pageController,
          itemCount: widget.snapshot!.data.docs.length,
          itemBuilder: (BuildContext context, int index) {
            DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
                widget.snapshot!.data.docs[index];

            return Stack(
              children: [
                Center(
                  child: Container(
                    decoration: BoxDecoration(
                        image: DecorationImage(
                            image: CachedNetworkImageProvider(
                                documentSnapshot.data()!['pictureUrl']))),
                  ),
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
