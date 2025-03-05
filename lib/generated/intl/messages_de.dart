// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a de locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'de';

  static String m0(name) =>
      "Der Tag ist noch nicht gekommen 😉 Trotzdem schön, dass du schon mal hier reinschaust ${name} :)";

  static String m1(date) => "${date}";

  static String m2(date) => "${date}";

  static String m3(date) => "${date}";

  static String m4(name) => "Toller Start${name}! Weiter so! 🎉";

  static String m5(name) =>
      "Ein Viertel geschafft${name}! Das machst du fantastisch! 🌟";

  static String m6(name) => "Mehr als ein Drittel geschafft${name}! 💪";

  static String m7(name) => "Halbzeit erreicht! Weiter so ${name}! 🔥";

  static String m8(name) => "Drei Viertel rum ${name}! Fast geschafft! 🌟";

  static String m9(name) =>
      "Fast fertig ${name}! Du hast hart gearbeitet, nur noch ein bisschen mehr! 🚀";

  static String m10(name) => "Gratuliere ${name}! Du hast es geschafft! 🏆🎉";

  static String m11(count) =>
      "${Intl.plural(count, zero: 'Dein Progress bis zu diesem Tag 😇', other: 'Dein Progress an diesem Tag 😇')}";

  static String m12(name) =>
      "Super gemacht, ${name}!\nDu bist echt auf dem richtigen Weg! 🌟";

  static String m13(name) => "Fantastische Arbeit,\n${name}! 💪";

  static String m14(name) => "Großartige Arbeit,\n${name} 🌟";

  static String m15(name) =>
      "Ganz stark, ${name}!\nDeine harte Arbeit wird sich auszahlen! 💪";

  static String m16(name) =>
      "${name}, das hast du großartig gemacht\n– weiter so! 🎉";

  static String m17(name) =>
      "Echt toll, ${name}!\nDu kommst stetig vorwärts! 🚀";

  static String m18(name) => "${name}, toller Fortschritt! ✨";

  static String m19(name) => "${name}, deine Leistung ist beeindruckend! 🏅";

  static String m20(name) => "Richtig gut,\n${name}! 🏆";

  static String m21(name) => "${name}, du machst das klasse,\nBleib dran! 🔥";

  static String m22(name) =>
      "Du rockst das, ${name}!\nEin Schritt nach dem anderen! 🎯";

  static String m23(name) =>
      "${name}, du hast was geschaft, das ist großartig! 💥";

  static String m24(count, name) =>
      "Ich hoffe, du hast und hattest trotzdem einen schönen Tag ${Intl.plural(count, zero: '', other: ', ${name}')} 😊";

  static String m25(date) => "Du hattest ${date} keine Termine geplant gehabt.";

  static String m26(date) => "\$🎉 Termin-Übersicht für den ${date}";

  static String m27(date) => "📅 Termine am ${date}";

  static String m28(terminName) =>
      "${terminName} ist vorbei. Ich hoffe es hat geklappt und dir geholfen 😊\nBitte klicke auf mich und nimm dir eine Minute und reflektiere den Termin\nEgal ob geschaft oder nicht, das reflektieren darüber ist schon eine tolle Leistung 🤘";

  static String m29(terminName) =>
      "Es ist soweit für ${terminName}! Viel Erfolg!🤞";

  static String m30(terminName, count) =>
      "${terminName} steht in ${count} Minuten an. Du schaffst das!🤞";

  static String m31(count) =>
      "${Intl.plural(count, zero: 'Benachrichtigung', other: 'Benachrichtigungen')}";

  static String m32(date) => "Du hast ${date}\n";

  static String m33(count) =>
      "${Intl.plural(count, one: '\nTermin geschafft', other: '\nTermine geschafft')}";

  static String m34(count, date) =>
      "Du hast ${date} ${Intl.plural(count, one: 'deinen Termin', other: '${count} Termine')} noch nicht beantwortet.";

  static String m35(count) =>
      "\n\n(Wenn du Lust hast, kannst du noch Feedback zu ${Intl.plural(count, one: 'einem Termin', other: '${count} Terminen')} auf der \'Offen\'-Seite geben 😊)";

  static String m36(name) =>
      "${name} hier findest du eine Auflistung all deiner Wochenpläne 😊";

  static String m37(name) =>
      "${name} hier findest du alle Termine, zu denen du noch kein Feedback gegeben hast 😉\n";

  static String m38(count) =>
      "${Intl.plural(count, zero: 'Gerade gibt es nichts zu beantworten 😉', one: 'Es steht noch ${count} Termin aus 😉', other: 'Es stehen noch ${count} Termine aus ;)')}";

  static String m39(count) =>
      "${Intl.plural(count, zero: ' ', one: '\n\n Wenn du Lust hast kannst du noch Feedback zu ${count} Aktivität geben', other: '\n\n Wenn du Lust hast kannst du noch Feedback zu ${count} Aktivitäten geben')}";

  static String m40(count, randomText) =>
      "${Intl.plural(count, one: 'Termin bewältigt\n\n ${randomText}', other: 'Termine bewältigt\n\n ${randomText}')}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "accept": MessageLookupByLibrary.simpleMessage("Accept"),
    "activitySummaryDescription": MessageLookupByLibrary.simpleMessage(
      "Dies ist deine übersicht über alle Wochen",
    ),
    "activitySummaryGoodFeedback": MessageLookupByLibrary.simpleMessage(
      "Die Liste unten merkt sich Aktivitäten, die du besonders gut bewertet hast.",
    ),
    "activitySummaryGraphDescription": MessageLookupByLibrary.simpleMessage(
      "Die Grafik zeigt deine Durchschnittswerte für jede Woche.",
    ),
    "am": MessageLookupByLibrary.simpleMessage("am"),
    "appTitle": MessageLookupByLibrary.simpleMessage("Menta Track"),
    "back": MessageLookupByLibrary.simpleMessage("zurück"),
    "bestActivities": MessageLookupByLibrary.simpleMessage("Beste Aktivitäten"),
    "calm_activities_desc": MessageLookupByLibrary.simpleMessage(
      "Aktivitäten bei denen du dich ruhig gefühlt hast:",
    ),
    "cancel": MessageLookupByLibrary.simpleMessage("Abbrechen"),
    "checkPendingFeedback": MessageLookupByLibrary.simpleMessage(
      "Schau auf der Startseite unter \"Offen\" oder in der \"Wochenübersicht\" nach, um Feedback zu einer Aktivität zu geben 👍",
    ),
    "daily_Values": MessageLookupByLibrary.simpleMessage("Tägliche Werte"),
    "dayNotYetArrived": m0,
    "day_reward_message": MessageLookupByLibrary.simpleMessage(
      "Danke! 😊 \n\n Ich hoffe der Tag hat dich vorangebracht und dir gut getan \n\n Du schaffst das Tag für Tag 💪",
    ),
    "delete": MessageLookupByLibrary.simpleMessage("Löschen"),
    "delete_week_plan": MessageLookupByLibrary.simpleMessage(
      "Willst du den Wochenplan für:",
    ),
    "delete_week_plan2": MessageLookupByLibrary.simpleMessage(
      "wirklich löschen?",
    ),
    "displayADate": m1,
    "displayADateWithYear": m2,
    "displayATime": m3,
    "favorite_comments0": MessageLookupByLibrary.simpleMessage(
      "Am besten ging es dir hier 🙂:",
    ),
    "favorite_comments1": MessageLookupByLibrary.simpleMessage(
      "Hier warst du am ruhigsten 😊:",
    ),
    "favorite_comments2": MessageLookupByLibrary.simpleMessage(
      "Am meisten geholfen hat dir 💪:",
    ),
    "friday": MessageLookupByLibrary.simpleMessage("Freitag"),
    "generalHelp": MessageLookupByLibrary.simpleMessage("Allgemeine Hilfe"),
    "gifProgress_case0": m4,
    "gifProgress_case1": m5,
    "gifProgress_case2": m6,
    "gifProgress_case3": m7,
    "gifProgress_case4": m8,
    "gifProgress_case5": m9,
    "gifProgress_case6": m10,
    "gifProgress_title": m11,
    "gifProgress_title_week": MessageLookupByLibrary.simpleMessage(
      "Dein Fortschritt diese Woche 😇",
    ),
    "good_activities_desc": MessageLookupByLibrary.simpleMessage(
      "Aktivitäten bei denen du dich gut gefühlt hast:",
    ),
    "help": MessageLookupByLibrary.simpleMessage("Hilfe"),
    "help_activities_desc": MessageLookupByLibrary.simpleMessage(
      "Aktivitäten die dir gut getan haben:",
    ),
    "helper_activities0": MessageLookupByLibrary.simpleMessage(
      "Das hast du wirklich großartig gemacht! 🎉",
    ),
    "helper_activities0_name": m12,
    "helper_activities1": MessageLookupByLibrary.simpleMessage(
      "Wieder einen Fortschritt vorwärts! 🌟",
    ),
    "helper_activities10": MessageLookupByLibrary.simpleMessage(
      "Du bist auf dem richtigen Weg! 🌟",
    ),
    "helper_activities10_name": m13,
    "helper_activities11": MessageLookupByLibrary.simpleMessage(
      "Großartige Arbeit 🌟",
    ),
    "helper_activities11_name": m14,
    "helper_activities1_name": m15,
    "helper_activities2": MessageLookupByLibrary.simpleMessage(
      "Tolle Leistung, mach weiter so! 🔥",
    ),
    "helper_activities2_name": m16,
    "helper_activities3": MessageLookupByLibrary.simpleMessage(
      "Richtig gut gemacht, du ziehst das durch! 🏅",
    ),
    "helper_activities3_name": m17,
    "helper_activities4": MessageLookupByLibrary.simpleMessage("Weiter so! 🚀"),
    "helper_activities4_name": m18,
    "helper_activities5": MessageLookupByLibrary.simpleMessage(
      "Wirklich beeindruckend, wie du das gemeistert hast! ✨",
    ),
    "helper_activities5_name": m19,
    "helper_activities6": MessageLookupByLibrary.simpleMessage(
      "Du verdienstt Anerkennung! 🥇",
    ),
    "helper_activities6_name": m20,
    "helper_activities7": MessageLookupByLibrary.simpleMessage(
      "Toll, wie du dich anstrengst! 🎯",
    ),
    "helper_activities7_name": m21,
    "helper_activities8": MessageLookupByLibrary.simpleMessage(
      "Du kommst jeden Tag einen Schritt näher an dein Ziel! 🚶‍♀️",
    ),
    "helper_activities8_name": m22,
    "helper_activities9": MessageLookupByLibrary.simpleMessage(
      "Wirklich stark, von dir! 💪",
    ),
    "helper_activities9_name": m23,
    "home": MessageLookupByLibrary.simpleMessage("Startseite"),
    "hopeYouHadAGoodDay": m24,
    "legend_Msg0": MessageLookupByLibrary.simpleMessage("Wie gut ging es dir?"),
    "legend_Msg1": MessageLookupByLibrary.simpleMessage("Wie ruhig warst du?"),
    "legend_Msg1_clip": MessageLookupByLibrary.simpleMessage(
      "Wie ruhig\nwarst du?",
    ),
    "legend_Msg2": MessageLookupByLibrary.simpleMessage(
      "Wie sehr hat es geholfen?",
    ),
    "legend_Msg2_clip": MessageLookupByLibrary.simpleMessage(
      "Wie sehr hat\nes geholfen?",
    ),
    "mainPageDeleteWeek": MessageLookupByLibrary.simpleMessage(
      "Um eine Woche zu löschen, halte das \'Mülleimer\'-Symbol gedrückt.",
    ),
    "mainPageDescription": MessageLookupByLibrary.simpleMessage(
      "Dies ist die Startseite",
    ),
    "mainPageInstructions": MessageLookupByLibrary.simpleMessage(
      "Hier findest du alle deine gespeicherten Wochenpläne.",
    ),
    "mainPageQrScanner": MessageLookupByLibrary.simpleMessage(
      "Wenn du auf die Schaltfläche unten rechts tippst, öffnet sich ein QR-Scanner. Nutze ihn, um einen QR-Code von deinem Therapeuten zu scannen.",
    ),
    "mainPageSwipeOrButton": MessageLookupByLibrary.simpleMessage(
      "Wische nach links/rechts oder nutze eine Schaltfläche im unteren Menü, um die Seiten zu wechseln.",
    ),
    "mainPageTapOnPlan": MessageLookupByLibrary.simpleMessage(
      "Tippe auf einen Plan, um ihn zu öffnen :)",
    ),
    "monday": MessageLookupByLibrary.simpleMessage("Montag"),
    "noAppointmentsOn": m25,
    "noti_dayEnd_message": MessageLookupByLibrary.simpleMessage(
      "Wieder ein Tag vorbei. \n Klicke auf mich um zu sehn was heute so los war 😊 \n",
    ),
    "noti_dayEnd_title": m26,
    "noti_noTasks_message": MessageLookupByLibrary.simpleMessage(
      "Heute stehen keine Termine an, also lehn dich zurück und Entspann ein bisschen 🙂",
    ),
    "noti_start_message": MessageLookupByLibrary.simpleMessage(
      "Heute stehen folgende Termine an 🙂 \n",
    ),
    "noti_start_title": m27,
    "noti_termin_messageAfter": m28,
    "noti_termin_messageAt": m29,
    "noti_termin_messageBefore": m30,
    "noti_weekEnd_message": MessageLookupByLibrary.simpleMessage(
      "Super! Wieder eine Woche geschaft\n Klicke hier um deine Wochenübersicht\n anzeigen zu lassen",
    ),
    "noti_weekEnd_title": MessageLookupByLibrary.simpleMessage(
      "Wochenübersicht 🎊",
    ),
    "open": MessageLookupByLibrary.simpleMessage("Offenes"),
    "overview": MessageLookupByLibrary.simpleMessage("Übersicht"),
    "qr_desc": MessageLookupByLibrary.simpleMessage(
      "Scane einen QR-Code\num einen Wochenplan zu importieren!",
    ),
    "qr_success": MessageLookupByLibrary.simpleMessage(
      "QR-Code erfolgreich gescannt! 👍",
    ),
    "questionPage_a0e": MessageLookupByLibrary.simpleMessage("Nein"),
    "questionPage_a0m": MessageLookupByLibrary.simpleMessage("Später"),
    "questionPage_a0s": MessageLookupByLibrary.simpleMessage("Ja"),
    "questionPage_a1e": MessageLookupByLibrary.simpleMessage("sehr \n gut"),
    "questionPage_a1s": MessageLookupByLibrary.simpleMessage(
      "sehr \n schlecht",
    ),
    "questionPage_a2e": MessageLookupByLibrary.simpleMessage("sehr \n ruhig"),
    "questionPage_a2s": MessageLookupByLibrary.simpleMessage(
      "sehr \n aufgeregt",
    ),
    "questionPage_a3e": MessageLookupByLibrary.simpleMessage(
      "sehr \n geholfen",
    ),
    "questionPage_a3s": MessageLookupByLibrary.simpleMessage(
      "wenig \n geholfen",
    ),
    "questionPage_comment": MessageLookupByLibrary.simpleMessage(
      "Wenn du Lust hast kannst du hier einen kurzen Kommentar hinzufügen:",
    ),
    "questionPage_commentLabel": MessageLookupByLibrary.simpleMessage(
      "Dein Feedback",
    ),
    "questionPage_q1": MessageLookupByLibrary.simpleMessage(
      "Konntest du den Termin wahrnehmen?",
    ),
    "questionPage_q2": MessageLookupByLibrary.simpleMessage(
      "Wie ist es dir bei dem Termin gegangen?",
    ),
    "questionPage_q3": MessageLookupByLibrary.simpleMessage(
      "Warst du dabei aufgeregt?",
    ),
    "questionPage_q4": MessageLookupByLibrary.simpleMessage(
      "Hat es dir gut getan?",
    ),
    "questionPage_rewardMsg": MessageLookupByLibrary.simpleMessage(
      "Danke 😊 \n\n Du hast dich mit deinen Emotionen auseinandergesetzt 🥰 \n\n Das war wirklich stark von dir 💪",
    ),
    "questionPage_save": MessageLookupByLibrary.simpleMessage(
      "Slide zum speichern",
    ),
    "questionPage_too_early": MessageLookupByLibrary.simpleMessage(
      "Du bist zu früh dran 😊 \nAber trotzdem cool, dass du vorbeischaust 👍",
    ),
    "rewardPopUp_conf": MessageLookupByLibrary.simpleMessage("Gut gemacht! ❤️"),
    "rewardPopUp_scroll": MessageLookupByLibrary.simpleMessage(
      "\n scrolle für deinen Progress 😉",
    ),
    "saturday": MessageLookupByLibrary.simpleMessage("Samstag"),
    "settings": MessageLookupByLibrary.simpleMessage("Einstellungen"),
    "settings_chooseAccent": MessageLookupByLibrary.simpleMessage(
      "Wähle eine Akzentfarbe",
    ),
    "settings_darkMode": MessageLookupByLibrary.simpleMessage("Dark Mode"),
    "settings_name": MessageLookupByLibrary.simpleMessage("Dein Name"),
    "settings_notifications": m31,
    "settings_theme": MessageLookupByLibrary.simpleMessage("Thema"),
    "settings_themeOnlyMainPage": MessageLookupByLibrary.simpleMessage(
      "Thema nur auf Hauptseite",
    ),
    "settings_themePictures": MessageLookupByLibrary.simpleMessage(
      "Keine Bilder",
    ),
    "special_activities": MessageLookupByLibrary.simpleMessage(
      "Besondere Aktivitäten:",
    ),
    "summary_no_entries": MessageLookupByLibrary.simpleMessage(
      " Noch Keine Einträge",
    ),
    "sunday": MessageLookupByLibrary.simpleMessage("Sonntag"),
    "taskCompletedOn": m32,
    "tasksCompleted": m33,
    "tasksNotAnsweredOn": m34,
    "tasksPendingFeedback": m35,
    "themeHelper_msg0": m36,
    "themeHelper_open_msg0": m37,
    "themeHelper_open_msg1": m38,
    "thursday": MessageLookupByLibrary.simpleMessage("Donnerstag"),
    "till": MessageLookupByLibrary.simpleMessage("bis"),
    "today": MessageLookupByLibrary.simpleMessage("heute"),
    "tuesday": MessageLookupByLibrary.simpleMessage("Dienstag"),
    "um": MessageLookupByLibrary.simpleMessage("um"),
    "unanswered": MessageLookupByLibrary.simpleMessage("Unbeantwortet"),
    "unansweredActivities": MessageLookupByLibrary.simpleMessage(
      "Auf dieser Seite findest du Aktivitäten, zu denen du noch kein Feedback gegeben hast ;)",
    ),
    "understood": MessageLookupByLibrary.simpleMessage("Verstanden!"),
    "unexpectedCaseFound": MessageLookupByLibrary.simpleMessage(
      "Glückwunsch!!! 🎉 Du hast einen Fall gefunden, an den ich nicht gedacht habe! Gut gemacht! 😊 Falls möglich, sag deinem Therapeuten oder Entwickler der App, welche Kombination zu diesem Fall geführt hat.",
    ),
    "wednesday": MessageLookupByLibrary.simpleMessage("Mittwoch"),
    "weekOverView_leftAnswers": m39,
    "weekOverView_noAnswers": MessageLookupByLibrary.simpleMessage(
      "Du hast diese Woche noch keine Aktivität bewertet \n komm bitte später wieder 🙋‍♂️",
    ),
    "weekOverView_scroll": MessageLookupByLibrary.simpleMessage(
      "\n\n Scroll weiter um mehr Infos zu bekommen ;)",
    ),
    "weekOverView_summary": MessageLookupByLibrary.simpleMessage(
      "Du hast diese Woche\n",
    ),
    "weekOverView_summary_part2": m40,
    "weekPlanActivitiesWithExclamation": MessageLookupByLibrary.simpleMessage(
      "• Aktivitäten mit einem Ausrufezeichen können noch bewertet werden 😊",
    ),
    "weekPlanDescription": MessageLookupByLibrary.simpleMessage(
      "Dies ist dein Wochenplan",
    ),
    "weekPlanGrayActivities": MessageLookupByLibrary.simpleMessage(
      "• Graue Aktivitäten bedeuten, dass die Zeit dafür noch nicht gekommen ist.",
    ),
    "weekPlanGreenActivities": MessageLookupByLibrary.simpleMessage(
      "• Grüne Aktivitäten bedeuten, dass du bereits Feedback gegeben hast.",
    ),
    "weekPlanInstructions": MessageLookupByLibrary.simpleMessage(
      "Hier siehst du alle Aktivitäten, die für diese Woche geplant sind :)",
    ),
    "weekPlanTapForDayView": MessageLookupByLibrary.simpleMessage(
      "Tippe auf die Kopfzeile, um eine Tagesübersicht zu öffnen.",
    ),
    "weekPlanTapForWeekView": MessageLookupByLibrary.simpleMessage(
      "Tippe auf die Schaltfläche unten rechts, um die Wochenübersicht zu öffnen.",
    ),
    "week_reward_message": MessageLookupByLibrary.simpleMessage(
      "Danke! 😊 \n\n Ich hoffe deine Woche hat dich vorangebracht und dir geholfen \n\n Du schaffst das Woche für Woche 💪",
    ),
    "weeklyPlans": MessageLookupByLibrary.simpleMessage("Wochenpläne"),
    "weekly_values": MessageLookupByLibrary.simpleMessage("Wöchentliche Werte"),
  };
}
