import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:menta_track/notification_helper.dart';
import 'package:menta_track/theme_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:audioplayers/audioplayers.dart';
import '../generated/l10n.dart';
import '../main.dart';

class SettingData {
  final String name;
  final String theme;
  final String accentColor;
  final bool isDarkMode;
  final bool themeOnlyOnMainPage;

  SettingData(this.name, this.theme, this.isDarkMode, this.themeOnlyOnMainPage, this.accentColor);
}

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => SettingsPageState();
}

class SettingsPageState extends State<SettingsPage> {
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


  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<SettingData> getSettings() async{
    final prefs = await SharedPreferences.getInstance();
    String alertSound = await ThemeHelper().getSound();
    bool isDarkMode = prefs.getBool("darkMode") ?? false;
    bool themeOnlyOnMainPage = prefs.getBool("themeOnlyOnMainPage") ?? false;
    String theme = prefs.getString("theme") ?? "nothing";
    String accentColor = prefs.getString("chosenAccentColor") ?? "blue";
    //List<int> notificationIntervals = prefs.getStringList("notificationIntervals")?.map(int.parse).toList() ?? [15]; //TODO: Aktivieren
    String name = prefs.getString("userName") ?? "";
    return SettingData(name, theme, isDarkMode, themeOnlyOnMainPage, accentColor);
  }

  void _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
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

  void _saveTheme(String value) async {
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

  void _saveSound(String value) async{
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("soundAlert", value);
    _settingsChanged = true;
    final player = AudioPlayer();
    String audioAsset = await ThemeHelper().getSound();
    player.play(AssetSource(audioAsset));
    setState(() {
        _rewardSound = value;
    });

  }

  Future<void> saveNotificationTime(BuildContext context, bool isMorning) async {
    final prefs = await SharedPreferences.getInstance();
    TimeOfDay initialTime = isMorning ? morningTime : eveningTime;
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );
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

  void _saveNotificationIntervals() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList("notificationIntervals", _notificationIntervals.map((e) => e.toString()).toList());
    setState(() {
      _settingsChanged = true;
    });
    _notificationsChanged = true;
  }

  void _addNotification() {
    setState(() {
      _notificationIntervals.add(60);
      _saveNotificationIntervals();
    });
  }

  void _removeNotification(int index) {
    setState(() {
      _notificationIntervals.removeAt(index);
      _saveNotificationIntervals();
    });
  }

  void _updateNotificationInterval(int index, double value) {
    setState(() {
      _notificationIntervals[index] = value.toInt();
      _saveNotificationIntervals();
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
                        _saveTheme(value);
                      }
                    },
                    items: [
                      DropdownMenuItem(value: "nothing", child: Text(S.of(context).settings_themePictures)),
                      DropdownMenuItem(value: "mascot", child: Text("Mascot")),
                      DropdownMenuItem(value: "illustration", child: Text("Illustration")),
                    ],
                  ),
                ),
                ListTile( //TODO: Notwendigkeit überprüfen, evtl in Studie erfragen
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
                        _saveSound(value);
                      }
                    },
                    items: [
                      DropdownMenuItem(value: "standard", child: Text("Standard")),
                      DropdownMenuItem(value: "bell", child: Text("Bell")),
                      DropdownMenuItem(value: "classicGame", child: Text("GameSound")),
                      DropdownMenuItem(value: "longer", child: Text("Longer")),
                      DropdownMenuItem(value: "level", child: Text("Level Completed")),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                ListTile(
                  title: Text(S.of(context).settings_notifications(1),style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),textAlign: TextAlign.center,),
                ),
                ListTile(
                  title: Text(S.of(context).settings_morningNotification),
                  trailing: SizedBox(
                    width: 40,
                    child: Stack(
                        children: [
                          Positioned(
                            right: -12,
                            child:TextButton(
                              onPressed: () => saveNotificationTime(context, true),
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
                    width: 60,
                    child: Stack(
                        children: [
                          Positioned(
                            right: -12,
                            child:TextButton(
                              onPressed: () => saveNotificationTime(context, false),
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
                  title:  Text("Notifications vor Terminen", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),textAlign: TextAlign.center,),
                  subtitle: Column(
                    children: [
                      SizedBox(height: 15,),
                      ListView.builder(
                        shrinkWrap: true,
                        physics:  NeverScrollableScrollPhysics(),
                        itemCount: _notificationIntervals.length,
                        itemBuilder: (context, index) {
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text("${S.of(context).settings_notifications(index)} ${index + 1}:"),
                                        Text("    ${_notificationIntervals[index]}min",textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold),)
                                      ],
                                    ),
                                    Slider(
                                      value: _notificationIntervals[index].toDouble(),
                                      min: 5,
                                      max: 120,
                                      divisions: 23,
                                      label: "${_notificationIntervals[index]} min",
                                      onChanged: (value) => _updateNotificationInterval(index, value),
                                    ),
                                  ],
                                ),
                              ),
                              Align(
                                alignment: Alignment.center ,
                                child:IconButton(
                                  icon: Icon(Icons.remove_circle),
                                  onPressed: () => _removeNotification(index),
                                ) ,
                              ),
                            ],
                          );
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.add),
                        onPressed: _addNotification,
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
