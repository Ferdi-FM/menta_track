import 'dart:isolate';
import 'dart:ui';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:menta_track/Pages/day_overview.dart';
import 'package:menta_track/Pages/week_overview.dart';
import 'package:menta_track/database_helper.dart';
import 'package:menta_track/main.dart';
import 'package:menta_track/Pages/question_page.dart';
import 'package:menta_track/termin.dart';
import 'package:menta_track/Pages/week_plan_view.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Pages/main_page.dart';
import 'generated/l10n.dart';

//Edited ExampleCode & Dokumentation von https://pub.dev/packages/awesome_notifications/example
//Konfigurieren für IOS, Testen ob permission "<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM"/>" unangemessen viel Akku verbraucht
///Erstellt und scheduled alle Notifications

class NotificationHelper{
  NotificationHelper(){
    initializeLocalNotifications();
  }

  ///Initialisierung
  Future<void> initializeLocalNotifications() async {
    await AwesomeNotifications().initialize(
        "resource://drawable/ic_launcher",
        [
          NotificationChannel(
              channelKey: "termin_Notifications",
              channelName: "Termin Notifications",
              channelDescription: "Channel for Notifications",
              importance: NotificationImportance.Max,
              defaultPrivacy: NotificationPrivacy.Private,
              defaultColor: Colors.deepPurple,
              ledColor: Colors.deepPurple,
              criticalAlerts: true,

          )
        ],
        debug: true);
    bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
    if (!isAllowed) isAllowed = await displayNotificationRationale();
  }

  static ReceivePort? receivePort;
  static Future<void> initializeIsolateReceivePort() async {
    receivePort = ReceivePort("Notification action port in main isolate")
      ..listen(
              (silentData) => onActionReceivedImplementationMethod(silentData));

    // This initialization only happens on main isolate
    IsolateNameServer.registerPortWithName(
        receivePort!.sendPort, "notification_action_port");
  }

  @pragma("vm:entry-point")
  static Future<void> onActionReceivedMethod(
      ReceivedAction receivedAction) async {
      // this process is only necessary when you need to redirect the user
      // to a new page or use a valid context, since parallel isolates do not
      // have valid context, so you need redirect the execution to main isolate
      if (receivePort == null) {
        SendPort? sendPort =
        IsolateNameServer.lookupPortByName("notification_action_port");
        if (sendPort != null) {
          sendPort.send(receivedAction);
          return;
        }
      }
      return onActionReceivedImplementationMethod(receivedAction);
  }

  static Future <void> onDismissActionReceivedMethod(ReceivedAction receivedAction) async {
    //Hier könnte Logic hin, wenn eine Benachrichtigung weggeclickt wird
  }

  ///Nimmt den payload einer Benachrichtigung und leitet dementsprechend zur gewünschten Seite um
  static Future<void> onActionReceivedImplementationMethod(
      ReceivedAction receivedAction) async {
    String? weekKey = receivedAction.payload?["weekKey"];
    String? timeBegin = receivedAction.payload?["timeBegin"];
    String? timeEnd = receivedAction.payload?["timeEnd"];
    String? terminName = receivedAction.payload?["terminName"];
    String? siteToOpen = receivedAction.payload?["siteToOpen"];
    String? weekDayKey = receivedAction.payload?["weekDayKey"];

    switch(siteToOpen){
      case "WeekPlanView":
        if(weekKey != null){
          if(timeBegin != null){
            navigatorKey.currentState?.push(MaterialPageRoute(
              builder: (context) => WeekPlanView(
                  weekKey: weekKey,
                  scrollToSpecificDayAndHour: DateTime.parse(timeBegin),),
            ));
          } else {
            navigatorKey.currentState?.push(MaterialPageRoute(
              builder: (context) => WeekPlanView(
                  weekKey: weekKey),
            ));
          }
          
        }
        return;
      case "QuestionPage":
        if (weekKey != null && timeBegin != null && terminName != null && timeEnd != null) {
          navigatorKey.currentState?.push(MaterialPageRoute(
            builder: (context) => QuestionPage(
              weekKey: weekKey,
              timeBegin: timeBegin,
              timeEnd: timeEnd,
              terminName: terminName,
            ),
          ));
        }
        return;
      case "DayOverView":
        if(weekKey != null && weekDayKey != null){
          navigatorKey.currentState?.push(MaterialPageRoute(
            builder: (context) => DayOverviewPage(
                weekKey: weekKey, //standard DateTime ("yyyy-MM-dd")
                weekDayKey: weekDayKey, //Format("dd.MM.yy")
                fromNotification: true,),
          ));
        }
        return;
      case "WeekOverView":
        if(weekKey != null) {
          navigatorKey.currentState?.push(MaterialPageRoute(
            builder: (context) =>
                WeekOverview(
                    weekKey: weekKey,
                    fromNotification: true,),
          ));
        }
        return;
      case "MainPage":
        if(weekKey != null) {
          navigatorKey.currentState?.push(MaterialPageRoute(
            builder: (context) =>
                MainPage(),
          ));
        }
        return;
    }
  }

  ///  Notifications events are only delivered after call this method
  Future<void> startListeningNotificationEvents() async {
    AwesomeNotifications().setListeners(
        onActionReceivedMethod: onActionReceivedMethod,
        onDismissActionReceivedMethod: onDismissActionReceivedMethod);
  }

  ///Alert für Zustimmung zu Notifiactions
  //passiert bereits automatisch?
  Future<bool> displayNotificationRationale() async {
    return await AwesomeNotifications().requestPermissionToSendNotifications(); //auf manchen Handys wird dannach erstmal ein reines weißes overlay gezeigt, noch nicht rausgefunden wieso
    //navigatorKey.currentState?.pop();
  }

  ///Lädt alle Benachrichtigungen, wenn reload=true werden zurvor alle bereits geplanten abgebrochen (z.B. falls Benachrichtigungszeiten geändert wurden)
  Future<void> loadAllNotifications(bool reload)async {
    if(reload) AwesomeNotifications().cancelAll();
    List<Map<String,dynamic>> plansList = await DatabaseHelper().getAllWeekPlans();
    for(var plan in plansList){
      String weekKey = plan["weekKey"];
      //Check ob gesamte Woche in der Vergangenheit liegt
      if(DateTime.parse(weekKey).add(Duration(days: 7)).difference(DateTime.now()).isNegative){
      }
      //Check ob eine neue Woche mehr als 10 Tage in der Zukunft liegt
      else if(DateTime.parse(weekKey).difference(DateTime.now()) > Duration(days: 10)){
      }else {
        loadNewNotifications(weekKey);
      }
    }
  }

  ///Lädt alle Benachrichtigungen
  Future<void> loadNewNotifications(String weekKey)async {
      List<Termin> terminList = await DatabaseHelper().getWeeklyPlan(weekKey);
      //Benachrichtigungen am Morgen
      scheduleBeginNotification(terminList, weekKey);
      //Benachrichtigungen für einzelene Aktivitäten (mindestens davor, zum Zeitpunkt, dannach)
      for(Termin termin in terminList){
        scheduleNewTerminNotification(termin);
      }
      //Benachrichtigungen am Abend + am Wochenende
      scheduleEndNotification(weekKey);
  }

  ///Plant die erste Benachrichtigung am Tag
  Future<void> scheduleBeginNotification(List<Termin> termine, String weekKey) async {
    //Check ob Permissions gegeben wurden
    bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
    if (!isAllowed) isAllowed = await displayNotificationRationale();
    if (!isAllowed) return;

    final pref = await SharedPreferences.getInstance();
    int timeMorningInMinutes = pref.getInt("morningTime") ?? 7*60;
    TimeOfDay morningTime =  TimeOfDay(hour: timeMorningInMinutes  ~/ 60, minute:  timeMorningInMinutes  % 60) ;


    DateTime firstWeekDayMorning = DateTime.parse(weekKey).add(Duration(hours: morningTime.hour, minutes: morningTime.minute)); //benachrichtigung um 7Uhr morgens, hängt von Implementation von Einstellungen ab
    //Ich benutze hier nicht die getDayTermine() funktion aus database_helper, weil ich eh für jeden Wochentag die Termine brauche und so nur einmal die Datenbank auslesen muss, wird evtl noch geändert
    for(int i = 0; i < 7;i++){
      List<Termin> termineForThisDay = [];
      DateTime currentDay = firstWeekDayMorning.add(Duration(days: i));
      String title = S.current.noti_start_title(currentDay);
      String message = S.current.noti_start_message;
      bool noTasks = false;

      for(Termin termin in termine){
        if(DateFormat("dd.MM.yy").format(currentDay) == DateFormat("dd.MM.yy").format(termin.timeBegin)){
          termineForThisDay.add(termin);
        }
      }

      if(termineForThisDay.isNotEmpty){ //Benachrichtigt wenn es Termine gibt
        for(Termin t in termineForThisDay){
          message = "$message - ${t.terminName} ${S.current.um} <b>${S.current.displayATime(t.timeBegin)}<b><br> \n";
        }
      } else {
        noTasks = true;
        message = S.current.noti_noTasks_message;
      }

      await myNotifyScheduleInHours(
          hashCode: currentDay.hashCode,
          title: title,
          msg: message,
          triggerDateTime: currentDay,
          repeatNotif: false,
          payLoad: {
            "weekKey": weekKey,
            "siteToOpen": noTasks ? "MainPage" : "WeekPlanView"
          }
      );
    }
  }

  ///Plant die Benachrichtigungen am Ende von den Tagen ein
  Future<void> scheduleEndNotification(String weekKey) async {
    //Check ob Permissions gegeben wurden
    bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
    if (!isAllowed) isAllowed = await displayNotificationRationale();
    if (!isAllowed) return;

    final pref = await SharedPreferences.getInstance();
    int timeEveningInMinutes = pref.getInt("eveningTime") ?? 22*60;
    TimeOfDay eveningTime =  TimeOfDay(hour: timeEveningInMinutes  ~/ 60, minute:  timeEveningInMinutes  % 60) ;

    DateTime firstWeekDayEvening = DateTime.parse(weekKey).add(Duration(hours: eveningTime.hour,minutes: eveningTime.minute)); //benachrichtigung um 22Uhr Abends/Nachts kann theoretscih durch Einstellungen geändert werden, wenn diese Implementiert werden
    for(int i = 0; i < 7;i++){
      DateTime currentDay = firstWeekDayEvening.add(Duration(days: i));
      String title = S.current.noti_dayEnd_title(currentDay);
      String message = S.current.noti_dayEnd_message;

      await myNotifyScheduleInHours(
          hashCode: currentDay.hashCode,
          title: title,
          msg: message,
          triggerDateTime: currentDay,
          repeatNotif: false,
          payLoad: {
            "weekKey": weekKey,
            "weekDayKey": DateFormat("dd.MM.yy").format(currentDay), //DayOverView braucht ("dd.MM.yy") format
            "siteToOpen": "DayOverView"
          });

      ///Plant die Benachrichtigung für die Wochenübersicht
      if(i == 6){
        DateTime lastDuration = currentDay.add(Duration(hours: 1)); //Zeigt Wochenübersicht eine Stunde nach der letzen Tages
        String lastTitle = S.current.noti_weekEnd_title;
        String lastMsg = S.current.noti_weekEnd_message;


        await myNotifyScheduleInHours(
            hashCode: lastDuration.hashCode,
            title: lastTitle,
            msg: lastMsg,
            triggerDateTime: lastDuration,
            repeatNotif: false,
            payLoad: {
              "weekKey": weekKey,
              "siteToOpen": "WeekOverView"
            });
      }
    }
  }

  ///Plant die Benachrichtigungen für die einzelnen Termine
  Future<void> scheduleNewTerminNotification(Termin termin) async {
    bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
    if (!isAllowed) isAllowed = await displayNotificationRationale();
    if (!isAllowed) return;

    ///Implementation der Benachrichtigungen
    SharedPreferences pref = await SharedPreferences.getInstance();
    List<int> notificationTimeList = pref.getStringList("notificationIntervals")?.map(int.parse).toList() ?? [15];
    List<DateTime> times = [];
    List<int> hashcodes = [];

    ///Benachrichtigungen aus den Einstellungen
    for(int k in notificationTimeList){
      times.add(termin.timeBegin.subtract(Duration(minutes: k))); //Benachrichtigung variabel anpassbar
      hashcodes.add(termin.timeBegin.subtract(Duration(minutes: k)).hashCode + termin.terminName.hashCode); //time+name für Unique hashcode, wenn zwei Termine/Benachrichtigungen zur selben Zeit sind
    }
    ///Benachrichtigung zum Zeitpunkt
    times.add((termin.timeBegin));
    hashcodes.add(termin.timeBegin.hashCode + termin.terminName.hashCode);
    ///Benachrichtigung nach dem Termin
    times.add(termin.timeEnd.add(Duration(minutes: 10)));
    hashcodes.add(termin.timeEnd.add(Duration(minutes: 10)).hashCode + termin.terminName.hashCode);

    List<String> messages = [];
    ///Benachrichtigungen aus den Einstellungen
    for(int i = 0; i < notificationTimeList.length; i++){
       messages.add(S.current.noti_termin_messageBefore(termin.terminName, notificationTimeList[i]));
    }

    ///Benachrichtigung zum Zeitpunkt
    messages.add(S.current.noti_termin_messageAt(termin.terminName));
    ///Benachrichtigung nach dem Termin
    messages.add(S.current.noti_termin_messageAfter(termin.terminName));

    for(int i = 0; i < notificationTimeList.length+2;i++){ //numberOfNotifications   i < notificationTimeList.length+2
      await myNotifyScheduleInHours(
            hashCode: hashcodes[i],
            title: "📆 ${termin.terminName}",
            msg: messages[i],
            triggerDateTime: times[i],
            repeatNotif: false,
            layout: i == notificationTimeList.length+1 ? NotificationLayout.BigText : NotificationLayout.Inbox ,
            payLoad: {
              "weekKey": termin.weekKey,
              "timeBegin": termin.timeBegin.toIso8601String(),
              "terminName": termin.terminName,
              "timeEnd": termin.timeEnd.toIso8601String(),
              "siteToOpen": i >= notificationTimeList.length ? "QuestionPage" : "WeekPlanView"   //Nur wenn Termin gestartet oder vorbei ist wird zur QuestionPage geleitet
            });
      }
  }

  ///Für Studie und Testen von Benachrichtigungen
  Future<void> scheduleStudyNotification() async {
    //Termin for Notification
    List<Termin> terminList = await DatabaseHelper().getAllTermine();
    Termin termin = terminList[1];
    for(Termin t in terminList){
      if(DateFormat("dd.MM.yy").format(t.timeBegin) == DateFormat("dd.MM.yy").format(DateTime.now())){
        if(t.timeBegin.isBefore(DateTime.now())){
          termin = t;
        }
      }
    }
    String weekKey = termin.weekKey;
    DateTime studyTime = DateTime.now().add(Duration(seconds: 10));
    ///Start 2sec
    final pref = await SharedPreferences.getInstance();

      List<Termin> termineForThisDay = [];
      String title = S.current.noti_start_title(studyTime);
      String message = S.current.noti_start_message;
      bool noTasks = false;

      for(Termin termin in terminList){
        if(DateFormat("dd.MM.yy").format(studyTime) == DateFormat("dd.MM.yy").format(termin.timeBegin)){
          termineForThisDay.add(termin);
        }
      }

      if(termineForThisDay.isNotEmpty){ //Benachrichtigt wenn es Termine gibt
        for(Termin t in termineForThisDay){
          message = "$message - ${t.terminName} ${S.current.um} <b>${S.current.displayATime(t.timeBegin)}<b><br> \n";
        }
      } else {
        noTasks = true;
        message = S.current.noti_noTasks_message;
      }

      await myNotifyScheduleInHours(
          hashCode: studyTime.hashCode,
          title: title,
          msg: message,
          triggerDateTime: studyTime,
          repeatNotif: false,
          payLoad: {
            "weekKey": weekKey,
            "siteToOpen": noTasks ? "MainPage" : "WeekPlanView"
          }
      );
    ///Implementation der Benachrichtigungen
    List<int> notificationTimeList = pref.getStringList("notificationIntervals")?.map(int.parse).toList() ?? [15];
    List<DateTime> times = [];
    List<int> hashcodes = [];

    ///Benachrichtigungen aus den Einstellungen
    for(int k in notificationTimeList){
      times.add(termin.timeBegin.subtract(Duration(minutes: k))); //Benachrichtigung variabel anpassbar
      hashcodes.add(termin.timeBegin.subtract(Duration(minutes: k)).hashCode);
    }
    ///Benachrichtigung zum Zeitpunkt
    times.add((termin.timeBegin));
    hashcodes.add(termin.timeBegin.hashCode);
    ///Benachrichtigung nach dem Termin
    times.add(termin.timeEnd.add(Duration(minutes: 10)));
    hashcodes.add(termin.timeBegin.add(Duration(minutes: 10)).hashCode);

    List<String> messages = [];
    ///Benachrichtigungen aus den Einstellungen
    for(int i = 0; i < notificationTimeList.length; i++){
      messages.add(S.current.noti_termin_messageBefore(termin.terminName, notificationTimeList[i]));
    }

    ///Benachrichtigung zum Zeitpunkt
    messages.add(S.current.noti_termin_messageAt(termin.terminName));
    ///Benachrichtigung nach dem Termin
    messages.add(S.current.noti_termin_messageAfter(termin.terminName));

    for(int i = 0; i < notificationTimeList.length+2;i++){ //numberOfNotifications   i < notificationTimeList.length+2
      await myNotifyScheduleInHours(
          hashCode:studyTime.hashCode+8+i,
          title: "📆 ${termin.terminName}",
          msg: messages[i],
          triggerDateTime: studyTime.add(Duration(seconds: i*2)),
          repeatNotif: false,
          payLoad: {
            "weekKey": weekKey,
            "timeBegin": termin.timeBegin.toIso8601String(),
            "timeEnd": termin.timeEnd.toIso8601String(),
            "terminName": termin.terminName,
            "siteToOpen": i >= notificationTimeList.length ?"QuestionPage" : "WeekPlanView"   //Nur wenn Termin gestartet oder vorbei ist wird zur QuestionPage geleitet
          });
    }
    ///END 5sec
    String title1 = S.current.noti_dayEnd_title(studyTime);
    String message1 = S.current.noti_dayEnd_message;

    //print(currentDay);
    await myNotifyScheduleInHours(
        hashCode: studyTime.hashCode+1,
        title: title1,
        msg: message1,
        triggerDateTime: studyTime.add(Duration(seconds: 5)),
        repeatNotif: false,
        payLoad: {
          "weekKey": weekKey,
          "weekDayKey": DateFormat("dd.MM.yy").format(studyTime), //DayOverView braucht ("dd.MM.yy") format
          "siteToOpen": "DayOverView"
        });

    ///Plant die Benachrichtigung für die Wochenübersicht 60sec

      String lastTitle = S.current.noti_weekEnd_title;
      String lastMsg = S.current.noti_weekEnd_message;


      await myNotifyScheduleInHours(
          hashCode: studyTime.hashCode+2,
          title: lastTitle,
          msg: lastMsg,
          triggerDateTime: studyTime.add(Duration(seconds: 10)),
          repeatNotif: false,
          payLoad: {
            "weekKey": weekKey,
            "siteToOpen": "WeekOverView"
          });
  }



  ///Checkt ob schon eine Benachrichtigung geplant ist
  Future<bool> isNotificationScheduled(int hashCode) async {
    List<NotificationModel> scheduledNotifications = await AwesomeNotifications().listScheduledNotifications();

    return scheduledNotifications.any((notification) =>
      notification.content?.id == hashCode);
  }

  Future<void> unscheduleTerminNotification(String startTime, String endTime, String terminName) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    List<int> notificationTimeList = pref.getStringList("notificationIntervals")?.map(int.parse).toList() ?? [15];
    List<int> hashcodes = [];

    DateTime timeBegin = DateTime.parse(startTime);
    DateTime timeEnd = DateTime.parse(endTime);

    ///Benachrichtigungen aus den Einstellungen
    for(int k in notificationTimeList){
      hashcodes.add(timeBegin.subtract(Duration(minutes: k)).hashCode + terminName.hashCode);
    }
    ///Benachrichtigung zum Zeitpunkt
    hashcodes.add(timeBegin.hashCode + terminName.hashCode);
    ///Benachrichtigung nach dem Termin
    hashcodes.add(timeEnd.add(Duration(minutes: 10)).hashCode + terminName.hashCode);

    for(int hashcode in hashcodes){
      AwesomeNotifications().cancel(hashcode);
    }

  }

  ///Erstellt die eigentliche Notification
  Future<void> myNotifyScheduleInHours({
    required int hashCode,
    required DateTime triggerDateTime,
    required String title,
    required String msg,
    required Map<String, String> payLoad,
    NotificationLayout? layout,
    bool repeatNotif = false,
  }) async {
    ///Checkt ob eine Notification schon in der Vergangenheit liegt
    if(DateTime.now().isAfter(triggerDateTime)){ //Scheinbar checkt Awesome_Notification selbst ob eine Benachrichtigung in der vergangenheit liegt, Ich weiß jedoch nicht wo
      return;
    }
    ///Checkt ob die Notification mehr als eine Woche entfernt wäre. Checke, weil für jeden Termin 3 Benachrichtigungen + 2 für den Tag + 1 für die Woche generiert wird, wobei schnell sehr viele zusammenkommen können
    if (triggerDateTime.isAfter(DateTime.now().add(Duration(days: 8)))) {
      return;
    }
    if(!await isNotificationScheduled(hashCode)){ //Checkt ob Notification schon geschedulet is
      await AwesomeNotifications().createNotification(
        schedule: NotificationCalendar(
          year: triggerDateTime.year,
          month: triggerDateTime.month,
          day: triggerDateTime.day,
          hour: triggerDateTime.hour,
          minute: triggerDateTime.minute,
          second: triggerDateTime.second,
          allowWhileIdle: true,
          preciseAlarm: true,
        ),
        content: NotificationContent(
          id: hashCode,
          channelKey: "termin_Notifications",
          title: title,
          body: msg,
          notificationLayout: layout ?? NotificationLayout.BigText,
          //largeIcon: "resource://assets/images/mascot/Mascot DaumenHoch Transparent.png",
          //bigPicture: "resource://assets/images/mascot/Mascot DaumenHoch Transparent.png",
          actionType : ActionType.Default,
          color: Colors.black,
          backgroundColor: Colors.black,
          // customSound: "resource://raw/notif",
          payload: payLoad,
        ),
      );
    }
  }
  }