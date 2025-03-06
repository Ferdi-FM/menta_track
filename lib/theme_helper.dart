import 'package:flutter/material.dart';
import 'package:menta_track/database_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Pages/settings.dart';
import 'generated/l10n.dart';

class ThemeHelper {
  ThemeHelper();

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
          case "illustratv2": //TODO: Implement
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

  Future<String> getSound() async{
    final prefs = await SharedPreferences.getInstance();
    String soundKey = prefs.getString("soundAlert") ?? "";
    //DropdownMenuItem(value: "standard", child: Text("Standard")),
    //                       DropdownMenuItem(value: "bell", child: Text("Bell")),
    //                       DropdownMenuItem(value: "classicGame", child: Text("GameSound")),
    //                       DropdownMenuItem(value: "longer", child: Text("Longer")),
    //                       DropdownMenuItem(value: "level", child: Text("Level Completed")),

    switch(soundKey){
      case "bell":
        return "soundAlerts/happy-bell.wav";
      case "classicGame":
        return "soundAlerts/classic-game.mp3";
      case "longer":
        return "soundAlerts/collect.mp3";
      case "level":
        return "soundAlerts/level-complete.wav";
      case"standard":
        return "soundAlerts/glockenspiel.mp3";
      default:
        return "soundAlerts/glockenspiel.mp3";
    }
  }

}

/*Alternative: Future<Widget> getMainPageImage(String path) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String? theme = pref.getString("theme") ?? "illustration";


    String title = "Startseite";
    String message = "Hier findest du eine Auflistung all deiner Wochenpläne ${Emojis.smile_smiling_face}";
    switch (theme) {
      case "illustration":
        return generateElement("assets/images/illustrations/flat-design illustration.png", title, message);
      case "mascot":
        return generateElement( "assets/images/mascot/Mascot Wochenplan Transparent v2.png", title, message);
      case "nothing":
        return SizedBox(height: 0);
      default:
        return SizedBox();
    }
  }

  Future<Widget> getOpenImage() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String? theme = pref.getString("theme") ?? "illustration";

    String title = "Offen";
    String message = "Hier findest du offene Einträge";
    switch (theme) {
      case "illustration":
        return generateElement("assets/images/illustrations/flat-design illustration 2.png", title, message);
      case "mascot":
        return generateElement( "assets/images/mascot/Mascot Wochenplan Transparent v2.png", title, message);
      case "nothing":
        return SizedBox(height: 0);
      default:
        return SizedBox();
    }
  }*/
