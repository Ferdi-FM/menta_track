import 'package:flutter/material.dart';
import 'package:gif_view/gif_view.dart';
import 'package:menta_track/Pages/settings.dart';

import 'generated/l10n.dart';


class GifProgressWidget extends StatefulWidget {
  final double progress; //letzter anzuzeigender frame als prozent zwischen 0.0 und 1.0
  final double startFrame;
  final gifPath = "assets/images/Growing Tree Transparent 30 Frames no transparent Padding.gif";
  final int totalFrames;
  final VoidCallback finished;
  final int? termineForThisDay;
  final bool forRewardPage;

  const GifProgressWidget({
    super.key,
    required this.progress,
    required this.startFrame,
    this.totalFrames = 30,
    required this.finished,
    this.termineForThisDay,
    required this.forRewardPage //unelegant, aber es ist spät...
  });

  @override
  GifProgressWidgetState createState() => GifProgressWidgetState();
}

class GifProgressWidgetState extends State<GifProgressWidget> {
  late GifController _gifController;
  bool finished = false;
  String name = "";

  @override
  void initState() {
    super.initState();
    loadTheme();
    _gifController = GifController();
  }

  Future<void> loadTheme() async {
    SettingData data = await SettingsPageState().getSettings();
    name = data.name;
    name = name == "" ? "" : ", $name"; //Name muss am Satzende kommen
    setState(() {
      name;
    });
  }

  Future<void> _pauseGifAtProgress(int val) async {
    int targetFrame = (widget.progress * (widget.totalFrames - 1)).clamp(0, widget.totalFrames - 1).toInt();
    int startFrame = (widget.startFrame * (widget.totalFrames - 1)).clamp(0, widget.totalFrames - 1).toInt();
    if(startFrame == targetFrame){
      _gifController.seek(targetFrame);
      _gifController.pause();
      if(!finished) widget.finished();
    } else {
      if(_gifController.index == targetFrame){
        _gifController.pause();
        await Future.delayed(Duration(milliseconds: 1500)); //Gif wiederholt sich hierdurch alle 1.5 Sekunden
        _gifController.seek(startFrame);
        _gifController.play();
        if(!finished) widget.finished();
      }
    }
  }

  Text getProgressText(){
    double p = widget.progress;
    String text = "";
    switch(p) {
      case double n when (n < 0.2):
        text = S.of(context).gifProgress_case0(name);
        break;
      case double n when (n < 0.3):
        text = S.of(context).gifProgress_case1(name);
        break;
      case double n when (n < 0.4):
        text = S.of(context).gifProgress_case2(name);
        break;
      case double n when (n < 0.5):
        text = S.of(context).gifProgress_case3(name);
        break;
      case double n when (n < 0.75):
        text =S.of(context).gifProgress_case4(name);
        break;
      case double n when (n < 1.0):
        text = S.of(context).gifProgress_case5(name);
        break;
      case 1.0:
        text = S.of(context).gifProgress_case6(name);
        break;
    }
    return Text(
      text,
      textAlign: TextAlign.center,
    );
  }

  @override
  void dispose() {
    _gifController.dispose();
    super.dispose();
  }

  Widget build1(BuildContext context) {
    return GifView.asset(
      widget.gifPath,
      controller: _gifController,
      frameRate: 5,
      onFrame: _pauseGifAtProgress,
      onStart: () => {
        _gifController.seek((widget.startFrame * (widget.totalFrames - 1)).clamp(0, widget.totalFrames - 1).toInt()),
      },
      height: MediaQuery.of(context).size.height * 0.3,
      width: MediaQuery.of(context).size.height * 0.35,
    );
  }

  @override
  Widget build(BuildContext context){
    return !widget.forRewardPage ? Material(
        elevation: 10,
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            border: Border.fromBorderSide(BorderSide(width: 0.5, color: Colors.black)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.all(15),
                child:  Text(widget.termineForThisDay != null ? S.current.gifProgress_title(widget.termineForThisDay ?? 0) : S.current.gifProgress_title_week, textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
              ),
              GifView.asset(
                widget.gifPath,
                controller: _gifController,
                frameRate: 5,
                onFrame: _pauseGifAtProgress,
                onStart: () => {
                  _gifController.seek((widget.startFrame * (widget.totalFrames - 1)).clamp(0, widget.totalFrames - 1).toInt()),
                },
                height: MediaQuery.of(context).size.height * 0.3,
                width: MediaQuery.of(context).size.height * 0.35,
              ),
              Padding(
                padding: EdgeInsets.all(15),
                child:  getProgressText(),
              ),
            ],
          ),
        )
    ): GifView.asset(
      widget.gifPath,
      controller: _gifController,
      frameRate: 5,
      onFrame: _pauseGifAtProgress,
      onStart: () => {
        _gifController.seek((widget.startFrame * (widget.totalFrames - 1)).clamp(0, widget.totalFrames - 1).toInt()),
      },
      height: MediaQuery.of(context).size.height * 0.3,
      width: MediaQuery.of(context).size.height * 0.35,
    );
  }
}