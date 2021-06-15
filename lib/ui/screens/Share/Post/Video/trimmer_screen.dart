import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_trimmer/video_trimmer.dart';

import 'video_editor_screen.dart';

class TrimmerScreen extends StatefulWidget {
  final Trimmer? trimmer;

  const TrimmerScreen({@required this.trimmer});

  @override
  TrimmerScreenState createState() => TrimmerScreenState();
}

class TrimmerScreenState extends State<TrimmerScreen> {
  double _startValue = 0.0;
  double _endValue = 0.0;

  bool _isPlaying = false;
  bool _progressVisibility = false;

  Future<String> _saveVideo() async {
    setState(() {
      _progressVisibility = true;
    });

    String? _value;

    await widget.trimmer!
        .saveTrimmedVideo(startValue: _startValue, endValue: _endValue)
        .then((value) {
      setState(() {
        _progressVisibility = false;
        _value = value;
      });
    });

    return _value!;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Builder(
        builder: (BuildContext context) {
          return Center(
            child: Container(
              padding: EdgeInsets.only(bottom: 1.0, top: 1.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Visibility(
                      visible: _progressVisibility,
                      child: LinearProgressIndicator(
                        backgroundColor: Colors.red,
                      )),
                  Expanded(
                      child: Stack(
                    children: [
                      VideoViewer(),
                      Align(
                        alignment: Alignment.center,
                        child: GestureDetector(
                          onTap: () async {
                            bool playbackState =
                                await widget.trimmer!.videPlaybackControl(
                              startValue: _startValue,
                              endValue: _endValue,
                            );
                            setState(() {
                              _isPlaying = playbackState;
                            });
                          },
                          child: Container(
                            height: 35,
                            width: 35,
                            decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(color: Colors.black),
                                shape: BoxShape.circle),
                            child: _isPlaying
                                ? Icon(
                                    Icons.pause,
                                    color: Colors.black,
                                  )
                                : Icon(
                                    Icons.play_arrow,
                                    color: Colors.black,
                                  ),
                          ),
                        ),
                      )
                    ],
                  )),
                  Center(
                    child: TrimEditor(
                      viewerHeight: 50.0,
                      viewerWidth: MediaQuery.of(context).size.width,
                      onChangeStart: (value) {
                        _startValue = value;
                      },
                      onChangeEnd: (value) {
                        _endValue = value;
                      },
                      onChangePlaybackState: (value) {
                        setState(() {
                          _isPlaying = value;
                        });
                      },
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: EdgeInsets.all(5.0),
                      child: GestureDetector(
                        onTap: _progressVisibility
                            ? null
                            : () async {
                                _saveVideo().then((path) {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (BuildContext context) =>
                                              VideoEditorScreen(
                                                  file: File(path))));
                                });
                              },
                        child: Container(
                          height: 50,
                          width: 50,
                          decoration: BoxDecoration(
                              gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Theme.of(context).primaryColor,
                                    Theme.of(context).accentColor
                                  ]),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.black)),
                          child: Icon(Icons.video_collection),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          );
        },
      ),
    ));
  }
}
