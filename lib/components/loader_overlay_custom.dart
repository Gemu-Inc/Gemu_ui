import 'package:flutter/material.dart';
import 'package:flutter_overlay_loader/flutter_overlay_loader.dart';

class LoaderOverlayCustom {
  const LoaderOverlayCustom({Key? key});

  static void showLoader(BuildContext context) {
    Loader.show(context,
        overlayColor: Theme.of(context).brightness == Brightness.dark
            ? Colors.white24
            : Colors.black54,
        progressIndicator: Center(
          child: CircularProgressIndicator(
            color: Theme.of(context).colorScheme.primary,
            strokeWidth: 1.0,
          ),
        ));
  }

  static void hideLoader() {
    Loader.hide();
  }
}
