import 'package:audioplayers/audioplayers.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:menta_track/database_helper.dart';
import 'package:menta_track/theme_helper.dart';
import 'Pages/settings.dart';
import 'generated/l10n.dart';
import 'gif_progress_widget.dart';

///Klasse für den Belohnungs-PopUp- Dialog

class RewardPopUp {

  const RewardPopUp();

  Future<String?> show(BuildContext context, String message, String weekKey, bool gifFromBeginning) {
     return showDialog<String>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black87,
      builder: (context) {
        return _AnimatedRewardPopUp(
          message: message,
          weekKey: weekKey,
          gifBegin : gifFromBeginning, //Weil je nach RewardPopUp für Termin/Tag/Woche soll das gif unterschiedlich beginnen
        );
      },
    );
  }
}

class _AnimatedRewardPopUp extends StatefulWidget {
  final String message;
  final String weekKey;
  final bool gifBegin;
  final bool? fromDayWeekNotification;

  const _AnimatedRewardPopUp({
    required this.message,
    required this.weekKey,
    required this.gifBegin,
    this.fromDayWeekNotification,
  });

  @override
  State<_AnimatedRewardPopUp> createState() => _AnimatedRewardPopUpState();
}

class _AnimatedRewardPopUpState extends State<_AnimatedRewardPopUp> with TickerProviderStateMixin {
  late AnimationController _controller;
  late ConfettiController _confettiController;
  late AnimationController _buttonController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _scaleButtonAnimation;
  Widget illustrationImage = SizedBox();
  String _theme = "nothing";
  bool _showOnlyOnMainPage = false;
  double startFrame = 0;
  double endFrame = 0;
  bool finishedGif = false;

  @override
  void initState() {
    super.initState();
    ///Lädt das Bild-Thema
    _loadTheme();
    ///Lädt die Fortschrittsanzeige
    getProgressForGif();

    //Animation zum öffnen
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    );
    //Animation für den Confirm Button
    _buttonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleButtonAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _buttonController, curve: Curves.easeOut),
    );

    //Animation für Confetti
    _confettiController = ConfettiController(
        duration: const Duration(seconds: 1),);

    SchedulerBinding.instance.addPostFrameCallback((_) {
      _controller.forward();
    });
  }

  ///lädt das Thema
  void _loadTheme() async {
    SettingData data = await SettingsPageState().getSettings();
    illustrationImage = await ThemeHelper().getRewardImage();
    String alertSound = await ThemeHelper().getSound();
    _theme = data.theme;
    _showOnlyOnMainPage = data.themeOnlyOnMainPage;
    if(alertSound != "nothing"){
      final player = AudioPlayer();
      player.play(AssetSource(alertSound));
    }


    setState(() {
      _theme;
      _showOnlyOnMainPage;
      illustrationImage;
    });

  }

  ///Errechnet den start und Endframe für die Baum-Fortschrittsanzeige
  void getProgressForGif() async {
    int totalTasks = await DatabaseHelper().getWeekTermineCount(widget.weekKey,false);
    int doneTasks = await DatabaseHelper().getWeekTermineCountAnswered(widget.weekKey, true);
    setState(() {
      finishedGif = widget.gifBegin;
      !widget.gifBegin ? startFrame = doneTasks/totalTasks : startFrame = 0;
      if(widget.fromDayWeekNotification != null){

        endFrame = (doneTasks)/totalTasks;
      } else {
        endFrame = (doneTasks+1)/totalTasks;
      }

    });
  }


  ///wenn das Gif zum ersten mal fertig animiert hat, wird der Text und Thema angezeigt und GIF nach unten verschoben
  void gifIsFinished(){
      if(mounted && !finishedGif){ //!finishedGif weil gif_progress_widget jeden loop gifIsFinished aufruft
        _confettiController.play();
        setState(() {
          finishedGif = true;
        });
      }
  }

  @override
  void dispose() {
    _controller.dispose();
    _buttonController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  ///Animation für den Button
  void _buttonAnimation() async {
    await _buttonController.forward();
    _buttonController.reverse();
    await Future.delayed(Duration(milliseconds: 120));
    backToPage(); // Seite wechseln
  }

  ///Verlassen des Popups, damit context nicht async ist
  void backToPage() {
    Navigator.of(context).pop("confirmed");
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
        canPop: false, //Nutzer darf nicht über zurück das Pop-Up verlassen (Muss sich loben lassen)
        child: Padding(
          padding: EdgeInsets.only(left: 32,right: 32,bottom: 66,top: 42),
          child: Stack(
            fit: StackFit.expand,
            children: [
              ScaleTransition(
                  scale: _scaleAnimation,
                alignment: Alignment.center, //Alignment(widget.buttonPosition!.dx / MediaQuery.of(context).size.width * 2 - 1, widget.buttonPosition!.dy / MediaQuery.of(context).size.height * 2 - 1),
                  child: Column(
                    children: [
                      SizedBox( //Hat einige Probleme mit Skalierung gemacht, wesegen der Code etwas Kompliziert geworden ist
                        width: MediaQuery.of(context).size.width * 0.8,  // Feste Breite
                        height: MediaQuery.of(context).size.height * 0.7, // Feste Höhe
                      child: Material(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        color: Theme.of(context).listTileTheme.tileColor,
                        elevation: 8,
                        child: ShaderMask(
                            shaderCallback: (Rect rect) {
                              return LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [Theme.of(context).listTileTheme.tileColor as Color, Colors.transparent, Colors.transparent, Theme.of(context).listTileTheme.tileColor as Color],
                                stops: [0.0, 0.1, 0.9, 1.0], // 10% purple, 80% transparent, 10% purple
                              ).createShader(rect);
                            },
                            blendMode: BlendMode.dstOut,
                            child:SingleChildScrollView(
                          child: Column(
                            children: [
                              Padding(
                                padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.1),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    if(!_showOnlyOnMainPage && finishedGif) illustrationImage,
                                    if(finishedGif)SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                                    if(finishedGif)ConstrainedBox(
                                      constraints: BoxConstraints(
                                        maxHeight: MediaQuery.of(context).size.height * 0.35,
                                        minHeight: 40.0,
                                      ),
                                      child: Text(
                                        widget.message,
                                        textAlign: TextAlign.center,
                                        overflow: TextOverflow.visible,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: MediaQuery.of(context).size.width * 0.045,
                                        ),
                                      ),
                                    ),
                                    if(finishedGif)Text(S.of(context).rewardPopUp_scroll,style: TextStyle(fontSize: 10),),
                                    SizedBox(height: MediaQuery.of(context).size.height * 0.04,),
                                    if(endFrame != 0)GifProgressWidget(
                                        progress: endFrame,
                                        startFrame: startFrame,
                                        finished: () => gifIsFinished(),
                                        forRewardPage: true,

                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        )
                      ),
                      ),
                      ),
                      SizedBox(height: 15,),
                      if(finishedGif)ScaleTransition(
                        alignment: Alignment.center,
                        scale: _scaleButtonAnimation,
                        child: SizedBox(  // Use a Container to wrap the ElevatedButton
                          width: double.infinity,  // Make the container take the full width
                          child: ElevatedButton(
                            onPressed: () => {
                              HapticFeedback.lightImpact(),
                              _buttonAnimation(),
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).primaryColor,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
                            ),
                            child: Text(
                              S.of(context).rewardPopUp_conf,
                              style: TextStyle(
                                fontSize: MediaQuery.of(context).size.width * 0.045,
                                fontWeight: FontWeight.w900,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              Align(
                alignment: Alignment.topLeft,
                child: ConfettiWidget(
                  confettiController: _confettiController,
                  blastDirectionality: BlastDirectionality.explosive,
                  emissionFrequency: 0.35,
                  numberOfParticles: 15, // a lot of particles at once
                  gravity: 0.1,
                  shouldLoop: false,
                ),
              ),
              Align(
                alignment: Alignment.topRight,
                child: ConfettiWidget(
                  confettiController: _confettiController,
                  blastDirectionality: BlastDirectionality.explosive,
                  emissionFrequency: 0.35,
                  numberOfParticles: 15, // a lot of particles at once
                  gravity: 0.1,
                  shouldLoop: false,
                ),
              ),
            ],
          ),
        )
    );
  }
}
