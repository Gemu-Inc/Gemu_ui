import 'package:flutter/material.dart';
import 'package:gemu/constants/constants.dart';
import 'package:loader/loader.dart';

class LoaderDataCustom extends StatelessWidget {
  final Widget widgetLoading;
  final Widget widgetLoad;
  final Future<bool> loadingData;

  const LoaderDataCustom(
      {Key? key,
      required this.widgetLoading,
      required this.widgetLoad,
      required this.loadingData})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Loader<bool>(
        autoReload: false,
        loadingWidget: widgetLoading,
        load: () {
          return loadingData;
        },
        builder: (_, value) {
          print('value:' + value.toString());
          return widgetLoad;
        },
        errorBuilder: (error) {
          return Center(
            child: Text(
              error,
              style: mystyle(15, Colors.red),
            ),
          );
        });
  }
}
