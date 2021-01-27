import 'package:Gemu/screensmodels/Highlights/highlights_screen_model.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:Gemu/ui/widgets/app_bar_animate.dart';

class HighlightsScreen extends StatefulWidget {
  const HighlightsScreen({Key key}) : super(key: key);

  HighlightsScreenState createState() => HighlightsScreenState();
}

class HighlightsScreenState extends State<HighlightsScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<HighlightScreenModel>.reactive(
        viewModelBuilder: () => HighlightScreenModel(),
        builder: (context, model, child) => Column(
              children: [
                AppBarAnimate(
                  model: model,
                ),
                Center(
                  child: Container(
                    margin: EdgeInsets.only(top: 25.0),
                    child: Text("Create your custom feed"),
                  ),
                )
              ],
            ));
  }
}
