import 'package:Gemu/screensmodels/Discover/discover_screen_model.dart';
import 'package:Gemu/ui/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

class DiscoverScreen extends StatelessWidget {
  const DiscoverScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<DiscoverScreenModel>.reactive(
      viewModelBuilder: () => DiscoverScreenModel(),
      builder: (context, model, child) => CustomScrollScreen(widgets: [
        Center(
          child: Container(
            margin: EdgeInsets.only(top: 25.0),
            child: Text("Create your custom feed"),
          ),
        )
      ]),
    );
  }
}
