import 'package:flutter/material.dart';

class DirectScreen extends StatefulWidget {
  final String uid;

  const DirectScreen({Key? key, required this.uid}) : super(key: key);

  @override
  Directviewstate createState() => Directviewstate();
}

class Directviewstate extends State<DirectScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Center(
      child: Text('Live, événements, compétitions,..'),
    );
  }
}
