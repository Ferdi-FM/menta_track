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

  static String m0(count, name) =>
      "${Intl.plural(count, one: 'Die Aktivität ist', other: 'die Aktivitäten sind')} noch nicht gekommen 😉 Trotzdem schön, dass du schon mal hier reinschaust ${name} :)";

  static String m1(count) =>
      "${Intl.plural(count, zero: 'gar nicht', one: 'wenig', two: 'sehr', other: 'äußerst')}";

  static String m2(count) =>
      "${Intl.plural(count, zero: 'letzte\nWoche', one: 'letzten\nMonat', other: 'gesamte\nZeit')}";

  static String m3(adjective) =>
      "Aktivitäten bei denen du dich ${adjective} gefühlt hast:";

  static String m4(name) =>
      "Der Tag ist noch nicht gekommen 😉 Trotzdem schön, dass du schon mal hier reinschaust ${name} :)";

  static String m5(date) => "${date}";

  static String m6(date) => "${date}";

  static String m7(date) => "${date}";

  static String m8(name) => "Toller Start${name}! Weiter so! 🎉";

  static String m9(name) =>
      "Ein Viertel geschafft${name}! Das machst du fantastisch! 🌟";

  static String m10(name) => "Mehr als ein Drittel geschafft${name}! 💪";

  static String m11(name) => "Halbzeit erreicht! Weiter so ${name}! 🔥";

  static String m12(name) => "Drei Viertel rum ${name}! Fast geschafft! 🌟";

  static String m13(name) =>
      "Fast fertig ${name}! Du hast hart gearbeitet, nur noch ein bisschen mehr! 🚀";

  static String m14(name) => "Gratuliere ${name}! Du hast es geschafft! 🏆🎉";

  static String m15(count) =>
      "${Intl.plural(count, zero: 'Dein Fortschritt bis zu diesem Tag 😇', other: 'Dein Fortschritt an diesem Tag 😇')}";

  static String m16(adjective) =>
      "Aktivitäten bei denen du dich ${adjective} gefühlt hast:";

  static String m17(adjective) => "Aktivitäten die dir ${adjective} haben:";

  static String m18(name) =>
      "Super gemacht, ${name}!\nDu bist auf dem richtigen Weg! 🌟";

  static String m19(name) => "Gut gemacht,\n${name}! 💪";

  static String m20(name) => "Großartige Arbeit,\n${name} 🌟";

  static String m21(name) =>
      "Stark, ${name}!\nDeine harte Arbeit wird sich auszahlen! 💪";

  static String m22(name) => "${name},  großartig!\nWeiter so! 🎉";

  static String m23(name) => "${name}\nDu kommst stetig vorwärts! 🚀";

  static String m24(name) => "${name}, toller Fortschritt! ✨";

  static String m25(name) => "${name}, Schritt für Schritt ans Ziel! 🏅";

  static String m26(name) => "Richtig gut,\n${name}! 🏆";

  static String m27(name) => "${name}, du machst das klasse,\nBleib dran! 🔥";

  static String m28(name) => "\nEin Schritt nach dem anderen, ${name}! 🎯";

  static String m29(name) =>
      "${name}, du hast was geschaft, das ist großartig! 💥";

  static String m30(count, name) =>
      "Ich hoffe, du hast und hattest trotzdem einen schönen Tag ${Intl.plural(count, zero: '', other: ', ${name}')} 😊";

  static String m31(date) =>
      "Du hattest ${date} keine Aktivität geplant gehabt.";

  static String m32(date) => "🎉 Aktivitäts-Übersicht für den ${date}";

  static String m33(date) => "📅 Aktivitäten am ${date}";

  static String m34(terminName) =>
      "${terminName} ist vorbei.\n Ich hoffe es hat geklappt und dir geholfen 😊\nBitte klicke auf mich,\n nimm dir eine Minute\nund reflektiere die Aktivität\nEgal ob geschaft oder nicht,\ndas reflektieren darüber ist schon\neine tolle Leistung 🤘";

  static String m35(terminName) =>
      "Es ist soweit für ${terminName}!\n Viel Erfolg!🤞";

  static String m36(terminName, count) =>
      "${terminName} steht\n in ${count} Minuten an. \n Du schaffst das!🤞";

  static String m37(name) =>
      "Du kannst auch feedback geben, falls es nicht geklappt hat!\nAllein das du Feedback gibst ist schon toll ${name} 😇💖\n";

  static String m38(count, name) =>
      "${Intl.plural(count, zero: 'Klasse, dass du Feedback gegeben hast${name}!!\n🥳', one: 'Schön, dass du dir die Zeit für Feedback genommen hast${name}!\n🥳', other: 'Toll, dass du reflektierst${name}!\n🥳')}";

  static String m39(count, name) =>
      "${Intl.plural(count, zero: 'Klasse, dass dus geschafft hast${name}!!\n🥳', one: 'Schön, dass du dir die Zeit genommen hast${name}!\n🥳', other: 'Toll, dass du reflektierst${name}!\n🥳')}";

  static String m40(date1, date2, count, name) =>
      "${Intl.plural(count, zero: '${name} ist am \n${date1} um ${date2}\n\nDu bist zu früh dran 😊 \nAber trotzdem cool, dass du vorbeischaust 👍', other: '${name} ist am \n${date1} um ${date2}\n\nCool, dass du da bist 😊\nDie Aktivität hat grade erst gestartet\nSchau in kürze nochmal hier rein um Feedback zu geben 👍')}";

  static String m41(count) =>
      "${Intl.plural(count, zero: 'Benachrichtigung', other: 'Benachrichtigungen')}";

  static String m42(date) => "Du hast ${date}\n";

  static String m43(count) =>
      "${Intl.plural(count, one: '\nAktivität geschafft', other: '\nAktivitäten geschafft')}";

  static String m44(count, date) =>
      "Du hast ${date}\n ${Intl.plural(count, one: 'deine Aktivität', other: '${count} Aktivitäten')}\nnoch nicht beantwortet.";

  static String m45(count) =>
      "\n\n(Wenn du Lust hast, kannst du noch Feedback zu ${Intl.plural(count, one: 'einer Aktivität', other: '${count} Aktivitäten')} auf der \'Offen\'-Seite geben 😊)";

  static String m46(name) =>
      "Hier wird angezeigt was heute so geplant ist ${name}😇";

  static String m47(name, count) =>
      "${name}${Intl.plural(count, zero: 'Hier', other: ', hier')} findest du eine Liste all deiner Wochenpläne 😊";

  static String m48(name, count) =>
      "${name}${Intl.plural(count, zero: 'Hier', other: ', hier')} findest du alle Aktivitäten, zu denen du noch kein Feedback gegeben hast 😊\n";

  static String m49(count) =>
      "${Intl.plural(count, zero: 'Gerade gibt es nichts zu beantworten 😉', one: 'Es steht noch ${count} Aktivität aus 😉', other: 'Es stehen noch ${count} Aktivitäten aus 😉')}";

  static String m50(count) =>
      "${Intl.plural(count, zero: ' ', one: '\n\n Wenn du Lust hast kannst du noch Feedback zu ${count} Aktivität geben', other: '\n\n Wenn du Lust hast kannst du noch Feedback zu ${count} Aktivitäten geben')}";

  static String m51(count) =>
      "${Intl.plural(count, one: 'Aktivität bewältigt\n\n', other: 'Aktivitäten bewältigt\n\n')}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "accept": MessageLookupByLibrary.simpleMessage("Annehmen"),
    "activities": MessageLookupByLibrary.simpleMessage("Aktivitäten"),
    "activitySummaryDescription": MessageLookupByLibrary.simpleMessage(
      "Das ist Deine Übersicht über alle Wochen",
    ),
    "activitySummaryGoodFeedback": MessageLookupByLibrary.simpleMessage(
      "Die Liste unten merkt sich Aktivitäten, die du besonders gut bewertet hast. \nWenn es dir gut getan hat etwas nicht zu tun wird der Eintrag dabei Orange markiert 😉",
    ),
    "activitySummaryGraphDescription": MessageLookupByLibrary.simpleMessage(
      "Die Grafik zeigt deine Durchschnittswerte für jede Woche.",
    ),
    "activity_calm_adjective1": MessageLookupByLibrary.simpleMessage(
      "äußerst aufgeregt",
    ),
    "activity_calm_adjective2": MessageLookupByLibrary.simpleMessage(
      "aher aufgeregt",
    ),
    "activity_calm_adjective3": MessageLookupByLibrary.simpleMessage(
      "sehr ruhig",
    ),
    "activity_calm_adjective4": MessageLookupByLibrary.simpleMessage(
      "besonders ruhig",
    ),
    "activity_filter": MessageLookupByLibrary.simpleMessage("Filter"),
    "activity_filter_desc1": MessageLookupByLibrary.simpleMessage(
      "Filtere dannach was",
    ),
    "activity_filter_desc2": MessageLookupByLibrary.simpleMessage(
      "gut, ruhig, hilfreich war 😊",
    ),
    "activity_good_adjective1": MessageLookupByLibrary.simpleMessage(
      "äußerst schlecht",
    ),
    "activity_good_adjective2": MessageLookupByLibrary.simpleMessage(
      "eher schlecht",
    ),
    "activity_good_adjective3": MessageLookupByLibrary.simpleMessage(
      "sehr gut",
    ),
    "activity_good_adjective4": MessageLookupByLibrary.simpleMessage(
      "besonders gut",
    ),
    "activity_help_adjective1": MessageLookupByLibrary.simpleMessage(
      "gar nicht geholfen",
    ),
    "activity_help_adjective2": MessageLookupByLibrary.simpleMessage(
      "sehr wenig geholfen",
    ),
    "activity_help_adjective3": MessageLookupByLibrary.simpleMessage(
      "sehr geholfen",
    ),
    "activity_help_adjective4": MessageLookupByLibrary.simpleMessage(
      "besonders geholfen",
    ),
    "activity_not_there_yet": m0,
    "addToCalendar": MessageLookupByLibrary.simpleMessage(
      "Zum Smartphone\nKalender hinzufügen",
    ),
    "addWeek": MessageLookupByLibrary.simpleMessage("Woche hinzufügen"),
    "am": MessageLookupByLibrary.simpleMessage("am"),
    "appTitle": MessageLookupByLibrary.simpleMessage("Menta Track"),
    "back": MessageLookupByLibrary.simpleMessage("zurück"),
    "beginTime": MessageLookupByLibrary.simpleMessage("Startzeit:"),
    "bestActivities": MessageLookupByLibrary.simpleMessage("Beste Aktivitäten"),
    "buttonDisplay": m1,
    "buttonTimeDisplay": m2,
    "calm_activities_desc": MessageLookupByLibrary.simpleMessage(
      "Aktivitäten bei denen du dich ruhig gefühlt hast:",
    ),
    "calm_activities_desc_variable": m3,
    "cancel": MessageLookupByLibrary.simpleMessage("Abbrechen"),
    "checkPendingFeedback": MessageLookupByLibrary.simpleMessage(
      "Schau auf der Startseite unter \"Offen\" oder in der \"Wochenübersicht\" nach, um Feedback zu einer Aktivität zu geben 👍",
    ),
    "close": MessageLookupByLibrary.simpleMessage("Schließen"),
    "comment": MessageLookupByLibrary.simpleMessage("Kommentar:"),
    "createTermin": MessageLookupByLibrary.simpleMessage("Aktivität erstellen"),
    "daily_Values": MessageLookupByLibrary.simpleMessage("Tägliche Werte"),
    "date": MessageLookupByLibrary.simpleMessage("Datum"),
    "dayNotYetArrived": m4,
    "dayOverViewText1": MessageLookupByLibrary.simpleMessage(
      "Das ist deine Tagesübersicht\n",
    ),
    "dayOverViewText2": MessageLookupByLibrary.simpleMessage(
      "Hier kannst du eine Zusammenfassung sehen, was du heute geschafft hast!",
    ),
    "dayOverViewText3": MessageLookupByLibrary.simpleMessage(
      "Aktivitäten, die du besonders gut bewertet hast, werden dir hier aufgelistet. Der Baum wächst je nach deinen Aktivitäten, zu denen du Feedback gegeben hast. Er startet dabei an dem Punkt, bis zu dem du an den Vortagen gekommen bist, und endet bei dem, was du am Tag hinzugewonnen hast :)",
    ),
    "dayOverViewText4": MessageLookupByLibrary.simpleMessage(
      "Der Graph zeigt dir die Durchschnittswerte deiner Antworten, sodass du aus deinen Aktivitäten ablesen kannst, wie sehr dir der Tag durchschnittlich geholfen hat.",
    ),
    "dayOverViewText5": MessageLookupByLibrary.simpleMessage(
      "Am Ende jeden Tages bekommst du eine Benachrichtigung, die dich hier hinführt, oder du kannst bei einem Wochenplan auf den Kalenderkopf tippen :) Ich hoffe, diese Übersicht ist hilfreich für dich! :)",
    ),
    "day_reward_message": MessageLookupByLibrary.simpleMessage(
      "Danke! 😊 \n\n Ich hoffe der Tag hat dich vorangebracht und dir gut getan \n\n Du schaffst das Tag für Tag 💪",
    ),
    "delete": MessageLookupByLibrary.simpleMessage("Löschen"),
    "deleteActivity": MessageLookupByLibrary.simpleMessage(
      "Aktivität löschen?",
    ),
    "delete_Entry": MessageLookupByLibrary.simpleMessage("Aktivität löschen"),
    "delete_Termin": MessageLookupByLibrary.simpleMessage(
      "Willst du die Aktivität:",
    ),
    "delete_week_plan": MessageLookupByLibrary.simpleMessage(
      "Willst du den Wochenplan für:",
    ),
    "delete_week_plan2": MessageLookupByLibrary.simpleMessage(
      "wirklich löschen?",
    ),
    "den": MessageLookupByLibrary.simpleMessage("den"),
    "displayADate": m5,
    "displayADateWithYear": m6,
    "displayATime": m7,
    "done": MessageLookupByLibrary.simpleMessage("Geschafft! 🏆"),
    "edit": MessageLookupByLibrary.simpleMessage("Bearbeiten"),
    "endTime": MessageLookupByLibrary.simpleMessage("Endzeit"),
    "favorite_comments0": MessageLookupByLibrary.simpleMessage(
      "Am besten ging es dir hier 🙂:",
    ),
    "favorite_comments1": MessageLookupByLibrary.simpleMessage(
      "Hier warst du am ruhigsten 😊:",
    ),
    "favorite_comments2": MessageLookupByLibrary.simpleMessage(
      "Am meisten geholfen hat dir 💪:",
    ),
    "firstStartUp_Message1": MessageLookupByLibrary.simpleMessage(
      "Du hast die App gerade zum ersten mal geöffnet.👍 \n\n Sehr Cool, dass du diese App verwendest 😊 \n\n Du kannst die App in den Einstellungen ein wenig anpassen wenn du Lust hast. \nTippe dazu auf die drei Striche in der oberen rechten Ecke und dann auf Einstellungen\n\n",
    ),
    "firstStartUp_Message2": MessageLookupByLibrary.simpleMessage(
      "Falls du mehr Infos zu einer Seite willst findest du in dem Menü auch einen Hilfe-Button ️",
    ),
    "friday": MessageLookupByLibrary.simpleMessage("Freitag"),
    "generalHelp": MessageLookupByLibrary.simpleMessage("Allgemeine Hilfe"),
    "gifProgress_case0": m8,
    "gifProgress_case1": m9,
    "gifProgress_case2": m10,
    "gifProgress_case3": m11,
    "gifProgress_case4": m12,
    "gifProgress_case5": m13,
    "gifProgress_case6": m14,
    "gifProgress_title": m15,
    "gifProgress_title_week": MessageLookupByLibrary.simpleMessage(
      "Dein Fortschritt diese Woche 😇",
    ),
    "good_activities_desc": MessageLookupByLibrary.simpleMessage(
      "Aktivitäten bei denen du dich gut gefühlt hast:",
    ),
    "good_activities_desc_variable": m16,
    "help": MessageLookupByLibrary.simpleMessage("Hilfe"),
    "help_activities_desc": MessageLookupByLibrary.simpleMessage(
      "Aktivitäten die dir gut getan haben:",
    ),
    "help_activities_desc_variable": m17,
    "helper_activities0": MessageLookupByLibrary.simpleMessage(
      "Das hast du wirklich großartig gemacht! 🎉",
    ),
    "helper_activities0_name": m18,
    "helper_activities1": MessageLookupByLibrary.simpleMessage(
      "Wieder einen Fortschritt vorwärts! 🌟",
    ),
    "helper_activities10": MessageLookupByLibrary.simpleMessage(
      "Du bist auf dem richtigen Weg! 🌟",
    ),
    "helper_activities10_name": m19,
    "helper_activities11": MessageLookupByLibrary.simpleMessage(
      "Großartige Arbeit 🌟",
    ),
    "helper_activities11_name": m20,
    "helper_activities1_name": m21,
    "helper_activities2": MessageLookupByLibrary.simpleMessage(
      "Tolle Leistung, mach weiter so! 🔥",
    ),
    "helper_activities2_name": m22,
    "helper_activities3": MessageLookupByLibrary.simpleMessage(
      "Richtig gut gemacht, du ziehst das durch! 🏅",
    ),
    "helper_activities3_name": m23,
    "helper_activities4": MessageLookupByLibrary.simpleMessage("Weiter so! 🚀"),
    "helper_activities4_name": m24,
    "helper_activities5": MessageLookupByLibrary.simpleMessage(
      "Gut gemacht! ✨",
    ),
    "helper_activities5_name": m25,
    "helper_activities6": MessageLookupByLibrary.simpleMessage("Weiter so! 🥇"),
    "helper_activities6_name": m26,
    "helper_activities7": MessageLookupByLibrary.simpleMessage(
      "Super, bleib dran! 🎯",
    ),
    "helper_activities7_name": m27,
    "helper_activities8": MessageLookupByLibrary.simpleMessage(
      "Du kommst jeden Tag einen Schritt näher an dein Ziel! 🚶‍♀️",
    ),
    "helper_activities8_name": m28,
    "helper_activities9": MessageLookupByLibrary.simpleMessage(
      "Stark, von dir! 💪",
    ),
    "helper_activities9_name": m29,
    "home": MessageLookupByLibrary.simpleMessage("Startseite"),
    "hopeYouHadAGoodDay": m30,
    "iconHelp1": MessageLookupByLibrary.simpleMessage(
      "Zeigt dir, dass du alle Aktivitäten in einer Woche bewertet hast",
    ),
    "iconHelp2": MessageLookupByLibrary.simpleMessage(
      "Zeigt dir, dass noch Aktivitäten bewertet werden können",
    ),
    "iconHelp3": MessageLookupByLibrary.simpleMessage(
      "Zeigt dir, in hervorgehobener Farbe, die aktuelle Woche",
    ),
    "iconHelp4": MessageLookupByLibrary.simpleMessage(
      "Zeigt dir, dass die Woche noch nicht gekommen ist",
    ),
    "illustration_mascot": MessageLookupByLibrary.simpleMessage("Maskottchen"),
    "illustration_people": MessageLookupByLibrary.simpleMessage(
      "Illustration Menschen",
    ),
    "illustration_things": MessageLookupByLibrary.simpleMessage(
      "Illustration Objekte",
    ),
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
      "Das ist die Startseite",
    ),
    "mainPageInstructions": MessageLookupByLibrary.simpleMessage(
      "Hier findest du alle Deine gespeicherten Wochenpläne.",
    ),
    "mainPageQrScanner": MessageLookupByLibrary.simpleMessage(
      "Wenn du auf die Schaltfläche unten rechts tippst, öffnet sich ein QR-Scanner. Nutze ihn um einen QR-Code von deinem Therapeuten zu scannen.",
    ),
    "mainPageSwipeOrButton": MessageLookupByLibrary.simpleMessage(
      "Wische nach links/rechts oder nutze eine Schaltfläche im unteren Menü, um die Seiten zu wechseln.",
    ),
    "mainPageTapOnPlan": MessageLookupByLibrary.simpleMessage(
      "Tippe auf einen Plan, um ihn zu öffnen 😊",
    ),
    "mainPage_noEntries_text": MessageLookupByLibrary.simpleMessage(
      "Du hast noch keine Wochenpläne 🙂 \nTippe auf den Button in der Ecke rechts unten um den QR-Code scanner zu öffnen und einen Plan zu importieren 😊",
    ),
    "monday": MessageLookupByLibrary.simpleMessage("Montag"),
    "noAppointmentsOn": m31,
    "noEntriesYet": MessageLookupByLibrary.simpleMessage(
      "Noch keine Einträge 😉",
    ),
    "noFeedBackOpen": MessageLookupByLibrary.simpleMessage(
      "Kein Feedback offen, super!👍",
    ),
    "noFeedbackFromNotification": MessageLookupByLibrary.simpleMessage(
      "Der Tag ist vorbei, toll das du hier reinschaust,\nallein das bedeutet schon, dass du deine Situation verbessern willst👍 \n Danke dir!😉\n\n",
    ),
    "notEmpty": MessageLookupByLibrary.simpleMessage(
      "Name darf nicht leer sein",
    ),
    "not_yet_single": MessageLookupByLibrary.simpleMessage(
      "Noch nicht soweit 😉",
    ),
    "noti_dayEnd_message": MessageLookupByLibrary.simpleMessage(
      "Wieder ein Tag vorbei. \n Klicke auf mich um zu sehn\n was heute so los war 😊 \n",
    ),
    "noti_dayEnd_title": m32,
    "noti_noTasks_message": MessageLookupByLibrary.simpleMessage(
      "Heute stehen keine Aktivitäten an,\nalso lehn dich zurück und\nentspann ein bisschen 🙂",
    ),
    "noti_start_message": MessageLookupByLibrary.simpleMessage(
      "Heute stehen folgende Aktivitäten an 🙂 \n",
    ),
    "noti_start_title": m33,
    "noti_termin_messageAfter": m34,
    "noti_termin_messageAt": m35,
    "noti_termin_messageBefore": m36,
    "noti_weekEnd_message": MessageLookupByLibrary.simpleMessage(
      "Super! Wieder eine Woche geschaft\n Klicke hier um deine Wochenübersicht\n anzeigen zu lassen",
    ),
    "noti_weekEnd_title": MessageLookupByLibrary.simpleMessage(
      "Wochenübersicht 🎊",
    ),
    "open": MessageLookupByLibrary.simpleMessage("Offenes"),
    "open_singular": MessageLookupByLibrary.simpleMessage("Offen"),
    "overview": MessageLookupByLibrary.simpleMessage("Übersicht"),
    "qr_desc": MessageLookupByLibrary.simpleMessage(
      "Scanne einen QR-Code\num einen Wochenplan zu importieren!",
    ),
    "qr_success": MessageLookupByLibrary.simpleMessage(
      "QR-Code erfolgreich gescannt! 👍",
    ),
    "questionPageHelpDialog1": MessageLookupByLibrary.simpleMessage(
      "Hier kannst du Feedback zu deinen Aktivitäten geben! 😊\n",
    ),
    "questionPageHelpDialog2": m37,
    "questionPageHelpDialog3": MessageLookupByLibrary.simpleMessage(
      "Die Fragen öffnen sich jeweils wenn du die vorherige beantwortet hast, am Ende kannst du noch einen kurzen Kommentar mit deinen Gedanken hinzufügen ",
    ),
    "questionPageHelpDialog4": MessageLookupByLibrary.simpleMessage(
      "Schiebe dann den Slider nach rechts um dein Feedback zu speichern ✨\n\nDer wachsende Baum zeigt deinen Fortschritt zur letzten Aktivität an und wächst immer mehr desto mehr Feedback du gibst😊\n",
    ),
    "questionPageHelpDialog5": MessageLookupByLibrary.simpleMessage(
      "Viel Erfolg! Ich hoffe wirklich, dass es dir hilft! 🤞😊\n",
    ),
    "questionPage_WellDone": m38,
    "questionPage_WellDone2": m39,
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
    "questionPage_noQ1": MessageLookupByLibrary.simpleMessage(
      "Wie hast du dich dabei gefühlt es nicht zu tun?",
    ),
    "questionPage_noQ2": MessageLookupByLibrary.simpleMessage(
      "Warst du ruhig oder aufgeregt es nicht zu tun?",
    ),
    "questionPage_noQ3": MessageLookupByLibrary.simpleMessage(
      "Hat es dir trotzdem gut getan?",
    ),
    "questionPage_q1": MessageLookupByLibrary.simpleMessage(
      "Konntest du die Aktivität wahrnehmen?",
    ),
    "questionPage_q2": MessageLookupByLibrary.simpleMessage(
      "Wie ist es dir dabei gegangen?",
    ),
    "questionPage_q3": MessageLookupByLibrary.simpleMessage(
      "Warst du dabei aufgeregt?",
    ),
    "questionPage_q4": MessageLookupByLibrary.simpleMessage(
      "Hat es dir gut getan?",
    ),
    "questionPage_rewardMsg": MessageLookupByLibrary.simpleMessage(
      "Danke 😊 \n\n Du hast dich mit deinen Emotionen beschäftigt 🥰 \n\n Das war wirklich stark von dir 💪",
    ),
    "questionPage_rewardMsg2": MessageLookupByLibrary.simpleMessage(
      "Danke, dass du dir die Zeit genommen hast!😊 \n\nReflexion ist ein wichtiger Teil des Wachstums💪",
    ),
    "questionPage_rewardMsg3": MessageLookupByLibrary.simpleMessage(
      "Top!🌟\n\n Schön, dass du dranbleibst Feedback zu geben!🥰",
    ),
    "questionPage_rewardMsg4": MessageLookupByLibrary.simpleMessage(
      "Danke dir! 🙌\n\n Sich mit den eigenen Emotionen zu beschäftigen, ist ein wichtiger Schritt💪",
    ),
    "questionPage_rewardMsg5": MessageLookupByLibrary.simpleMessage(
      "Schön, dass du dir Zeit für Feedback genommen hast! 🌿",
    ),
    "questionPage_save": MessageLookupByLibrary.simpleMessage(
      "Zum Speichern wischen",
    ),
    "questionPage_slightly_too_early": MessageLookupByLibrary.simpleMessage(
      "Deine Aktivität startet gleich, schau in 15min oder später nochmal vorbei um Feedback zu geben😊 👍",
    ),
    "questionPage_too_early": MessageLookupByLibrary.simpleMessage(
      "Du bist zu früh dran 😊 \nAber trotzdem cool, dass du vorbeischaust 👍",
    ),
    "questionPage_too_early1": m40,
    "rewardPopUp_conf": MessageLookupByLibrary.simpleMessage("Gut gemacht! ❤️"),
    "rewardPopUp_scroll": MessageLookupByLibrary.simpleMessage(
      "\n scrolle für deinen Fortschritt 😉",
    ),
    "rewardSounds": MessageLookupByLibrary.simpleMessage("Belohnungs Töne"),
    "saturday": MessageLookupByLibrary.simpleMessage("Samstag"),
    "save": MessageLookupByLibrary.simpleMessage("Speichern"),
    "settings": MessageLookupByLibrary.simpleMessage("Einstellungen"),
    "settingsSavedAutomatically": MessageLookupByLibrary.simpleMessage(
      "Einstellungen werden automatisch gespeichert!👍",
    ),
    "settingsText1": MessageLookupByLibrary.simpleMessage(
      "Das sind die Einstellungen\n",
    ),
    "settingsText2": MessageLookupByLibrary.simpleMessage(
      "Im Abschnitt Thema kannst du das Aussehen der App einstellen. Das Thema bezieht sich auf Bilder, die auf der Startseite, Offenseite und im PopUp zu sehen sind. Die Option darunter, wenn du das Bild nur auf der Startseite haben willst.",
    ),
    "settingsText3": MessageLookupByLibrary.simpleMessage(
      "Der Belohnungston wird immer beim PopUp abgespielt\n\n",
    ),
    "settingsText4": MessageLookupByLibrary.simpleMessage(
      "Bei den Benachrichtigungen kannst du bestimmen, wann du: \n- am Morgen eine Übersicht bekommen willst\n- Wann du abends eine Tagesübersicht bekommen willst\n- Wann und wie oft du vor einer Aktivität eine Nachricht erhalten willst",
    ),
    "settings_Infos": MessageLookupByLibrary.simpleMessage("Weitere Infos"),
    "settings_Infos_dataProtection": MessageLookupByLibrary.simpleMessage(
      "Die App erhebt keine deiner Daten, sie sind komplett sicher und privat!\nDer einzige Weg, wie sie jemand einsehen kann ist, wenn du dein Handy herzeigst 😇",
    ),
    "settings_chooseAccent": MessageLookupByLibrary.simpleMessage(
      "Wähle eine Akzentfarbe",
    ),
    "settings_darkMode": MessageLookupByLibrary.simpleMessage("Dark Mode"),
    "settings_eveningNotification": MessageLookupByLibrary.simpleMessage(
      "Zeitpunkt Abends",
    ),
    "settings_hapticFeedback": MessageLookupByLibrary.simpleMessage(
      "Haptisches Feedback",
    ),
    "settings_morningNotification": MessageLookupByLibrary.simpleMessage(
      "Zeitpunkt Morgens",
    ),
    "settings_name": MessageLookupByLibrary.simpleMessage("Dein Name"),
    "settings_name_headline": MessageLookupByLibrary.simpleMessage("Name"),
    "settings_notifications": m41,
    "settings_notificationsForTasks": MessageLookupByLibrary.simpleMessage(
      "Benachrichtigungen vor Aktivitäten",
    ),
    "settings_pickAColor": MessageLookupByLibrary.simpleMessage(
      "Wähle eine Farbe 🎨",
    ),
    "settings_sound_Standard": MessageLookupByLibrary.simpleMessage("Standard"),
    "settings_sound_gameSound": MessageLookupByLibrary.simpleMessage(
      "Videospiel",
    ),
    "settings_sound_levelDone": MessageLookupByLibrary.simpleMessage(
      "Level geschafft",
    ),
    "settings_sound_levelUp": MessageLookupByLibrary.simpleMessage("Level Up"),
    "settings_sound_longer": MessageLookupByLibrary.simpleMessage(
      "längerer Ton",
    ),
    "settings_sound_nothing": MessageLookupByLibrary.simpleMessage("Kein Ton"),
    "settings_theme": MessageLookupByLibrary.simpleMessage("Bilder-Thema"),
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
      "Noch keine Einträge",
    ),
    "sunday": MessageLookupByLibrary.simpleMessage("Sonntag"),
    "taskCompletedOn": m42,
    "tasksCompleted": m43,
    "tasksNotAnsweredOn": m44,
    "tasksPendingFeedback": m45,
    "terminName": MessageLookupByLibrary.simpleMessage("Aktivität Name"),
    "themeHelperToday": m46,
    "themeHelper_msg0": m47,
    "themeHelper_open_msg0": m48,
    "themeHelper_open_msg1": m49,
    "thursday": MessageLookupByLibrary.simpleMessage("Donnerstag"),
    "till": MessageLookupByLibrary.simpleMessage("bis"),
    "toNotDoIt": MessageLookupByLibrary.simpleMessage("(es nicht zu tun)"),
    "today": MessageLookupByLibrary.simpleMessage("heute"),
    "todayHeadline": MessageLookupByLibrary.simpleMessage("Heute"),
    "todayHelpMessage1": MessageLookupByLibrary.simpleMessage(
      "Heute Übersicht",
    ),
    "todayHelpMessage2": MessageLookupByLibrary.simpleMessage(
      "Das ist Deine Übersicht für den heutigen Tag.\n Du kannst sehen was heute noch ansteht und zu was du schon Feedback gegeben hast 👍\n\n Hoffentlich hilft dir das ein wenig beim strukturieren deines Tags 🥰",
    ),
    "today_Headline1": MessageLookupByLibrary.simpleMessage("Heute steht an"),
    "today_Headline2": MessageLookupByLibrary.simpleMessage(
      "Heute schon beantwortet",
    ),
    "today_allAnswered": MessageLookupByLibrary.simpleMessage(
      "Alles beantwortet, SUPER!🌟",
    ),
    "today_hopeForGood": MessageLookupByLibrary.simpleMessage(
      "Und kannst trotzdem etwas machen was dir gut tut 🌱",
    ),
    "today_nothingToAnswer": MessageLookupByLibrary.simpleMessage(
      "Heute gibts nichts zu beantworten 😇\nIch hoffe du hast einen schönen Tag! 😊",
    ),
    "today_nothingToAnswerYet": MessageLookupByLibrary.simpleMessage(
      "Es gibt bisher noch nichts zu beantworten, komm in kürze wieder 😇",
    ),
    "tuesday": MessageLookupByLibrary.simpleMessage("Dienstag"),
    "um": MessageLookupByLibrary.simpleMessage("um"),
    "unanswered": MessageLookupByLibrary.simpleMessage("Unbeantwortet"),
    "unansweredActivities": MessageLookupByLibrary.simpleMessage(
      "Auf dieser Seite findest du Aktivitäten, zu denen du noch kein Feedback gegeben hast 😊",
    ),
    "understood": MessageLookupByLibrary.simpleMessage("Verstanden!"),
    "unexpectedCaseFound": MessageLookupByLibrary.simpleMessage(
      "Glückwunsch!!! 🎉 Du hast einen Fall gefunden, an den ich nicht gedacht habe! Gut gemacht! 😊 Falls möglich, sag deinem Therapeuten oder Entwickler der App, welche Kombination zu diesem Fall geführt hat.",
    ),
    "wednesday": MessageLookupByLibrary.simpleMessage("Mittwoch"),
    "weekEnd": MessageLookupByLibrary.simpleMessage("Wochenende"),
    "weekOverViewHeadline": MessageLookupByLibrary.simpleMessage(
      "Wochenübersicht",
    ),
    "weekOverViewText1": MessageLookupByLibrary.simpleMessage(
      "Das ist deine Wochenübersicht\n",
    ),
    "weekOverViewText2": MessageLookupByLibrary.simpleMessage(
      "Hier wird dir angezeigt, was diese Woche so los war.\n",
    ),
    "weekOverViewText3": MessageLookupByLibrary.simpleMessage(
      "Oben siehst du, wieviel Feedback du gegeben hast, und überhaupt: Welches zu geben bedeutet schon, dass du etwas geschafft hast :)",
    ),
    "weekOverViewText4": MessageLookupByLibrary.simpleMessage(
      "Darunter findest du Aktivitäten, denen du besonders gutes Feedback gegeben hast. Der Baum auf dieser Seite zeigt dir deinen Fortschritt für die gesamte Woche, er startet bei Null und wächst je nachdem, wieviel Feedback du gegeben hast, wobei jedes Wachstum zählt! ;) Der Graph zeigt dir dann deine Durchschnittswerte der einzelnen Tage für diese Woche :)",
    ),
    "weekOverViewText5": MessageLookupByLibrary.simpleMessage(
      "Am Ende jeder Woche, eine halbe Stunde nach der Tagesübersicht, bekommst du eine Benachrichtigung, die dich hierher führt. Du kannst aber auch auf den Knopf rechts unten in einem Wochenplan tippen, um hierher zu kommen :) Viel Erfolg beim Feedback geben! Ich hoffe, du kannst so leichter Aktivitäten und Sachen finden, die dir Freude bereiten oder dir anders helfen :)\n\n",
    ),
    "weekOverViewText6": MessageLookupByLibrary.simpleMessage(
      "Viel Erfolg beim Feedback geben!\nIch hoffe du kannst so leichter Aktivitäten und Sachen finden die dir Freude bereiten oder dir anders helfen :)",
    ),
    "weekOverView_leftAnswers": m50,
    "weekOverView_noAnswers": MessageLookupByLibrary.simpleMessage(
      "Du hast diese Woche noch keine Aktivität bewertet \n komm bitte später wieder 🙋‍♂️",
    ),
    "weekOverView_scroll": MessageLookupByLibrary.simpleMessage(
      "\n\n Scroll weiter um mehr Infos zu bekommen ;)",
    ),
    "weekOverView_summary": MessageLookupByLibrary.simpleMessage(
      "Du hast diese Woche\n",
    ),
    "weekOverView_summary_part2": m51,
    "weekOverView_tooEarly": MessageLookupByLibrary.simpleMessage(
      "Die Woche ist noch nicht gekommen. Schau gerne später wieder hier rein :)",
    ),
    "weekPlanActivitiesWithExclamation": MessageLookupByLibrary.simpleMessage(
      "• Aktivitäten mit einem Ausrufezeichen können noch bewertet werden",
    ),
    "weekPlanDescription": MessageLookupByLibrary.simpleMessage(
      "Das ist dein Wochenplan",
    ),
    "weekPlanGrayActivities": MessageLookupByLibrary.simpleMessage(
      "• Graue Aktivitäten bedeuten, dass die Zeit dafür noch nicht gekommen ist.",
    ),
    "weekPlanGreenActivities": MessageLookupByLibrary.simpleMessage(
      "• Grüne Aktivitäten bedeuten, dass du bereits Feedback gegeben hast.",
    ),
    "weekPlanInstructions": MessageLookupByLibrary.simpleMessage(
      "Hier siehst du alle Aktivitäten, die für diese Woche geplant sind 😊",
    ),
    "weekPlanTapForDayView": MessageLookupByLibrary.simpleMessage(
      "Tippe auf die Kopfzeile, um eine Tagesübersicht zu öffnen.",
    ),
    "weekPlanTapForWeekView": MessageLookupByLibrary.simpleMessage(
      "Tippe auf die Schaltfläche unten rechts, um die Wochenübersicht zu öffnen.",
    ),
    "weekStart": MessageLookupByLibrary.simpleMessage("Wochenstart"),
    "week_reward_message": MessageLookupByLibrary.simpleMessage(
      "Danke! 😊 \n\n Ich hoffe deine Woche hat dich vorangebracht und dir geholfen \n\n Du schaffst das Woche für Woche 💪",
    ),
    "weeklyPlans": MessageLookupByLibrary.simpleMessage("Wochenpläne"),
    "weekly_values": MessageLookupByLibrary.simpleMessage("Wöchentliche Werte"),
  };
}
