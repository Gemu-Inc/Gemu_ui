import 'package:meta/meta.dart';
import 'package:Gemu/core/models/models.dart';

class Post {
  final UserLogin user;
  final String caption;
  final String timeAgo;
  final String imageUrl;
  final String videoUrl;
  final int likes;
  final int comments;
  final int shares;

  const Post({
    @required this.user,
    @required this.caption,
    @required this.timeAgo,
    @required this.imageUrl,
    @required this.videoUrl,
    @required this.likes,
    @required this.comments,
    @required this.shares,
  });
}
