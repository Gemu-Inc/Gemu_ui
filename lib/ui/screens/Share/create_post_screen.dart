import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:Gemu/screensmodels/Share/create_post_model.dart';

class CreatePostScreen extends StatefulWidget {
  CreatePostScreen({Key key}) : super(key: key);

  @override
  _CreatePostScreenState createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<CreatePostModel>.reactive(
        viewModelBuilder: () => CreatePostModel(),
        builder: (context, model, child) => Scaffold(
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: IconButton(
                    icon: Icon(
                      Icons.clear,
                      size: 30,
                    ),
                    onPressed: () => Navigator.pop(context)),
              ),
            ));
  }
}
