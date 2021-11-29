import 'package:flutter/material.dart';
import 'package:gemu/ui/constants/constants.dart';
import 'package:loader/loader.dart';

class LoaderDataCustom extends StatelessWidget {
  final Widget widgetLoading;
  final Function loadingData;

  const LoaderDataCustom(
      {Key? key, required this.widgetLoading, required this.loadingData})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Loader<bool>(
        loadingWidget: Center(
          child: CircularProgressIndicator(
            color: Theme.of(context).primaryColor,
            strokeWidth: 1.5,
          ),
        ),
        load: () async {
          return await loadingData();
        },
        builder: (_, value) {
          return widgetLoading;
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
