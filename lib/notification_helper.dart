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
import 'generated/l10n.dart';

//Edited ExampleCode & Dokumentation von https://pub.dev/packages/awesome_notifications/example
//Scheduled alle Notifications

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
    bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
    if (!isAllowed) isAllowed = await displayNotificationRationale();
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
    //Hier könnte Logic hinein, wenn eine Benachrichtigung weggeclickt wird
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
              terminName: terminName),
          ));
        }
        return;
      case "DayOverView":
        if(weekKey != null && weekDayKey != null){
          MyApp.navigatorKey.currentState?.push(MaterialPageRoute(
            builder: (context) => DayOverviewPage(
                weekKey: weekKey, //standard DateTime ("yyyy-MM-dd")
                weekDayKey: weekDayKey, //Format("dd.MM.yy")
                fromNotification: true,),
          ));
        }
        return;
      case "WeekOverView":
        if(weekKey != null) {
          MyApp.navigatorKey.currentState?.push(MaterialPageRoute(
            builder: (context) =>
                WeekOverview(
                    weekKey: weekKey,
                    fromNotification: true,),
          ));
        }
        return;
      case "MainPage":
        if(weekKey != null) {
          MyApp.navigatorKey.currentState?.push(MaterialPageRoute(
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

  //Alert für Zustimmung zu Notifiactions
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

  Future<void> loadAllNotifications(bool reload)async { //TODO: Aktivieren
    if(reload) AwesomeNotifications().cancelAll();
    List<Map<String,dynamic>> plansList = await DatabaseHelper().getAllWeekPlans();
    for(var plan in plansList){
      String weekKey = plan["weekKey"];
      List<Termin> terminList = await DatabaseHelper().getWeeklyPlan(weekKey);
      scheduleBeginNotification(terminList, weekKey);
      for(Termin termin in terminList){
        scheduleNewTerminNotification(termin, weekKey);
      }
      scheduleEndNotification(weekKey);
    }
  }

  Future<void> loadNewNotifications(String weekKey)async {
      List<Termin> terminList = await DatabaseHelper().getWeeklyPlan(weekKey);
      scheduleBeginNotification(terminList, weekKey);
      for(Termin termin in terminList){
        scheduleNewTerminNotification(termin, weekKey);
      }
      scheduleEndNotification(weekKey);

  }


  ///Plant die erste Benachrichtigung am Tag
  Future<void> scheduleBeginNotification(List<Termin> termine, String weekKey) async {
    //Check ob Permissions gegeben wurden
    bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
    if (!isAllowed) isAllowed = await displayNotificationRationale();
    if (!isAllowed) return;


    DateTime firstWeekDayMorning = DateTime.parse(weekKey).add(Duration(hours: 7)); //benachrichtigung um 7Uhr morgens, hängt von Implementation von Einstellungen ab
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
          message = "$message - ${t.terminName} ${S.current.um} <b>${S.current.displayATime(t.timeBegin)}<b> \n";
        }
      } else {
        noTasks = true;
        message = S.current.noti_noTasks_message;
      }

      await myNotifyScheduleInHours(
          hashCode: currentDay.hashCode,
          title: "${Emojis.office_tear_off_calendar} $title",
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

    DateTime firstWeekDayEvening = DateTime.parse(weekKey).add(Duration(hours: 22)); //benachrichtigung um 22Uhr Abends/Nachts kann theoretscih durch Einstellungen geändert werden, wenn diese Implementiert werden
    for(int i = 0; i < 7;i++){
      DateTime currentDay = firstWeekDayEvening.add(Duration(days: i));
      String title = S.current.noti_dayEnd_title(currentDay);
      String message = S.current.noti_dayEnd_message;

      //Lieber das der Nutzer auf Nachricht clickt und ansicht in DayOverview bekommt
      //List<Termin> termineForThisDay = await DatabaseHelper().getDayTermine(DateFormat("dd.MM.yy").format(currentDay));
      //if(termineForThisDay.isEmpty){
      //  message= "Heute war nix los, hoffe du hattest trotzdem einen tollen Tag :)";
      //}

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

      ///Plant die Benachrichtigung für die Wochenübersicht
      if(i == 6){
        DateTime lastDuration = currentDay.add(Duration(hours: 1)); //Zeigt Wochenübersicht eine Stunde nach der Tages
        String lastTitle = S.current.noti_weekEnd_title;
        String lastMsg = S.current.noti_weekEnd_message;


        await myNotifyScheduleInHours(
            hashCode: lastDuration.hashCode,
            title: lastTitle,
            msg: lastMsg,
            triggerDateTime: currentDay,
            repeatNotif: false,
            payLoad: {
              "weekKey": weekKey,
              "siteToOpen": "WeekOverview"
            });
      }
    }
  }

  ///Plant die Benachrichtigungen für die einzelnen Termine
  Future<void> scheduleNewTerminNotification(Termin termin, String weekKey) async {
    bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
    if (!isAllowed) isAllowed = await displayNotificationRationale();
    if (!isAllowed) return;

    /*Implementation der Benachrichtigungen TODO: Aktivieren und testen
    SharedPreferences pref = await SharedPreferences.getInstance();
    List<int> notificationTimeList = pref.getStringList("notificationIntervals")?.map(int.parse).toList() ?? [15];
    int numberOfNotifications = notificationTimeList.length+2
    List<DateTime> times = [];
    List<int> hashcodes = [];

    for(int k in notificationTimeList){
      times.add(termin.timeBegin.subtract(Duration(minutes: k))); //Benachrichtigung 15 Minuten vor Termin (evtl variabel anpassbar machen)
      hashcodes.add(termin.timeBegin.subtract(Duration(minutes: k)).hashCode);
    }
    times.add((termin.timeBegin));
    hashcodes.add(termin.timeBegin.hashCode);
    times.add(termin.timeEnd.add(Duration(minutes: 10)));
    hashcodes.add(termin.timeBegin.add(Duration(minutes: 10)).hashCode);

    List<String messages = []
    for(int i = 0; i < notificationTimeList.length; i++){
       messages.add(S.current.noti_termin_messageBefore(termin.terminName, notificationTimeList[i])
    }
    messages.add(S.current.noti_termin_messageAt(termin.terminName));
    messages.add(S.current.noti_termin_messageAfter(termin.terminName));
    */

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

    List<String> messages = [
      S.current.noti_termin_messageBefore(termin.terminName, 15),
      S.current.noti_termin_messageAt(termin.terminName),
      S.current.noti_termin_messageAfter(termin.terminName)
    ];

    for(int i = 0; i < 3;i++){ //numberOfNotifications   i < notificationTimeList.length+2
        await myNotifyScheduleInHours(
            hashCode: hashcodes[i],
            title: termin.terminName,
            msg: messages[i],
            triggerDateTime: times[i],
            repeatNotif: false,
            payLoad: {
              "weekKey": weekKey,
              "timeBegin": termin.timeBegin.toIso8601String(),
              "terminName": termin.terminName,
              "siteToOpen": i == 0 ? "WeekPlanView" : "QuestionPage"  //Nur wenn Termin gestartet oder vorbei ist wird zur QuestionPage geleitet //TODO: i == notificationTimeList.lenth || i == notificationTimeList.lenth+1
            });
      }
  }

  ///TESTING
  Future<void> scheduleTestNotification(String weekKey) async {
    ///Check ob Permissions gegeben wurden
    bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
    if (!isAllowed) isAllowed = await displayNotificationRationale();
    if (!isAllowed) return;

    DateTime testTime = DateTime.now().add(Duration(seconds: 2)); //benachrichtigung um 22Uhr Abends/Nachts
    DateTime testTerminTime = DateTime.parse(weekKey).add(Duration(hours: 22));
    List<Termin> testTerminList = await DatabaseHelper().getWeeklyPlan(weekKey);
    Termin testTermin = testTerminList[0];
    List<Termin> testDayTerminList = await DatabaseHelper().getDayTermine(DateFormat("dd.MM.yy").format(testTermin.timeBegin));

    ///Termin-Notification
    List<DateTime> times = [
      (testTime.add(Duration(seconds: 1))), //Benachrichtigung 15 Minuten vor Termin (evtl variabel anpassbar machen)
      (testTime.add(Duration(seconds: 2))),                                 //Benachrichtigung zum Zeitpunkt
      (testTime.add(Duration(seconds: 3))),        //Benachrichtigung 10 Minuten nach Termin (evtl zu 15 Minuten nach Terminanfang setzen
    ];
    List<int> testhashcodes = [
      testTime.add(Duration(seconds: 1)).hashCode,
      testTime.add(Duration(seconds: 2)).hashCode,
      testTime.add(Duration(seconds: 3)).hashCode
    ];

    List<String> messages = [
      "${testTermin.terminName} steht in 15 Minuten an. \nDu schaffst das!🤞",
      "Es ist soweit für ${testTermin.terminName}!\n Viel Erfolg!🤞",
      "${testTermin.terminName} ist vorbei. \nIch hoffe es hat geklappt \nund dir geholfen 😊\n\n"
      "Bitte klicke auf mich,\nnimm dir eine Minute \nund reflektiere den Termin.\n"
      "Das an sich ist schon eine \ntolle Leistung 🤘",
    ];

    for(int i = 0; i < 3;i++){ //numberOfNotifications
      await myNotifyScheduleInHours(
          hashCode: testhashcodes[i],
          title:"⏱️ ${testTermin.terminName}",
          msg: messages[i],
          triggerDateTime: times[i],
          repeatNotif: false,
          payLoad: {
            "weekKey": weekKey,
            "timeBegin": testTermin.timeBegin.toIso8601String(),
            "terminName": testTermin.terminName,
            "siteToOpen": i == 2 ? "WeekPlanView" : "QuestionPage" //Nur wenn Termin vorbei ist wird zur QuestionPage geleitet
          });
    }

    //Tagesanfang-Notification
    List<Termin> termineForThisDay = [];
    String title1 = "📅 Termine am ${DateFormat("dd.MM").format(testTermin.timeBegin)}";
    String message1 = "Heute stehen folgende Termine an ${Emojis.smile_relieved_face} \n";

    for(Termin termin in testTerminList){
      if(DateFormat("dd.MM.yy").format(termin.timeBegin) == DateFormat("dd.MM.yy").format(termin.timeBegin)){
        termineForThisDay.add(termin);
      }
    }

    if(termineForThisDay.isNotEmpty){ //Benachrichtigt wenn es Termine gibt
      for(Termin t in testDayTerminList){
        message1 = "$message1 - ${t.terminName} um <b>${DateFormat("HH:mm").format(t.timeBegin)}<b> \n";
      }
    } else {
      message1 = "Heute stehen keine Termine an \nalso lehn dich zurück und \nEntspann ein bisschen ${Emojis.smile_smiling_face}";
    }

    await myNotifyScheduleInHours(
        hashCode: testTime.hashCode+3,
        title: title1,
        msg: message1,
        triggerDateTime: testTime,
        repeatNotif: false,
        payLoad: {
          "weekKey": weekKey,
          "siteToOpen": "WeekPlanView"
        });

    //DayÜbersicht
    String title2 = "${Emojis.smile_partying_face} Übersicht für den ${DateFormat("dd.MM.yy").format(testTermin.timeBegin)}";
    String message2 = "Wieder ein Tag vorbei. \n Klicke auf mich um zu sehn \nwas heute so los war ${Emojis.smile_relieved_face} \n";

    if(termineForThisDay.isEmpty){
      message2 = "Heute war nix los, hoffe du hattest trotzdem einen tollen Tag :)";
    }

    await myNotifyScheduleInHours(
        hashCode: testTime.hashCode+4,
        title: title2,
        msg: message2,
        triggerDateTime: testTime,
        repeatNotif: false,
        payLoad: {
          "weekKey": weekKey,
          "weekDayKey": DateFormat("dd.MM.yy").format(testTerminTime), //DayOverView braucht ("dd.MM.yy") format
          "siteToOpen": "DayOverView" //Muss in DayOverView aus der Datenbank laden um aktuelle Daten zu erhalten
        });


    //WeekÜbersicht

    String lastTitle = "Wochenübersicht ${Emojis.activites_confetti_ball}";
    String lastMsg = "Super! Wieder eine Woche geschaft\n Klicke hier um deine Wochenübersicht\n anzeigen zu lassen";
    await myNotifyScheduleInHours(
        hashCode: testTime.hashCode+1,
        title: lastTitle,
        msg: lastMsg,
        triggerDateTime: testTime,
        repeatNotif: false,
        payLoad: {
          "weekKey": weekKey,
          "siteToOpen": "WeekOverView" //Muss in DayOverView aus der Datenbank laden um aktuelle Daten zu erhalten
        });
  }
}

//Checkt ob schon eine Benachrichtigung geplant ist
Future<bool> isNotificationScheduled(int hashCode) async {
  List<NotificationModel> scheduledNotifications = await AwesomeNotifications().listScheduledNotifications();
  //for(NotificationModel n in scheduledNotifications){
  //   //print("Hash already scheduled  ${n.content?.id} ");
  //}
  //Evtl eigenes Array mit hashcodes, anstelle jede einzelne Notification durchzugehen?
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
  NotificationLayout? layout,
  bool repeatNotif = false,
}) async {
  //Checkt ob eine Notification eh schon in der Vergangenheit liegt
  if(DateTime.now().isAfter(triggerDateTime)){ //Scheinbar checkt Awesome_Notification selbst ob eine Benachrichtigung in der vergangenheit liegt, Ich weiß jedoch nicht wo
    print("Already too late for $triggerDateTime");
    return;
  }
  //Checkt ob die Notification mehr als eine Woche entfernt wäre. Checke, weil für jeden Termin 3 Benachrichtigungen + 2 für den Tag + 1 für die Woche generiert wird, wobei schnell sehr viele zusammenkommen können
  if (triggerDateTime.isAfter(DateTime.now().add(Duration(days: 14)))) {
    print("more than a two weeks in the future $triggerDateTime");
    return;
  }

  if(!await isNotificationScheduled(hashCode)){ //Checkt ob Notification schon geschedulet ist
    await AwesomeNotifications().createNotification(
      schedule: NotificationCalendar.fromDate(
        date: triggerDateTime,
        allowWhileIdle: true,
        preciseAlarm: true,
      ),
      content: NotificationContent(
        id: hashCode,
        channelKey: "termin_Notifications",
        title: title,
        body: msg,
        notificationLayout: layout ?? NotificationLayout.Inbox,
        //largeIcon: "asset://assets/images/mascot/Mascot DaumenHoch Transparent.png",
        //bigPicture: "asset://assets/images/mascot/Mascot DaumenHoch Transparent.png",
        actionType : ActionType.Default,
        color: Colors.black,
        backgroundColor: Colors.black,
        // customSound: "resource://raw/notif",
        payload: payLoad,
      ),
    );
  }
}