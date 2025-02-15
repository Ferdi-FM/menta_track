import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class RewardPopUp {

  const RewardPopUp();

  void show(BuildContext context, String message, GlobalKey buttonKey, VoidCallback onConfirm) {
    final RenderBox renderBox = buttonKey.currentContext!.findRenderObject() as RenderBox;
    final Offset position = renderBox.localToGlobal(Offset.zero);

    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black87,
      builder: (context) {
        return _AnimatedRewardPopUp(
          message: message,
          buttonPosition: position,
          onConfirm: onConfirm,
        );
      },
    );
  }
}

class _AnimatedRewardPopUp extends StatefulWidget {
  final String message;
  final Offset buttonPosition;
  final VoidCallback onConfirm;

  const _AnimatedRewardPopUp({
    required this.message,
    required this.buttonPosition,
    required this.onConfirm,
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

  @override
  void initState() {
    super.initState();
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
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
    _confettiController.play();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _buttonController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  void _buttonAnimation() async {
    await _buttonController.forward();
    _buttonController.reverse();
    await Future.delayed(Duration(milliseconds: 300));

    //TODO: BaumAnimation hinzufügen?
    backToPage(); // Seite wechseln
  }

  void backToPage() {
    Navigator.of(context).pop(); //Until((route) => route.isFirst);
    widget.onConfirm();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 32,right: 32,bottom: 128,top: 128),
      child: Stack(
        fit: StackFit.expand,
        children: [
          /*GestureDetector( Falls danebenclicken popup Schließen soll
            onTap: () => {
              Navigator.of(context).pop(),
              FocusScope.of(context).unfocus()
            },
            child: Container(
              color: Colors.transparent,
            ),
          ),*/
          ScaleTransition(
              scale: _scaleAnimation,
            alignment: Alignment(widget.buttonPosition.dx / MediaQuery.of(context).size.width * 2 - 1,
                widget.buttonPosition.dy / MediaQuery.of(context).size.height * 2 - 1),
              child: Stack(
                children: [
                  Positioned.fill(
                      bottom: 66,
                      child: Material(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 8,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              widget.message,
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                            ),
                          ],
                        )
                      ),
                  ),
                  const SizedBox(height: 16), // Abstand zwischen Dialog und Button
                  Positioned(
                      bottom: 5,
                      left: 0,
                      right: 0,
                      height: 50,
                      child: ScaleTransition(
                        scale: _scaleButtonAnimation,
                        child: ElevatedButton(
                          onPressed: () => _buttonAnimation(), //backToPage(),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).primaryColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15.0),
                              )),
                          child: const Text("Gut Gemacht! ${Emojis.emotion_beating_heart}", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.black87),),
                        ),
                      ),
                  )

                ],
              ),
            ),

          Align(
            alignment: Alignment.topLeft,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              emissionFrequency: 0.25,
              numberOfParticles: 20, // a lot of particles at once
              gravity: 0.1,
            ),
          ),
          Align(
            alignment: Alignment.topRight,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              emissionFrequency: 0.25,
              numberOfParticles: 20, // a lot of particles at once
              gravity: 0.1,
            ),
          ),
        ],
      ),
    );
    
  }
}
