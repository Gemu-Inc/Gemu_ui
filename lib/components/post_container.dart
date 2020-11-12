import 'package:flutter/material.dart';
import 'package:Gemu/core/models/models.dart';
import 'package:Gemu/components/components.dart';
import 'package:cached_network_image/cached_network_image.dart';

class PostContainer extends StatelessWidget {
  final Post post;

  const PostContainer({Key key, @required this.post}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
        margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 5.0),
        elevation: 0.0,
        child: post.imageUrl != null
            ? Card(
                elevation: 0.0,
                color: Colors.transparent,
                child: Column(
                  children: [
                    Stack(
                      children: [
                        CachedNetworkImage(
                          imageUrl: post.imageUrl,
                        ),
                        Card(
                          elevation: 0.0,
                          color: Colors.transparent,
                          child: _PostHeader(post: post),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                            padding: EdgeInsets.symmetric(vertical: 6.0),
                            child: Text(post.caption)),
                        Card(
                            child: Container(
                          height: 45,
                          child: _PostStats(post: post),
                        )),
                      ],
                    ),
                  ],
                ))
            : post.videoUrl != null
                ? Card(
                    elevation: 0.0,
                    color: Colors.transparent,
                    child: Column(
                      children: [
                        Stack(
                          children: [
                            VideoPlayerScreen(videoUrl: post.videoUrl),
                            Card(
                              elevation: 0.0,
                              color: Colors.transparent,
                              child: _PostHeader(post: post),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Padding(
                                padding: EdgeInsets.symmetric(vertical: 6.0),
                                child: Text(post.caption)),
                            Card(
                                child: Container(
                              height: 45,
                              child: _PostStats(post: post),
                            )),
                          ],
                        ),
                      ],
                    ))
                : Card(
                    color: Colors.transparent,
                    elevation: 0.0,
                    child: Stack(
                      children: [
                        Column(
                          children: [
                            Card(
                              elevation: 0.0,
                              color: Colors.transparent,
                              child: _PostHeader(post: post),
                            ),
                            Card(
                                elevation: 0.0,
                                color: Colors.transparent,
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Text(post.caption),
                                  ],
                                )),
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 5.0),
                              child: Card(
                                  child: Container(
                                height: 45,
                                child: _PostStats(post: post),
                              )),
                            )
                          ],
                        )
                      ],
                    )));
  }
}

class _PostHeader extends StatelessWidget {
  final Post post;

  const _PostHeader({
    Key key,
    @required this.post,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ProfileAvatar(imageUrl: post.user.imageProfil),
        const SizedBox(width: 8.0),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                post.user.name,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${post.timeAgo}',
                style: TextStyle(
                  fontSize: 12.0,
                ),
              ),
            ],
          ),
        ),
        FlatButton(
            onPressed: () => print('Suivre'),
            child: Text('Suivre',
                style: TextStyle(color: Theme.of(context).primaryColor))),
        IconButton(
          icon: const Icon(Icons.more_horiz),
          onPressed: () => print('More'),
        ),
      ],
    );
  }
}

class _PostStats extends StatelessWidget {
  final Post post;

  const _PostStats({
    Key key,
    @required this.post,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Row(
          children: [
            _PostButton(
              icon: Icon(
                Icons.keyboard_arrow_up,
                size: 35.0,
                color: Colors.green,
              ),
              label: 'UP',
              onTap: () => print('Up'),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 6.0),
              child: Text(
                '${post.likes}',
                style: TextStyle(fontSize: 15),
              ),
            ),
            _PostButton(
              icon: Icon(
                Icons.keyboard_arrow_down,
                size: 35.0,
                color: Colors.red,
              ),
              label: 'DOWN',
              onTap: () => print('Down'),
            ),
          ],
        ),
        Row(
          children: [
            _PostButton(
              icon: Icon(
                Icons.add_comment,
                size: 35.0,
                color: Theme.of(context).primaryColor,
              ),
              label: 'COMMENT',
              onTap: () => print('Comment'),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 6.0),
              child: Text(
                '${post.comments}',
                style: TextStyle(fontSize: 15),
              ),
            ),
          ],
        ),
        _PostButton(
          icon: Icon(
            Icons.screen_share,
            size: 35.0,
            color: Theme.of(context).primaryColor,
          ),
          label: 'Share',
          onTap: () => print('Share'),
        )
      ],
    );
  }
}

class _PostButton extends StatelessWidget {
  final Icon icon;
  final String label;
  final Function onTap;

  const _PostButton({
    Key key,
    @required this.icon,
    @required this.label,
    @required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          height: 25.0,
          child: icon,
        ),
      ),
    );
  }
}
