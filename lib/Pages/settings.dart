import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:menta_track/helper_utilities.dart';
import 'package:menta_track/notification_helper.dart';
import 'package:menta_track/theme_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:audioplayers/audioplayers.dart';
import '../generated/l10n.dart';
import '../main.dart';

///Einstellungs-Seite
//Color-Picker from: https://pub.dev/packages/flutter_colorpicker

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => SettingsPageState();
}

class SettingsPageState extends State<SettingsPage> {
  ///Variabeln werden zuerst mit Standard-Werten initialisiert
  bool _isDarkMode = false;
  String _theme = "illustration";
  bool _themeOnlyOnMainPage = false;
  bool _hapticFeedback = false;
  String _rewardSound = "standard";
  bool _settingsChanged = false;
  TimeOfDay _morningTime = TimeOfDay(hour: 07, minute: 00);
  TimeOfDay _eveningTime = TimeOfDay(hour: 22, minute: 00);
  List<int> _notificationIntervals = [15];
  bool _notificationsChanged = false; //damit nicht jedesmal alles neu geplant wird
  final TextEditingController _nameController = TextEditingController();
  final _player = AudioPlayer();
  String _audioAsset = "";
  MaterialColor _chosenMaterialColor = Colors.lightBlue;

  @override
  void initState() {
    super.initState();
    _loadSettings();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if(mounted) {
        await Utilities().checkAndShowFirstHelpDialog(context, "Settings");
      }
    });
  }

  ///Kann in andern Klassen auf die Settings-Daten zentralisiert zugreifen
  Future<SettingData> getSettings() async{
    final prefs = await SharedPreferences.getInstance();
    bool isDarkMode = prefs.getBool("darkMode") ?? false;
    bool themeOnlyOnMainPage = prefs.getBool("themeOnlyOnMainPage") ?? false;
    bool hapticFeedBack = prefs.getBool("hapticFeedback") ?? false;
    String theme = prefs.getString("theme") ?? "illustration";
    String name = prefs.getString("userName") ?? "";

    return SettingData(name, theme, isDarkMode, themeOnlyOnMainPage, hapticFeedBack);
  }

  ///Lädt alle Settings aus sharedPreferences
  void _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _audioAsset = await ThemeHelper().getSound(); //Lädt hier da sonst audio verzögerung hat
    _chosenMaterialColor = await HexMaterialColor().getColorFromPreferences();
    setState(() {
      _isDarkMode = prefs.getBool("darkMode") ?? false;
      _theme = prefs.getString("theme") ?? "illustration";
      _themeOnlyOnMainPage = prefs.getBool("themeOnlyOnMainPage") ?? false;
      _hapticFeedback = prefs.getBool("hapticFeedback") ?? false;
      _notificationIntervals = prefs.getStringList("notificationIntervals")?.map(int.parse).toList() ?? [15];
      _nameController.text = prefs.getString("userName") ?? "";
      _rewardSound = prefs.getString("soundAlert") ?? "standard";
      int morningMinutes = prefs.getInt("morningTime") ?? 07*60;
      int eveningMinutes = prefs.getInt("eveningTime") ?? 22*60;
      _morningTime = TimeOfDay(hour: morningMinutes  ~/ 60, minute:  morningMinutes  % 60) ;
      _eveningTime = TimeOfDay(hour: eveningMinutes  ~/ 60, minute:  eveningMinutes  % 60) ;
    });
  }

  Future<void> saveName(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("userName", value);
    _settingsChanged = true;
  }

  Future<void> toggleDarkMode(bool val) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("darkMode", val);
    _settingsChanged = true;
    setState(() {
      _isDarkMode = val;
      ThemeMode mode = _isDarkMode ? ThemeMode.dark : ThemeMode.light;
      MyApp.of(context).changeTheme(mode);
    });
  }

  void saveTheme(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("theme", value);
    _settingsChanged = true;
    setState(() {
      _theme = value;
    });
  }

  Future<void> setThemeCheckbox(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("themeOnlyOnMainPage", value);
    _settingsChanged = true;
    setState(() {
      _themeOnlyOnMainPage = value;
    });
  }

  Future<void> setHapticCheckbox(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("hapticFeedback", value);
    _settingsChanged = true;
    setState(() {
      _hapticFeedback = value;
    });
  }

  Future<bool> getHapticFeedback() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool("hapticFeedback") ?? false;
  }

  void saveSound(String value) async{
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("soundAlert", value);
    _settingsChanged = true;
    _audioAsset = await ThemeHelper().getSound();
    if(_audioAsset != "nothing"){
      _player.stop();
      _player.play(AssetSource(_audioAsset));
    }
    setState(() {
        _rewardSound = value;
    });
  }

  ///Damit context nicht in async ist
  Future<TimeOfDay?> pickTime(TimeOfDay initialTime) {
    return showTimePicker(
      context: context,
      initialTime: initialTime,
    );
  }

  Future<void> saveNotificationTime(bool isMorning) async {
    final prefs = await SharedPreferences.getInstance();
    TimeOfDay initialTime = isMorning ? _morningTime : _eveningTime;
    final TimeOfDay? picked = await pickTime(initialTime);
    if (picked != null) {
      setState(() {
        if (isMorning) {
          _morningTime = picked;
        } else {
          _eveningTime = picked;
        }
      });

      int minutes = picked.hour * 60 + picked.minute;
      await prefs.setInt(isMorning ? "morningTime" : "eveningTime", minutes);
      _settingsChanged = true;
      _notificationsChanged = true;
    }
  }

  void saveNotificationIntervals() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList("notificationIntervals", _notificationIntervals.map((e) => e.toString()).toList());
    setState(() {
      _settingsChanged = true;
    });
    _notificationsChanged = true;
  }

  void addNotification() {
    setState(() {
      _notificationIntervals.add(60);
      saveNotificationIntervals();
    });
  }

  void removeNotification(int index) {
    setState(() {
      if(_notificationIntervals.isNotEmpty){
        _notificationIntervals.removeAt(index);
        saveNotificationIntervals();
      }
    });
  }

  void updateNotificationInterval(int index, double value) {
    setState(() {
      _notificationIntervals[index] = value.toInt();
      saveNotificationIntervals();
    });
  }

  Future showColorPicker(){
    Color pickerColor = Color(0xff443a49);
    MaterialColor? pickerMaterialColor = Colors.lightBlue;

    return showDialog<bool>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(S.current.settings_pickAColor),
          content: SingleChildScrollView(
            child: BlockPicker(
              pickerColor: pickerColor,
              onColorChanged:(color){
                setState(() {
                  pickerColor = color;
                  pickerMaterialColor = color as MaterialColor?;
                  MyApp.of(context).changeColorDynamic(pickerMaterialColor!);
                });
              },
            ),
          ),
          actionsAlignment: MainAxisAlignment.spaceEvenly,
          actions: <Widget>[
            ElevatedButton(
              child:  Text(S.current.cancel),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: Text(S.current.accept),
              onPressed: () {
                setState(() => _chosenMaterialColor = pickerMaterialColor!);
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
        canPop: false, // Ermöglicht das Verlassen der Seite
        onPopInvokedWithResult: (bool didPop, result) {
          if (!didPop) {
            Navigator.pop(context, _settingsChanged);
            if(_notificationsChanged) NotificationHelper().loadAllNotifications(true);
          }
        },
      child: Scaffold(
        appBar: AppBar(
            title:  Text(S.of(context).settings),
            leading: IconButton(
              icon:  Icon(Icons.arrow_back),
              onPressed: () => {
                Navigator.pop(context, _settingsChanged),
                if(_notificationsChanged) NotificationHelper().loadAllNotifications(true),
              },
            ),
          actions: [
            Utilities().getHelpBurgerMenu(context, "Settings"),
          ],
        ),
        body: SingleChildScrollView(
          child:Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              children: [
                ListTile(
                  title: Text(S.current.settings_name_headline, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),textAlign: TextAlign.center,),
                ),
                ListTile(
                  title: TextField(
                    controller: _nameController,
                    decoration: InputDecoration(hintText: S.of(context).settings_name),
                    onChanged: (value){
                      _nameController.text = value;
                      saveName(_nameController.text);
                    },
                  )
                ),
                SizedBox(height: 20),
                ListTile(
                    title: Text(S.of(context).settings_theme, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),textAlign: TextAlign.center,)
                ),
                ///Dark Mode
                Container(
                    color: Theme.of(context).listTileTheme.tileColor,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                      child:  Row(
                        children: [
                          Expanded(
                            flex: 4, 
                            child: Text(S.of(context).settings_darkMode),
                          ),
                          Spacer(flex: 1),
                          Expanded(
                            flex: 2, 
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: Switch(
                                  value: _isDarkMode,
                                  onChanged: (value){
                                    _isDarkMode = _isDarkMode;
                                    toggleDarkMode(value);
                                  }
                              ),
                            ),
                          )
                        ],
                      ),
                    )
                ),
                ///Bilder Thema
                Container(
                    color: Theme.of(context).listTileTheme.tileColor,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                      child:  Row(
                        children: [
                          Expanded(
                            flex: 3, 
                            child: Text(S.current.settings_theme),
                          ),
                          Spacer(flex: 1), 
                          Expanded(
                            flex: 4,
                            child: FittedBox(
                              child: DropdownButton<String>(
                                dropdownColor: Theme.of(context).primaryColorLight,
                                elevation: 6,
                                borderRadius: BorderRadius.circular(10),
                                value: _theme,
                                onChanged: (value) {
                                  if (value != null) {
                                    saveTheme(value);
                                  }
                                },
                                items: [
                                  DropdownMenuItem(value: "nothing", child: AutoSizeText(S.of(context).settings_themePictures)),
                                  DropdownMenuItem(value: "mascot", child: AutoSizeText(S.current.illustration_mascot)),
                                  DropdownMenuItem(value: "illustration", child: AutoSizeText(S.current.illustration_things)),
                                  DropdownMenuItem(value: "illustration v2", child: AutoSizeText(S.current.illustration_people),)
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                    )
                ),
                ///Thema nur auf Hauptseite
                Container(
                    color: Theme.of(context).listTileTheme.tileColor,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                      child:  Row(
                        children: [
                          Expanded(
                            flex: 4, 
                            child: Text(S.of(context).settings_themeOnlyMainPage),
                          ),
                          Spacer(flex: 1), 
                          Expanded(
                            flex: 2, 
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: Checkbox(
                                  value: _themeOnlyOnMainPage,
                                  onChanged: (value){
                                    _themeOnlyOnMainPage = value!;
                                    setThemeCheckbox(_themeOnlyOnMainPage);
                                  }
                              ),
                            ),
                          )
                        ],
                      ),
                    )
                ),
                ///Farbauswahl
                Container(
                    color: Theme.of(context).listTileTheme.tileColor,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                      child:  Row(
                        children: [
                          Expanded(
                            flex: 4, 
                            child: Text(S.of(context).settings_chooseAccent),
                          ),
                          Spacer(flex: 1), 
                          Expanded(
                            flex: 2, 
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                  onPressed: () async{
                                    bool? result = await showColorPicker();
                                    if(result != null){
                                      String test = _chosenMaterialColor.toHexString();
                                      HexMaterialColor().saveToPreferences(test);
                                      if(context.mounted) MyApp.of(context).changeColorDynamic(_chosenMaterialColor);
                                    } else {
                                      if(context.mounted) MyApp.of(context).changeColorDynamic(_chosenMaterialColor);
                                    }
                                  },
                                  child: Icon(Icons.color_lens, size: 32)
                              ),
                            )
                          )
                        ],
                      ),
                    )
                ),
                Container(
                    color: Theme.of(context).listTileTheme.tileColor,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                      child:  Row(
                        children: [
                          Expanded(
                            flex: 3, 
                            child: Text(S.current.rewardSounds),
                          ),
                          Spacer(flex: 1), 
                          Expanded(
                            flex: 4,
                            child: FittedBox(
                              child: DropdownButton<String>(
                                dropdownColor: Theme.of(context).primaryColorLight,
                                elevation: 6,
                                borderRadius: BorderRadius.circular(10),
                                value: _rewardSound,
                                onChanged: (value) {
                                  if (value != null) {
                                    saveSound(value);
                                  }
                                },
                                items: [
                                  DropdownMenuItem(value: "standard", child: Text(S.current.settings_sound_Standard)),
                                  DropdownMenuItem(value: "classicGame", child: Text(S.current.settings_sound_gameSound)),
                                  DropdownMenuItem(value: "longer", child: Text(S.current.settings_sound_longer)),
                                  DropdownMenuItem(value: "level-up", child: Text(S.current.settings_sound_levelUp)),
                                  DropdownMenuItem(value: "level", child: Text(S.current.settings_sound_levelDone)),
                                  DropdownMenuItem(value: "nothing", child: Text(S.current.settings_sound_nothing)),
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                    )
                ),
                Container(
                    color: Theme.of(context).listTileTheme.tileColor,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                      child:  Row(
                        children: [
                          Expanded(
                            flex: 3, 
                            child: Text(S.current.settings_hapticFeedback),
                          ),
                          Spacer(flex: 1), 
                          Expanded(
                            flex: 2, 
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: Checkbox(
                                  value: _hapticFeedback,
                                  onChanged: (value){
                                    _hapticFeedback = value!;
                                    setHapticCheckbox(_hapticFeedback);
                                  }),),
                          )
                        ],
                      ),
                    )
                ),
                ///Notification Einstellungen
                SizedBox(height: 20),
                ListTile(
                  title: Text(S.current.settings_notifications(1),style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),textAlign: TextAlign.center,),
                ),
                ListTile(
                  title: Text(S.of(context).settings_morningNotification),
                  trailing: SizedBox(
                    width: 60,
                    child: Stack(
                        children: [
                          Positioned(
                            right: -10,
                            child:TextButton(
                              onPressed: () => saveNotificationTime(true),
                              child: Text(_morningTime.format(context), textAlign: TextAlign.right,),
                            ),
                          )
                        ]
                    ),
                  ),
                ),
                ListTile(
                  title: Text(S.of(context).settings_eveningNotification),
                  trailing: SizedBox(
                    width: 65,
                    child: Stack(
                        children: [
                          Positioned(
                            right: -10,
                            child:TextButton(
                              onPressed: () => saveNotificationTime(false),
                              child: Text(_eveningTime.format(context), textAlign: TextAlign.right,),
                            ),
                          )
                        ]
                    ),
                  ),
                ),
                ListTile(
                  minTileHeight: 10,
                ),
                ListTile(
                  title:  Text(S.current.settings_notificationsForTasks, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),textAlign: TextAlign.center,),
                  subtitle: Column(
                    children: [
                      SizedBox(height: 15,),
                      ListView.builder(
                        shrinkWrap: true,
                        physics:  NeverScrollableScrollPhysics(),
                        itemCount: _notificationIntervals.length,
                        itemBuilder: (context, index) {
                          return Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              border: Border.fromBorderSide(BorderSide(width: 1, color: _chosenMaterialColor)),
                            ),
                            padding: EdgeInsets.only(top: 10, left: 10, right: 10, bottom: 0),
                            margin: EdgeInsets.symmetric(vertical: 5,horizontal: 0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      FittedBox(
                                        child: Row(
                                          children: [
                                            Text("${S.of(context).settings_notifications(0)} ${index + 1}:", style: TextStyle(fontWeight: FontWeight.bold),),
                                            Text("    ${_notificationIntervals[index]}min",textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold),)
                                          ],
                                        ),
                                      ),
                                      Slider(
                                        value: _notificationIntervals[index].toDouble(),
                                        min: 5,
                                        max: 120,
                                        divisions: 23,
                                        label: "${_notificationIntervals[index]} min",
                                        onChanged: (value) => updateNotificationInterval(index, value),
                                      ),
                                    ],
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.centerRight ,
                                  child: TextButton(
                                    child:Icon(Icons.remove_circle, size: 28,),
                                    onPressed: () => removeNotification(index),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      TextButton(
                        onPressed: addNotification,
                        child: Icon(Icons.add_alert, size: 28,),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20,),
                Text(S.current.settingsSavedAutomatically, textAlign: TextAlign.center,),
                SizedBox(height: 20,),
                Text(S.current.settings_Infos, textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)),
                Text(S.current.settings_Infos_dataProtection)
              ],
            ),
          ),
        ),
      )
    );
  }
}

///Settings-Daten
class SettingData {
  final String name;
  final String theme;
  final bool isDarkMode;
  final bool themeOnlyOnMainPage;
  final bool hapticFeedback;

  SettingData(this.name, this.theme, this.isDarkMode, this.themeOnlyOnMainPage, this.hapticFeedback);
}

class HexMaterialColor {
  HexMaterialColor();

  Future<void> saveToPreferences(String colorHexString) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
   prefs.setString("materialHexCode", colorHexString);
  }


  Future<MaterialColor> getColorFromPreferences() async {
    MaterialColor color = Colors.lightBlue;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String colorHexString = prefs.getString("materialHexCode") ?? "";
    for(MaterialColor c in Colors.primaries){
          if(c.toHexString() == colorHexString){
            color = c;
          }
    }
    return color;
  }
}