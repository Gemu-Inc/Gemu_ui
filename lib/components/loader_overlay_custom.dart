import 'package:flutter/material.dart';
import 'package:flutter_overlay_loader/flutter_overlay_loader.dart';

class LoaderOverlayCustom {
  final Widget widgetProgressIndicator;

  const LoaderOverlayCustom({required this.widgetProgressIndicator});

  void showLoader(BuildContext context) {
    Loader.show(context,
        overlayColor: Colors.black38.withOpacity(0.5),
        progressIndicator: Center(
          child: widgetProgressIndicator,
        ));
  }

  void dispose() {
    Loader.hide();
  }
}
