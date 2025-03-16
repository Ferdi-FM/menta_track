import 'package:flutter/material.dart';
import 'package:menta_track/notification_helper.dart';
import 'package:menta_track/theme_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:audioplayers/audioplayers.dart';
import '../generated/l10n.dart';
import '../main.dart';

///Einstellungs-Seite

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => SettingsPageState();
}

class SettingsPageState extends State<SettingsPage> {
  ///Variabeln werden zuerst mit Standard-Werten initialisiert
  bool isDarkMode = false;
  String _theme = "nothing";
  String _chosenAccentColor = "blue";
  bool _themeOnlyOnMainPage = false;
  String _rewardSound = "standard";
  bool _settingsChanged = false;
  TimeOfDay morningTime = TimeOfDay(hour: 07, minute: 00);
  TimeOfDay eveningTime = TimeOfDay(hour: 22, minute: 00);
  List<int> _notificationIntervals = [15];
  bool _notificationsChanged = false; //damit nicht jedesmal alles neu geplant wird
  final TextEditingController _nameController = TextEditingController();
  final player = AudioPlayer();
  String audioAsset = "";

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  ///Kann in andern Klassen auf die Settings-Daten zentralisiert zugreifen
  Future<SettingData> getSettings() async{
    final prefs = await SharedPreferences.getInstance();
    bool isDarkMode = prefs.getBool("darkMode") ?? false;
    bool themeOnlyOnMainPage = prefs.getBool("themeOnlyOnMainPage") ?? false;
    String theme = prefs.getString("theme") ?? "nothing";
    String accentColor = prefs.getString("chosenAccentColor") ?? "blue";
    //List<int> notificationIntervals = prefs.getStringList("notificationIntervals")?.map(int.parse).toList() ?? [15];
    String name = prefs.getString("userName") ?? "";
    return SettingData(name, theme, isDarkMode, themeOnlyOnMainPage, accentColor);
  }


  ///Lädt alle Settings aus sharedPreferences
  void _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    audioAsset = await ThemeHelper().getSound(); //Lädt hier da sonst audio verzögerung hat
    setState(() {
      isDarkMode = prefs.getBool("darkMode") ?? false;
      _theme = prefs.getString("theme") ?? "nothing";
      _themeOnlyOnMainPage = prefs.getBool("themeOnlyOnMainPage") ?? false;
      _notificationIntervals = prefs.getStringList("notificationIntervals")?.map(int.parse).toList() ?? [15];
      _nameController.text = prefs.getString("userName") ?? "";
      _chosenAccentColor = prefs.getString("chosenAccentColor") ?? "blue";
      _rewardSound = prefs.getString("soundAlert") ?? "standard";
      int morningMinutes = prefs.getInt("morningTime") ?? 07*60;
      int eveningMinutes = prefs.getInt("eveningTime") ?? 22*60;
      morningTime = TimeOfDay(hour: morningMinutes  ~/ 60, minute:  morningMinutes  % 60) ;
      eveningTime = TimeOfDay(hour: eveningMinutes  ~/ 60, minute:  eveningMinutes  % 60) ;
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
      isDarkMode = val;
      ThemeMode mode = isDarkMode ? ThemeMode.dark : ThemeMode.light;
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

  Future<void> setAccentColor(String  value) async{
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("chosenAccentColor", value);
    _settingsChanged = true;
    setState(() {
         MyApp.of(context).changeColor(value);
        _chosenAccentColor = value;
    });
  }

  void saveSound(String value) async{
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("soundAlert", value);
    _settingsChanged = true;
    audioAsset = await  ThemeHelper().getSound();
    player.stop();
    player.play(AssetSource(audioAsset));
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
    TimeOfDay initialTime = isMorning ? morningTime : eveningTime;
    final TimeOfDay? picked = await pickTime(initialTime);
    if (picked != null) {
      setState(() {
        if (isMorning) {
          morningTime = picked;
        } else {
          eveningTime = picked;
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
      if(_notificationIntervals.length > 1){
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
        ),
        body: SingleChildScrollView(
          child:Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                ListTile(
                  title: const Text("Name", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),textAlign: TextAlign.center,),
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
                const SizedBox(height: 20),
                ListTile(
                    title: Text(S.of(context).settings_theme, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),textAlign: TextAlign.center,)
                ),
                ListTile(
                  title: Text(S.of(context).settings_darkMode),
                  trailing: Switch(
                    value: isDarkMode,
                    onChanged: (value){
                      isDarkMode = isDarkMode;
                      toggleDarkMode(value);
                    }
                    ,
                  ),
                ),
                ListTile(
                  title: Text(S.of(context).settings_theme),
                  trailing: DropdownButton<String>(
                    value: _theme,
                    onChanged: (value) {
                      if (value != null) {
                        saveTheme(value);
                      }
                    },
                    items: [
                      DropdownMenuItem(value: "nothing", child: Text(S.of(context).settings_themePictures)),
                      DropdownMenuItem(value: "mascot", child: Text("Mascot")),
                      DropdownMenuItem(value: "illustration", child: Text("Illustration")),
                    ],
                  ),
                ),
                ListTile(
                  title: Text(S.of(context).settings_themeOnlyMainPage),
                  trailing: Checkbox(
                    value: _themeOnlyOnMainPage,
                    onChanged: (value){
                      _themeOnlyOnMainPage = value!;
                      setThemeCheckbox(_themeOnlyOnMainPage);
                    }),
                ),
                ListTile(
                  title: Text(S.of(context).settings_chooseAccent),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: () => setAccentColor("blue"),
                        child: Container(
                          width: 33,
                          height: 33,
                          margin: EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                            color: Colors.lightBlue,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.black, width: 1),
                          ),
                          child: _chosenAccentColor == "blue"
                              ? Icon(Icons.check, color: Colors.white)
                              : null,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => setAccentColor("orange"),
                        child: Container(
                          width: 33,
                          height: 33,
                          margin: EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                            color: Colors.orange,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.black, width: 1),
                          ),
                          child: _chosenAccentColor == "orange"
                              ? Icon(Icons.check, color: Colors.white)
                              : null,
                        ),
                      ),
                    ],
                  ),
                ),
                ListTile(
                  title: Text("Reward Sounds"),
                  trailing: DropdownButton<String>(
                      value: _rewardSound,
                      onChanged: (value) {
                        if (value != null) {
                          saveSound(value);
                        }
                      },
                      items: [
                        DropdownMenuItem(value: "standard", child: Text("Standard")),
                        DropdownMenuItem(value: "classicGame", child: Text("GameSound")),
                        DropdownMenuItem(value: "longer", child: Text("Longer")),
                        DropdownMenuItem(value: "level-up", child: Text("Level Up")),
                        DropdownMenuItem(value: "level", child: Text("Level End")),
                      ],
                    ),
                  ),
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
                              child: Text(morningTime.format(context), textAlign: TextAlign.right,),
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
                              child: Text(eveningTime.format(context), textAlign: TextAlign.right,),
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
                              border: Border.fromBorderSide(BorderSide(width: 1, color: _chosenAccentColor == "blue" ? Colors.lightBlue : Colors.orange)),
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
                                  child:IconButton(
                                    icon:_notificationIntervals.length > 1 ? Icon(Icons.remove_circle) : SizedBox(), //Immer mindestens eine Benachrichtigung
                                    onPressed: () => removeNotification(index),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.add_alert),
                        onPressed: addNotification,
                      ),
                    ],
                  ),
                ),
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
  final String accentColor;
  final bool isDarkMode;
  final bool themeOnlyOnMainPage;

  SettingData(this.name, this.theme, this.isDarkMode, this.themeOnlyOnMainPage, this.accentColor);
}
