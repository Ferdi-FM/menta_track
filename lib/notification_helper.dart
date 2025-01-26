import 'dart:isolate';
import 'dart:ui';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:menta_track/Pages/day_overview.dart';
import 'package:menta_track/Pages/week_overview.dart';
import 'package:menta_track/main.dart';
import 'package:menta_track/Pages/question_page.dart';
import 'package:menta_track/termin.dart';
import 'package:menta_track/Pages/week_plan_view.dart';

//Edited ExampleCode & Dokumentation von https://pub.dev/packages/awesome_notifications/example

class NotificationHelper{

  NotificationHelper(){
    initializeLocalNotifications();
  }

  Future<void> initializeLocalNotifications() async {
    await AwesomeNotifications().initialize(
        null,
        [
          NotificationChannel(
              channelKey: "termin_Notifications",
              channelName: "Termin Notifications",
              channelDescription: "Channel for Notifications",
              importance: NotificationImportance.High,
              defaultPrivacy: NotificationPrivacy.Private,
              defaultColor: Colors.deepPurple,
              ledColor: Colors.deepPurple)
        ],
        debug: true);
       //await Permission.notification.request(); Alternative permisson funktion, da displayNotificationRationale ursprünglich nicht funktionierte
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
        //print("onActionReceivedMethod was called inside a parallel dart isolate.");
        SendPort? sendPort =
        IsolateNameServer.lookupPortByName("notification_action_port");

        if (sendPort != null) {
          //print("Redirecting the execution to main isolate process.");
          sendPort.send(receivedAction);
          return;
        }
      }
      return onActionReceivedImplementationMethod(receivedAction);
  }

  static Future <void> onDismissActionReceivedMethod(ReceivedAction receivedAction) async {
    print("Dissmissed");
    //TODO: Vielleicht eigene Seite auf der alle unbeantworteten Einträge sind. Oder nur nach hinten verschieben? auf der Tagesübersicht zeigen?

  }

  static Future<void> onActionReceivedImplementationMethod(
      ReceivedAction receivedAction) async {
    String? weekKey = receivedAction.payload?["weekKey"];
    String? timeBegin = receivedAction.payload?["timeBegin"];
    String? terminName = receivedAction.payload?["terminName"];
    String? siteToOpen = receivedAction.payload?["siteToOpen"];
    String? weekDayKey = receivedAction.payload?["weekDayKey"];

    switch(siteToOpen){
      case "WeekPlanView":
        if(weekKey != null){
          MyApp.navigatorKey.currentState?.push(MaterialPageRoute(
            builder: (context) => WeekPlanView(
                weekKey: weekKey),
          ));
        }
        return;
      case "QuestionPage":
        if (weekKey != null && timeBegin != null && terminName != null) {
          MyApp.navigatorKey.currentState?.push(MaterialPageRoute(
            builder: (context) => QuestionPage(
              weekKey: weekKey,
              timeBegin: timeBegin,
              terminName: terminName,
              isEditable: true,
            ),
          ));
        }
        return;
      case "DayOverView":
        if(weekKey != null && weekDayKey != null){
          print("Should open DayOverView");
          MyApp.navigatorKey.currentState?.push(MaterialPageRoute(
            builder: (context) => DayOverviewPage(
                weekKey: weekKey,
                weekDayKey: weekDayKey,),
          ));
        }
        return;
      case "WeekOverView":
        if(weekKey != null) {
          MyApp.navigatorKey.currentState?.push(MaterialPageRoute(
            builder: (context) =>
                WeekOverview(
                    weekKey: weekKey),
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

  Future<bool> displayNotificationRationale() async {
    bool userAuthorized = false;
    BuildContext context = MyApp.navigatorKey.currentContext!;
    await showDialog(
        context: context,
        builder: (BuildContext ctx) {
          return AlertDialog(
            title: Text("Get Notified!",
                style: Theme.of(context).textTheme.titleLarge),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Image.asset(
                        "assets/images/animated-bell.gif",
                        height: MediaQuery.of(context).size.height * 0.3,
                        fit: BoxFit.fitWidth,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Text(
                    "Allow Awesome Notifications to send you beautiful notifications!"),
              ],
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                  },
                  child: Text(
                    "Deny",
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(color: Colors.red),
                  )),
              TextButton(
                  onPressed: () async {
                    userAuthorized = true;
                    Navigator.of(ctx).pop();
                  },
                  child: Text(
                    "Allow",
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(color: Colors.deepPurple),
                  )),
            ],
          );
        });
    return userAuthorized &&
        await AwesomeNotifications().requestPermissionToSendNotifications();
  }

  //Plant die erste Benachrichtigung am Tag
  Future<void> scheduleBeginNotification(List<Termin> termine, String weekKey) async {
    //Check ob Permissions gegeben wurden
    bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
    if (!isAllowed) isAllowed = await displayNotificationRationale();
    if (!isAllowed) return;

    DateTime firstWeekDayMorning = DateTime.parse(weekKey).add(Duration(hours: 7)); //benachrichtigung um 7Uhr morgens
    String testTitle = "";
    String testtestMessage = "";


    //Ich benutze hier nicht die getDayTermine() funktion aus database_helper, weil ich eh für jeden Wochentag die Termine brauche und so nur einmal die Datenbank auslesen muss, wird evtl noch geändert
    for(int i = 0; i < 7;i++){
      List<Termin> termineForThisDay = [];
      DateTime currentDay = firstWeekDayMorning.add(Duration(days: i));
      String title = "Termine am ${DateFormat("dd.MM.yy").format(currentDay)}";
      String message = "Heute stehen folgende Termine an ${Emojis.smile_relieved_face} \n";


      for(Termin termin in termine){
        if(DateFormat("dd.MM.yy").format(currentDay) == DateFormat("dd.MM.yy").format(termin.timeBegin)){
          //print("- ${termin.terminName} um ${DateFormat("HH:mm").format(termin.timeBegin)} \n");
          termineForThisDay.add(termin);
        }
      }

      if(termineForThisDay.isNotEmpty){ //Benachrichtigt nur, wenn es auch einen Termin gibt
        for(Termin t in termineForThisDay){
          message = "$message - ${t.terminName} um <b>${DateFormat("HH:mm").format(t.timeBegin)}<b> \n";
        }
        testtestMessage = message;
        testTitle = title;
      } else {
        //Evtl andere motivierende Nachricht
      }
    }

    print("----------------------REALTEST-----------------------");
    //DateTime triggerTestTime = DateTime(DateTime.now().year,DateTime.now().month,DateTime.now().day, 18);
    DateTime triggerTestTime = DateTime.now().add(Duration(seconds: 5));

    int testHash = triggerTestTime.hashCode;

    print("$testTitle \n $testtestMessage \n Jetzt ist es ${DateTime.now().toString()} und die Notification wird triggern um:  ${triggerTestTime.toString()}");

    //print(triggerTestTime.toString());
    //print("New Hash  ${testHash} ");

    if(!await isNotificationScheduled(testHash)){ //Works
      print("Notification should be scheduled");
      await myNotifyScheduleInHours(
          hashCode: testHash,
          title: "${Emojis.office_tear_off_calendar} $testTitle",
          msg: testtestMessage,
          triggerDateTime: triggerTestTime,
          repeatNotif: false,
          payLoad: {
            "weekKey": weekKey,
            "siteToOpen": "WeekPlanView"
          });
    }else{
      print("$testHash Is already scheduled");
    }
  }

  //Plant die Benachrichtigungen am Ende von den Tagen ein
  Future<void> scheduleEndNotification(String weekKey) async {
    //Check ob Permissions gegeben wurden
    bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
    if (!isAllowed) isAllowed = await displayNotificationRationale();
    if (!isAllowed) return;

    DateTime firstWeekDayEvening = DateTime.parse(weekKey).add(Duration(hours: 22)); //benachrichtigung um 22Uhr Abends/Nachts

    for(int i = 0; i < 7;i++){
      DateTime currentDay = firstWeekDayEvening.add(Duration(days: i));
      String title = "Termin-Übersicht für den ${DateFormat("dd.MM.yy").format(currentDay)}";
      String message = "Heute hast du folgende Termine bewältigt ${Emojis.smile_relieved_face} \n";

      //TODO: - Überlegen, ob eine Nachricht angezeigt werden soll, wenn keine Termine an dem Tag waren
      //TODO: - Überlegen was in die Benachrichtigung soll, da eig erst in dem DayOverView Daten geladen werden sollen, aber muss evtl hier schon ausgeben

      await myNotifyScheduleInHours(
          hashCode: currentDay.hashCode,
          title: title,
          msg: message,
          triggerDateTime: currentDay,
          repeatNotif: false,
          payLoad: {
            "weekKey": weekKey,
            "weekDayKey": DateFormat("dd.MM.yy").format(currentDay), //DayOverView braucht ("dd.MM.yy") format
            "siteToOpen": "DayOverview" //Muss in DayOverView aus der Datenbank laden um aktuelle Daten zu erhalten
          });
    }

    //TODO: add wendofWekkNotification here


    //print("Notification should be scheduled");
  }

  //TODO: Testing
  Future<void> scheduleTestNotification(String weekKey) async {
    //Check ob Permissions gegeben wurden
    bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
    if (!isAllowed) isAllowed = await displayNotificationRationale();
    if (!isAllowed) return;

    DateTime testTime = DateTime.now().add(Duration(seconds: 2)); //benachrichtigung um 22Uhr Abends/Nachts
    DateTime testTerminTime = DateTime.parse(weekKey).add(Duration(hours: 22));
      String title = "Termin-Übersicht für den ${DateFormat("dd.MM.yy").format(testTime)}";
      String message = "Heute hast du folgende Termine bewältigt ${Emojis.smile_relieved_face} \n";

      //TODO: - Überlegen, ob eine Nachricht angezeigt werden soll, wenn keine Termine an dem Tag waren
      //TODO: - Überlegen was in die Benachrichtigung soll, da eig erst in dem DayOverView Daten geladen werden sollen, aber muss evtl hier schon ausgeben

      await myNotifyScheduleInHours(
          hashCode: testTime.hashCode,
          title: title,
          msg: message,
          triggerDateTime: testTime,
          repeatNotif: false,
          payLoad: {
            "weekKey": weekKey,
            "weekDayKey": DateFormat("dd.MM.yy").format(testTerminTime), //DayOverView braucht ("dd.MM.yy") format
            "siteToOpen": "DayOverView" //Muss in DayOverView aus der Datenbank laden um aktuelle Daten zu erhalten
          });
    }
    //print("Notification should be scheduled");


  //Plant die Benachrichtigungen für die einzelnen Termine
  Future<void> scheduleNewTerminNotification(Termin termin, String weekKey) async {
    bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
    if (!isAllowed) isAllowed = await displayNotificationRationale();
    if (!isAllowed) return;

    List<DateTime> times = [
      (termin.timeBegin.subtract(Duration(minutes: 15))), //Benachrichtigung 15 Minuten vor Termin (evtl variabel anpassbar machen)
      (termin.timeBegin),                                 //Benachrichtigung zum Zeitpunkt
      (termin.timeEnd.add(Duration(minutes: 10))),        //Benachrichtigung 10 Minuten nach Termin (evtl zu 15 Minuten nach Terminanfang setzen
    ];
    List<int> hashcodes = [
      termin.timeBegin.subtract(Duration(minutes: 15)).hashCode,
      termin.timeBegin.hashCode,
      termin.timeEnd.add(Duration(minutes: 10)).hashCode
    ];

    for(int i = 0; i < 3;i++){
      bool isAlreadyScheduled = await isNotificationScheduled(hashcodes[i]);
      if(isAlreadyScheduled) {
        print("Notification with Hash: ${hashcodes[i]} is already scheduled"); //Requires testing
      } else {
        await myNotifyScheduleInHours(
            hashCode: hashcodes[i],
            title: termin.terminName,
            msg: "test message",
            triggerDateTime: times[i],
            repeatNotif: false,
            payLoad: {
              "weekKey": weekKey,
              "timeBegin": termin.timeBegin.toString(),
              "terminName": termin.terminName,
              "SiteToOpen": "QuestionPage"
            });
      }
    }
  }
}

Future<void> scheduleEndOfWeekNotification(String weekKey) async {
  //TODO:
}

//Checkt ob schon eine Benachrichtigung geplant ist
Future<bool> isNotificationScheduled(int hashCode) async {
  List<NotificationModel> scheduledNotifications = await AwesomeNotifications().listScheduledNotifications();
  for(NotificationModel n in scheduledNotifications){
    print("Hash already scheduled  ${n.content?.id} ");
  }
  return scheduledNotifications.any((notification) =>
    notification.content?.id == hashCode);
}

//Erstellt die eigentliche Notification
Future<void> myNotifyScheduleInHours({
  required int hashCode,
  required DateTime triggerDateTime,
  required String title,
  required String msg,
  required Map<String, String> payLoad,
  bool repeatNotif = false,
}) async {
  await AwesomeNotifications().createNotification(
    schedule: NotificationCalendar.fromDate(
        date: triggerDateTime,
      allowWhileIdle: true,
      preciseAlarm: true,
    ),
    // schedule: NotificationCalendar.fromDate(
    //    date: DateTime.now().add(const Duration(seconds: 10))),
    content: NotificationContent(
      id: hashCode,
      channelKey: "termin_Notifications",
      title: title,
      body: msg,
      bigPicture: null, //testing
      notificationLayout: NotificationLayout.Inbox,
      actionType : ActionType.Default,
      color: Colors.black,
      backgroundColor: Colors.black,
      // customSound: "resource://raw/notif",
      payload: payLoad,
    ),
    actionButtons: [
      NotificationActionButton(
        key: "NOW",
        label: "btnAct1",
      ),
      NotificationActionButton(
        key: "LATER",
        label: "btnAct2",
      ),
    ],
  );
}