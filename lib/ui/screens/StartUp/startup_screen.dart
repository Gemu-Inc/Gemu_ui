import 'package:flutter/material.dart';
import 'package:Gemu/screensmodels/StartUp/startup_screen_model.dart';
import 'package:stacked/stacked.dart';

class StartUpScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<StartUpScreenModel>.reactive(
        viewModelBuilder: () => StartUpScreenModel(),
        onModelReady: (model) => model.handleStartUpLogic(),
        builder: (context, model, child) => Scaffold(
              body: Center(
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor:
                      AlwaysStoppedAnimation(Theme.of(context).primaryColor),
                ),
              ),
            ));
  }
}
