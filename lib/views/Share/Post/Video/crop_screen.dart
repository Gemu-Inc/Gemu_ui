//import 'package:flutter/material.dart';
//import 'package:video_editor/video_editor.dart';

/*class CropScreen extends StatefulWidget {
  final VideoEditorController? videoEditorController;

  CropScreen({Key? key, this.videoEditorController}) : super(key: key);

  @override
  Cropviewstate createState() => Cropviewstate();
}

class Cropviewstate extends State<CropScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 10.0),
                    child: GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Icon(
                          Icons.clear,
                          color: Colors.white,
                        )),
                  ),
                  Padding(
                    padding: EdgeInsets.only(right: 10.0),
                    child: GestureDetector(
                        onTap: () {
                          widget.videoEditorController!.updateCrop();
                          Navigator.of(context).pop();
                        },
                        child: Icon(
                          Icons.check,
                          color: Colors.white,
                        )),
                  )
                ],
              ),
              SizedBox(
                height: 15.0,
              ),
              Expanded(
                child: CropGridViewer(
                  controller: widget.videoEditorController!,
                  showGrid: true,
                ),
              ),
            ],
          ),
        ));
  }
}*/
