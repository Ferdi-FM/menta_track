import 'package:flutter/material.dart';
import 'package:menta_track/database_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Pages/settings.dart';
import 'generated/l10n.dart';

///Klasse für alles was mit dem Thema zu tun hat

class ThemeHelper {
  ThemeHelper();

  ///Gibt das Bild für das Belohnung-PopUp zurück
  Future<Widget> getRewardImage() async {
  SharedPreferences pref = await SharedPreferences.getInstance();
    String? theme = pref.getString("theme") ?? "illustration";
    bool showOnlyOnMainPage = pref.getBool("themeOnlyOnMainPage") ?? false;
    String path = "";
    if (showOnlyOnMainPage) return SizedBox(height: 10);
    switch (theme) {
      case "illustration":
        path = "assets/images/illustrations/illustration reward.png";
        break;
      case "mascot":
        path = "assets/images/mascot/Mascot Cheer Transparent.png";
        break;
      case "illustration v2": //TODO: Implement
        break;
      default:
        path = "";
    }
    return getImageAsset(path);
  }

  Image getImageAsset(String path){
    var image = Image.asset(
      path,
      height: 200,
    );
    return image;
  }

  ///Gibt das Bild für die Startseiten zurück
  Future<Widget> getIllustrationImage(String page) async {
    SettingData data = await SettingsPageState().getSettings();
    int unansweredCount = await DatabaseHelper().getAllTermineCount(false,true);
    String name = data.name;
    String? theme = data.theme;
    bool showOnlyOnMainPage = data.themeOnlyOnMainPage;
    String path = "";
    String title = "";
    String message = "";

    switch (page) {
      case "MainPage":
        title = S.current.home;
        message = S.current.themeHelper_msg0(name);
        switch (theme) {
          case "illustration":
            path = "assets/images/illustrations/flat-design illustration.png";
            break;
          case "mascot":
            path = "assets/images/mascot/Mascot Wochenplan Transparent v2.png";
            break;
          case "illustratv2": //TODO: Implement / Kann einfach um neue bilder erweitert werden
            break;
        }
        break;
      case "OpenPage":
        if (showOnlyOnMainPage) {
          return SizedBox(
            height: 10,
          );
        }
        title = S.current.open;
        message =  "${S.current.themeHelper_open_msg0(name)}${S.current.themeHelper_open_msg1(unansweredCount)}";
        switch (theme) {
          case "illustration":
            path =
                "assets/images/illustrations/flat-design illustration unanswered.png";
            break;
          case "mascot":
            path = "assets/images/mascot/Mascot Klemmbrett Transparent.png";
            break;
          case "illustratv2": //TODO: Implement
            break;
        }
        break;
      default:
        path = "";
    }
    return path.isNotEmpty ? generateElement(path, title, message) : SizedBox(height: 10, width: 10,);
  }

  ///Erzeugt das gesamte Theme-Widget für die Startseiten
  LayoutBuilder generateElement(String path, String title, String message) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double width = constraints.maxWidth; // Maximal verfügbare Breite
        //double height = constraints.maxHeight; // Maximal verfügbare Höhe (= Infinity)
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            SizedBox(
              width: width * 0.03,
            ),
            SizedBox(
              width: width * 0.45,
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 15),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    path,
                    height: width * 0.48,
                  ),
                ),
              ),
            ),
            SizedBox(
              width: width * 0.04,
            ),
            SizedBox(
              width: width * 0.45,
              child: RichText(
                textAlign: TextAlign.left,
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: "$title: \n",
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    TextSpan(text: "\n", style: TextStyle(fontSize: 5)),
                    TextSpan(
                      text: message,
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                        fontSize: 17,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              width: width * 0.03,
            ),
          ],
        );
      },
    );
  }

  ///Holt das Sound-Asset basierend auf den Settings
  Future<String> getSound() async{
    final prefs = await SharedPreferences.getInstance();
    String soundKey = prefs.getString("soundAlert") ?? "";

    switch(soundKey){
      case "level-up":
        return "soundAlerts/level-up-4.mp3"; // Sound Effect by Universfield from Pixabay "https://pixabay.com/sound-effects/level-up-4-243762/"
      case "classicGame":
        return "soundAlerts/classic-game.mp3"; //Sound Effect by floraphonic from Pixabay "https://pixabay.com/sound-effects/classic-game-action-positive-5-224402/"
      case "longer":
        return "soundAlerts/collect.mp3"; //Sound Effect by freesound_community from Pixabay "https://pixabay.com/de/sound-effects/collect-5930/"
      case "level":
        return "soundAlerts/level-complete.wav"; //https://mixkit.co/free-sound-effects/discover/
      case"standard":
        return "soundAlerts/glockenspiel.mp3"; //Sound Effect by freesound_community from Pixabay "https://pixabay.com/sound-effects/short-success-sound-glockenspiel-treasure-video-game-6346/"
      default:
        return "soundAlerts/glockenspiel.mp3";  //Sound Effect by freesound_community from Pixabay "https://pixabay.com/sound-effects/short-success-sound-glockenspiel-treasure-video-game-6346/"
    }
  }
}