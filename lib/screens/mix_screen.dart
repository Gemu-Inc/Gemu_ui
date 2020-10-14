import 'package:flutter/material.dart';
import 'package:Gemu/widgets/widgets.dart';
import 'package:Gemu/models/models.dart';
import 'package:Gemu/data/data.dart';

class MixScreen extends StatelessWidget {
  const MixScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverList(
            delegate: SliverChildBuilderDelegate(
          (context, index) {
            final Post post = posts[index];
            return PostContainer(post: post);
          },
          childCount: posts.length,
        )),
      ],
    );
  }
}
