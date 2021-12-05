import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as time;

class Helpers {
  static String datePostView(int timestamp) {
    initializeDateFormatting();
    DateTime timePost = DateTime.fromMillisecondsSinceEpoch(timestamp);

    return time.format(timePost);
  }

  static String datePostInfo(int timestamp) {
    initializeDateFormatting();
    DateTime timePost = DateTime.fromMillisecondsSinceEpoch(timestamp);
    DateFormat format;

    format = new DateFormat.yMMMd("fr_FR");

    return format.format(timePost).toString();
  }
}