import 'package:flutter/material.dart';

class CustomScrollScreen extends StatefulWidget {
  CustomScrollScreen({Key key, @required this.widgets}) : super(key: key);

  final List<Widget> widgets;

  @override
  _CustomScrollScreenState createState() => _CustomScrollScreenState();
}

class _CustomScrollScreenState extends State<CustomScrollScreen> {
  @override
  Widget build(BuildContext context) {
    final List<Widget> widgets = widget.widgets;
    return CustomScrollView(
      physics: BouncingScrollPhysics(),
      slivers: [SliverList(delegate: SliverChildListDelegate(widgets))],
    );
  }
}
