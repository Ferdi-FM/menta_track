import 'package:flutter/material.dart';
import 'package:gif_view/gif_view.dart';
import 'package:menta_track/Pages/settings.dart';
import 'generated/l10n.dart';

///Erstellt und passt das Baum-Fortschritts-Widget an

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
    required this.forRewardPage
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
    if(widget.progress == 0) widget.finished;
  }

  ///Lädt Theme-Daten
  Future<void> loadTheme() async {
    SettingData data = await SettingsPageState().getSettings();
    name = data.name;
    name = name == "" ? "" : ", $name"; //Name muss am Satzende kommen
    setState(() {
      name;
    });
  }

  ///Definiert die Range und den Loop für Das Gif
  Future<void> _pauseGifAtProgress(int val) async {
    int targetFrame = (widget.progress * (widget.totalFrames - 1)).clamp(0, widget.totalFrames - 1).toInt();
    int startFrame = (widget.startFrame * (widget.totalFrames - 1)).clamp(0, widget.totalFrames - 1).toInt();

    if(startFrame == targetFrame){
      _gifController.seek(targetFrame);
      _gifController.pause();
      if(!finished || targetFrame == 0) widget.finished();
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

  ///Erstellt den Text des Widgets basierend auf den Fortschritt
  Text getProgressText(){
    double p = widget.progress;
    String text = "";
    switch(p) {
      case double n when (n < 0.25):
        text = S.of(context).gifProgress_case0(name);
        break;
      case double n when (n < 0.33):
        text = S.of(context).gifProgress_case1(name);
        break;
      case double n when (n < 0.5):
        text = S.of(context).gifProgress_case2(name);
        break;
      case double n when (n < 0.6):
        text = S.of(context).gifProgress_case3(name);
        break;
      case double n when (n < 0.8):
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

  @override
  Widget build(BuildContext context){
    return !widget.forRewardPage ? Material( //Eventuell forRewardpage entfernen
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
    ): Column( ///Für die Belohnungsseite, da es mit Material nicht so gut aussah
      children: [
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
    );
  }
}