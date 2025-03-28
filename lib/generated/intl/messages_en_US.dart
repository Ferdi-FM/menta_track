// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a en_US locale. All the
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
  String get localeName => 'en_US';

  static String m0(count, name) =>
      "${Intl.plural(count, one: 'Die Aktivität ist', other: 'die Aktivitäten sind')} noch nicht gekommen 😉 Trotzdem schön, dass du schon mal hier reinschaust ${name} :)";

  static String m1(count) =>
      "${Intl.plural(count, zero: 'not', one: 'few', two: 'good', other: 'better')}";

  static String m2(count) =>
      "${Intl.plural(count, zero: 'last week', one: 'last month', other: 'all time')}";

  static String m3(adjective) => "Activities where you felt ${adjective}:";

  static String m4(name) =>
      "The day hasn\'t arrived yet 😉 \n Still, it\'s nice that you\'re checking in early ${name} :)";

  static String m5(date) => "${date}";

  static String m6(date) => "${date}";

  static String m7(date) => "${date}";

  static String m8(name) => "Great start ${name}! Keep it up! 🎉";

  static String m9(name) => "A quarter achieved ${name}, fantastic job! 🌟";

  static String m10(name) => "More than a third done ${name}, great effort! 💪";

  static String m11(name) => "Halfway there ${name}! Keep going! 🔥";

  static String m12(name) => "Three quarters done ${name}, almost there! 🌟";

  static String m13(name) =>
      "Almost finished ${name}! You\'ve worked hard, just a little more to go! 🚀";

  static String m14(name) => "Congratulations ${name}! You did it! 🏆🎉";

  static String m15(count) =>
      "${Intl.plural(count, zero: 'Your Progress till this day 😇', other: 'Your Progress on this day 😇')}";

  static String m16(adjective) => "Activities where you felt ${adjective}:";

  static String m17(adjective) => "Activities that made you feel ${adjective}:";

  static String m18(name) =>
      "Awesome job, ${name}!\nYou’re on the right track! 🌟";

  static String m19(name) => "Fantastic work,\n ${name}! 💪";

  static String m20(name) => "Great work,\n ${name}! 🌟";

  static String m21(name) =>
      "Impressive, ${name}!\nYour hard work will pay off! 💪";

  static String m22(name) => "${name}, you did an amazing job!\nKeep going! 🎉";

  static String m23(name) =>
      "Wow, ${name}! You’re setting a new normal every time! 🚀";

  static String m24(name) => "${name}, you nailed this!\nFantastic progress! ✨";

  static String m25(name) => "${name}, your performance is impressive! 🏅";

  static String m26(name) => "Great work,\n ${name}! 🏆";

  static String m27(name) => "${name}, you\'re doing great!\nStay focused! 🔥";

  static String m28(name) =>
      "You’re rocking it, ${name}!\n One step at a time! 🎯";

  static String m29(name) => "${name}, you’ve got this!\nIt’s awesome! 💥";

  static String m30(count, name) =>
      "I hope you had a good day ${Intl.plural(count, zero: '', other: ', ${name}')} 😊";

  static String m31(date) => "You had no appointments planned ${date}.";

  static String m32(date) => "🎉 Activity Summary for the ${date}";

  static String m33(date) => "📅 Activities on the ${date}";

  static String m34(terminName) =>
      "${terminName} is over. I hope it worked out and helped you 😊\nPlease tap on me and take a second to reflect\nIt\'s not bad if you coudn\'t do the Activity, the reflection itself is more than most people can do🤘";

  static String m35(terminName) => "It\'s time for ${terminName}! Good Luck!🤞";

  static String m36(terminName, count) =>
      "${terminName} is on in ${count} minutens. You got this!🤞";

  static String m37(name) =>
      "You can also give feedback if it didn\'t work out! Just giving feedback is already great, ${name} 😇💖\n";

  static String m38(count, name) =>
      "${Intl.plural(count, zero: 'Great job giving feedback${name}!!\n🥳', one: 'Nice that you took the time for feedback${name}!\n🥳', other: 'Awesome that you\'re reflecting${name}!\n🥳')}";

  static String m39(count, name) =>
      "${Intl.plural(count, zero: 'Klasse, dass du\'s geschafft hast${name}!!\n🥳', one: 'Schön, dass du dir die Zeit genommen hast${name}!\n🥳', other: 'Toll, dass du reflektierst${name}!\n🥳')}";

  static String m40(date1, date2, count, name) =>
      "${Intl.plural(count, zero: '${name} is on the ${date1} at ${date2}\n\nYou\'re too early 😊 \nBut it\'s still nice that you\'re here 👍', other: '${name} is on the ${date1} at ${date2}\n\nBut it\'s still nice that you\'re here 😊 Come back shortly too give Feedback! 👍')}";

  static String m41(count) =>
      "${Intl.plural(count, zero: 'Notification', other: 'Notifications')}";

  static String m42(date) => "${date} \nyou completed\n";

  static String m43(count) =>
      "${Intl.plural(count, one: '\nTask', other: '\nTasks')}";

  static String m44(count, date) =>
      "You haven\'t answered ${Intl.plural(count, one: 'your activity', other: '${count} activites')} ${date} yet.";

  static String m45(count) =>
      "\n\n(If you like, you can still give feedback on ${Intl.plural(count, one: 'one activity', other: '${count} activities')} on the \'Open\' page 😊)";

  static String m46(name) => "Your Activities today ${name}😇";

  static String m47(name, count) =>
      "${name}${Intl.plural(count, zero: 'Here', other: ', here')} you can find a List of all your weekly plans 😊";

  static String m48(name, count) =>
      "${name}${Intl.plural(count, zero: 'Here', other: ', here')} are all the activities where you haven\'t given feedback yet 😉\n";

  static String m49(count) =>
      "${Intl.plural(count, zero: 'Currently there is nothing to answer 😉', one: '${count} appointment is left 😉', other: '${count} appointments are left 😉')}";

  static String m50(count) =>
      "${Intl.plural(count, zero: '', one: '\n\n If you like, you can still give feedback on ${count} activity', other: '\n\n If you like, you can still give feedback on ${count} activities')}";

  static String m51(count) =>
      "${Intl.plural(count, one: 'Task\n\n', other: 'Tasks\n\n')}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "accept": MessageLookupByLibrary.simpleMessage("Accept"),
    "activities": MessageLookupByLibrary.simpleMessage("Activities"),
    "activitySummaryDescription": MessageLookupByLibrary.simpleMessage(
      "This is your summary of all weeks.",
    ),
    "activitySummaryGoodFeedback": MessageLookupByLibrary.simpleMessage(
      "The list below notes activities you\'ve evaluated particularly well.",
    ),
    "activitySummaryGraphDescription": MessageLookupByLibrary.simpleMessage(
      "The chart displays your average values for each week.",
    ),
    "activity_calm_adjective1": MessageLookupByLibrary.simpleMessage(
      "restless",
    ),
    "activity_calm_adjective2": MessageLookupByLibrary.simpleMessage("okay"),
    "activity_calm_adjective3": MessageLookupByLibrary.simpleMessage("calm"),
    "activity_calm_adjective4": MessageLookupByLibrary.simpleMessage(
      "very calm",
    ),
    "activity_filter": MessageLookupByLibrary.simpleMessage("Filter"),
    "activity_filter_desc1": MessageLookupByLibrary.simpleMessage("Filter by:"),
    "activity_filter_desc2": MessageLookupByLibrary.simpleMessage(
      "good, calm, helpful 😊",
    ),
    "activity_good_adjective1": MessageLookupByLibrary.simpleMessage("bad"),
    "activity_good_adjective2": MessageLookupByLibrary.simpleMessage("okay"),
    "activity_good_adjective3": MessageLookupByLibrary.simpleMessage("good"),
    "activity_good_adjective4": MessageLookupByLibrary.simpleMessage("better"),
    "activity_help_adjective1": MessageLookupByLibrary.simpleMessage(
      "not helpful",
    ),
    "activity_help_adjective2": MessageLookupByLibrary.simpleMessage(
      "slightly helpful",
    ),
    "activity_help_adjective3": MessageLookupByLibrary.simpleMessage("helpful"),
    "activity_help_adjective4": MessageLookupByLibrary.simpleMessage(
      "very helpful",
    ),
    "activity_not_there_yet": m0,
    "addToCalendar": MessageLookupByLibrary.simpleMessage(
      "Add to Smartphone Calendar",
    ),
    "addWeek": MessageLookupByLibrary.simpleMessage("Add Week"),
    "am": MessageLookupByLibrary.simpleMessage("on the"),
    "appTitle": MessageLookupByLibrary.simpleMessage("Menta Track"),
    "back": MessageLookupByLibrary.simpleMessage("Back"),
    "beginTime": MessageLookupByLibrary.simpleMessage("Starttime:"),
    "bestActivities": MessageLookupByLibrary.simpleMessage("Best Activities"),
    "buttonDisplay": m1,
    "buttonTimeDisplay": m2,
    "calm_activities_desc": MessageLookupByLibrary.simpleMessage(
      "Activities where you felt calm:",
    ),
    "calm_activities_desc_variable": m3,
    "cancel": MessageLookupByLibrary.simpleMessage("Cancel"),
    "checkPendingFeedback": MessageLookupByLibrary.simpleMessage(
      "Check on the home page under \'Open\' or in the \'Week Overview\' to give feedback on an activity 👍",
    ),
    "close": MessageLookupByLibrary.simpleMessage("Close"),
    "comment": MessageLookupByLibrary.simpleMessage("Comment:"),
    "createTermin": MessageLookupByLibrary.simpleMessage("create Activity"),
    "daily_Values": MessageLookupByLibrary.simpleMessage("Daily Values"),
    "date": MessageLookupByLibrary.simpleMessage("Date"),
    "dayNotYetArrived": m4,
    "dayOverViewText1": MessageLookupByLibrary.simpleMessage(
      "This is your daily overview\n",
    ),
    "dayOverViewText2": MessageLookupByLibrary.simpleMessage(
      "Here, you can see a summary of what you\'ve accomplished today!",
    ),
    "dayOverViewText3": MessageLookupByLibrary.simpleMessage(
      "Activities that you rated particularly well will be listed here. The tree grows based on your activities, to which you have provided feedback. It starts at the point you\'ve reached from previous days and ends with the progress you\'ve made today :)",
    ),
    "dayOverViewText4": MessageLookupByLibrary.simpleMessage(
      "The graph shows the average of your answers, so you can see how much the day helped you on average based on your activities.",
    ),
    "dayOverViewText5": MessageLookupByLibrary.simpleMessage(
      "At the end of each day, you\'ll receive a notification that will guide you here, or you can tap on the calendar header in a weekly plan :) I hope this overview is helpful for you! :)",
    ),
    "day_reward_message": MessageLookupByLibrary.simpleMessage(
      "Thanks! 😊 \n\n I hope the day was helpful and you felt good \n\n Just take it one day at a time 😊 💪",
    ),
    "delete": MessageLookupByLibrary.simpleMessage("Delete"),
    "deleteActivity": MessageLookupByLibrary.simpleMessage("Delete Activity?"),
    "delete_Entry": MessageLookupByLibrary.simpleMessage("delete Activity"),
    "delete_Termin": MessageLookupByLibrary.simpleMessage(
      "Du you want to really delete:",
    ),
    "delete_week_plan": MessageLookupByLibrary.simpleMessage(
      "Do you really want to delete the Plan for:",
    ),
    "delete_week_plan2": MessageLookupByLibrary.simpleMessage("Are you sure?"),
    "den": MessageLookupByLibrary.simpleMessage("the"),
    "displayADate": m5,
    "displayADateWithYear": m6,
    "displayATime": m7,
    "done": MessageLookupByLibrary.simpleMessage("Success! 🏆"),
    "edit": MessageLookupByLibrary.simpleMessage("Edit"),
    "endTime": MessageLookupByLibrary.simpleMessage("Endtime:"),
    "favorite_comments0": MessageLookupByLibrary.simpleMessage(
      "These Activities were the best for you 🙂:",
    ),
    "favorite_comments1": MessageLookupByLibrary.simpleMessage(
      "These Activities were the calmest 😊:",
    ),
    "favorite_comments2": MessageLookupByLibrary.simpleMessage(
      "These Activities helped you the most 💪:",
    ),
    "firstStartUp_Message1": MessageLookupByLibrary.simpleMessage(
      "You just opened the app for the first time.\nCool that you\'re using this app! :)\nYou can customize things a bit in the settings if you\'d like.\nJust tap the three lines in the top right corner and then select Settings.",
    ),
    "firstStartUp_Message2": MessageLookupByLibrary.simpleMessage(
      "If you need more Help theres a Help-Button in the same menu😊",
    ),
    "friday": MessageLookupByLibrary.simpleMessage("Friday"),
    "generalHelp": MessageLookupByLibrary.simpleMessage("General Help"),
    "gifProgress_case0": m8,
    "gifProgress_case1": m9,
    "gifProgress_case2": m10,
    "gifProgress_case3": m11,
    "gifProgress_case4": m12,
    "gifProgress_case5": m13,
    "gifProgress_case6": m14,
    "gifProgress_title": m15,
    "gifProgress_title_week": MessageLookupByLibrary.simpleMessage(
      "Your progress this week 😇 ",
    ),
    "good_activities_desc": MessageLookupByLibrary.simpleMessage(
      "Activities where you felt good:",
    ),
    "good_activities_desc_variable": m16,
    "help": MessageLookupByLibrary.simpleMessage("Help"),
    "help_activities_desc": MessageLookupByLibrary.simpleMessage(
      "Activities that helped you:",
    ),
    "help_activities_desc_variable": m17,
    "helper_activities0": MessageLookupByLibrary.simpleMessage(
      "You did an amazing job! 🎉",
    ),
    "helper_activities0_name": m18,
    "helper_activities1": MessageLookupByLibrary.simpleMessage(
      "Another step forward! 🌟",
    ),
    "helper_activities10": MessageLookupByLibrary.simpleMessage(
      "You\'re on the right track! 🌟",
    ),
    "helper_activities10_name": m19,
    "helper_activities11": MessageLookupByLibrary.simpleMessage(
      "Great work! 🌟",
    ),
    "helper_activities11_name": m20,
    "helper_activities1_name": m21,
    "helper_activities2": MessageLookupByLibrary.simpleMessage(
      "Great performance, keep going! 🔥",
    ),
    "helper_activities2_name": m22,
    "helper_activities3": MessageLookupByLibrary.simpleMessage(
      "Well done, you\'re pushing through! 🏅",
    ),
    "helper_activities3_name": m23,
    "helper_activities4": MessageLookupByLibrary.simpleMessage(
      "Keep it up! 🚀",
    ),
    "helper_activities4_name": m24,
    "helper_activities5": MessageLookupByLibrary.simpleMessage(
      "Impressive work, you really nailed this! ✨",
    ),
    "helper_activities5_name": m25,
    "helper_activities6": MessageLookupByLibrary.simpleMessage(
      "You deserve recognition! 🥇",
    ),
    "helper_activities6_name": m26,
    "helper_activities7": MessageLookupByLibrary.simpleMessage(
      "Awesome effort, you\'re pushing hard! 🎯",
    ),
    "helper_activities7_name": m27,
    "helper_activities8": MessageLookupByLibrary.simpleMessage(
      "You\'re getting closer to your goal every day! 🚶",
    ),
    "helper_activities8_name": m28,
    "helper_activities9": MessageLookupByLibrary.simpleMessage(
      "You’re so strong, from you! 💪",
    ),
    "helper_activities9_name": m29,
    "home": MessageLookupByLibrary.simpleMessage("Home"),
    "hopeYouHadAGoodDay": m30,
    "iconHelp1": MessageLookupByLibrary.simpleMessage(
      "Shows you that you gave Feedback to every Activity",
    ),
    "iconHelp2": MessageLookupByLibrary.simpleMessage(
      "Shows you that you can give Feedback",
    ),
    "iconHelp3": MessageLookupByLibrary.simpleMessage(
      "Shows you the current week",
    ),
    "iconHelp4": MessageLookupByLibrary.simpleMessage(
      "Shows you the week hasn\'t come yet",
    ),
    "illustration_mascot": MessageLookupByLibrary.simpleMessage("Mascot"),
    "illustration_people": MessageLookupByLibrary.simpleMessage(
      "Illustration People",
    ),
    "illustration_things": MessageLookupByLibrary.simpleMessage(
      "Illustration Things",
    ),
    "legend_Msg0": MessageLookupByLibrary.simpleMessage(
      "How well did it go for you?",
    ),
    "legend_Msg1": MessageLookupByLibrary.simpleMessage("How calm were you?"),
    "legend_Msg1_clip": MessageLookupByLibrary.simpleMessage(
      "How calm\nwere you?",
    ),
    "legend_Msg2": MessageLookupByLibrary.simpleMessage("How helpful was it?"),
    "legend_Msg2_clip": MessageLookupByLibrary.simpleMessage(
      "How helpful\nwas it?",
    ),
    "mainPageDeleteWeek": MessageLookupByLibrary.simpleMessage(
      "Hold the trash symbol to delete an entry.",
    ),
    "mainPageDescription": MessageLookupByLibrary.simpleMessage(
      "This is the main page.",
    ),
    "mainPageInstructions": MessageLookupByLibrary.simpleMessage(
      "Here you can find all your saved weekly plans.",
    ),
    "mainPageQrScanner": MessageLookupByLibrary.simpleMessage(
      "Tapping the button on the bottom-right opens the QR scanner.",
    ),
    "mainPageSwipeOrButton": MessageLookupByLibrary.simpleMessage(
      "You can switch pages by swiping left/right or using the button in the bottom menu.",
    ),
    "mainPageTapOnPlan": MessageLookupByLibrary.simpleMessage(
      "Tapping on a plan will open it.",
    ),
    "mainPage_noEntries_text": MessageLookupByLibrary.simpleMessage(
      "\"You don\'t have any weekplans yet 🙂 \nTap the button on the bottom right to open the QR-Code scanner and import a plan 😊",
    ),
    "monday": MessageLookupByLibrary.simpleMessage("Monday"),
    "noAppointmentsOn": m31,
    "noEntriesYet": MessageLookupByLibrary.simpleMessage("No Entries yet 😉"),
    "noFeedBackOpen": MessageLookupByLibrary.simpleMessage(
      "No Feedback open, awesome!👍",
    ),
    "noFeedbackFromNotification": MessageLookupByLibrary.simpleMessage(
      "The day is over, it\'s great you opened this Notification,\nthat in itself proofs you\'re working to improve your Situation👍 \n Thank You!😉",
    ),
    "notEmpty": MessageLookupByLibrary.simpleMessage("Name mustn\'t "),
    "not_yet_single": MessageLookupByLibrary.simpleMessage("Not here yet 😉"),
    "noti_dayEnd_message": MessageLookupByLibrary.simpleMessage(
      "Once again a day is over. \n Tap on me to see what happend today 😊 \n",
    ),
    "noti_dayEnd_title": m32,
    "noti_noTasks_message": MessageLookupByLibrary.simpleMessage(
      "Today there aren\'t any Activities planed, so lean back and try to relax a bit 🙂",
    ),
    "noti_start_message": MessageLookupByLibrary.simpleMessage(
      "Today the following Activities are planed 🙂 \n",
    ),
    "noti_start_title": m33,
    "noti_termin_messageAfter": m34,
    "noti_termin_messageAt": m35,
    "noti_termin_messageBefore": m36,
    "noti_weekEnd_message": MessageLookupByLibrary.simpleMessage(
      "Super! Another week done\n Tap on me for a Summary of the week",
    ),
    "noti_weekEnd_title": MessageLookupByLibrary.simpleMessage(
      "Week Overview 🎊",
    ),
    "open": MessageLookupByLibrary.simpleMessage("Open Activities"),
    "open_singular": MessageLookupByLibrary.simpleMessage("Open"),
    "overview": MessageLookupByLibrary.simpleMessage("Overview"),
    "qr_desc": MessageLookupByLibrary.simpleMessage(
      "Scan a QR-Code\nto import a Weekly Plan!",
    ),
    "qr_success": MessageLookupByLibrary.simpleMessage(
      "QR-Code scanned successfully! 👍",
    ),
    "questionPageHelpDialog1": MessageLookupByLibrary.simpleMessage(
      "Here you can give feedback on your activities! 😊",
    ),
    "questionPageHelpDialog2": m37,
    "questionPageHelpDialog3": MessageLookupByLibrary.simpleMessage(
      "Each question opens once you\'ve answered the previous one; at the end, you can add a short comment with your thoughts.",
    ),
    "questionPageHelpDialog4": MessageLookupByLibrary.simpleMessage(
      "Slide the slider to the right to save your feedback ✨",
    ),
    "questionPageHelpDialog5": MessageLookupByLibrary.simpleMessage(
      "Good luck! I truly hope this helps you! 🤞😊\n",
    ),
    "questionPage_WellDone": m38,
    "questionPage_WellDone2": m39,
    "questionPage_a0e": MessageLookupByLibrary.simpleMessage("No"),
    "questionPage_a0m": MessageLookupByLibrary.simpleMessage("Later"),
    "questionPage_a0s": MessageLookupByLibrary.simpleMessage("Yes"),
    "questionPage_a1e": MessageLookupByLibrary.simpleMessage("very \n good"),
    "questionPage_a1s": MessageLookupByLibrary.simpleMessage("very \n bad"),
    "questionPage_a2e": MessageLookupByLibrary.simpleMessage("very \n calm"),
    "questionPage_a2s": MessageLookupByLibrary.simpleMessage("very \n excited"),
    "questionPage_a3e": MessageLookupByLibrary.simpleMessage("very \n helpful"),
    "questionPage_a3s": MessageLookupByLibrary.simpleMessage(
      "little \n helpful",
    ),
    "questionPage_comment": MessageLookupByLibrary.simpleMessage(
      "If you\'d like, you can add a short comment here:",
    ),
    "questionPage_commentLabel": MessageLookupByLibrary.simpleMessage(
      "Your Feedback",
    ),
    "questionPage_noQ1": MessageLookupByLibrary.simpleMessage(
      "How did you feel about not doing it?",
    ),
    "questionPage_noQ2": MessageLookupByLibrary.simpleMessage(
      "Did you feel calm or excited about not having done it?",
    ),
    "questionPage_noQ3": MessageLookupByLibrary.simpleMessage(
      "Did it still feel good?",
    ),
    "questionPage_q1": MessageLookupByLibrary.simpleMessage(
      "Could you attend the appointment?",
    ),
    "questionPage_q2": MessageLookupByLibrary.simpleMessage(
      "How did it go for ?",
    ),
    "questionPage_q3": MessageLookupByLibrary.simpleMessage(
      "Were you excited ?",
    ),
    "questionPage_q4": MessageLookupByLibrary.simpleMessage(
      "Did it do you good?",
    ),
    "questionPage_rewardMsg": MessageLookupByLibrary.simpleMessage(
      "Thank you 😊 \n\n You\'ve dealt with your emotions 🥰 \n\n That was really strong of you 💪",
    ),
    "questionPage_rewardMsg2": MessageLookupByLibrary.simpleMessage(
      "Thanks for taking the time! 😊 \n\nReflection is an important part of growth. 💪",
    ),
    "questionPage_rewardMsg3": MessageLookupByLibrary.simpleMessage(
      "Awesome! ⭐ Great to see you sticking with it! 🥰",
    ),
    "questionPage_rewardMsg4": MessageLookupByLibrary.simpleMessage(
      "Thank you! 🙌 Taking time for your emotions is a valuable step. 💪",
    ),
    "questionPage_rewardMsg5": MessageLookupByLibrary.simpleMessage(
      "Glad you made time for this! 🌿",
    ),
    "questionPage_save": MessageLookupByLibrary.simpleMessage("Slide to save"),
    "questionPage_slightly_too_early": MessageLookupByLibrary.simpleMessage(
      "Your activity starts shortly, com back in 15min or later to give Feedback😊 👍",
    ),
    "questionPage_too_early": MessageLookupByLibrary.simpleMessage(
      "You\'re here too early 😊 \nBut cool that you stopped by 👍",
    ),
    "questionPage_too_early1": m40,
    "rewardPopUp_conf": MessageLookupByLibrary.simpleMessage("Well done! ❤️"),
    "rewardPopUp_scroll": MessageLookupByLibrary.simpleMessage(
      "\n Scroll for your progress 😉",
    ),
    "rewardSounds": MessageLookupByLibrary.simpleMessage("Reward Sounds"),
    "saturday": MessageLookupByLibrary.simpleMessage("Saturday"),
    "save": MessageLookupByLibrary.simpleMessage("Save"),
    "settings": MessageLookupByLibrary.simpleMessage("Settings"),
    "settingsSavedAutomatically": MessageLookupByLibrary.simpleMessage(
      "Settings saved automatically!👍",
    ),
    "settingsText1": MessageLookupByLibrary.simpleMessage(
      "These are the settings\n",
    ),
    "settingsText2": MessageLookupByLibrary.simpleMessage(
      "In the \'Theme\' section, you can adjust the appearance of the app. The theme refers to images shown on the home page, offense page, and in the pop-up. The option below lets you display the image only on the home page.",
    ),
    "settingsText3": MessageLookupByLibrary.simpleMessage(
      "The reward sound will always play when the pop-up appears\n\n",
    ),
    "settingsText4": MessageLookupByLibrary.simpleMessage(
      "In the notifications, you can choose when you want to: \n- Receive a summary in the morning\n- Receive a daily summary in the evening\n- Receive a notification before an activity and how often you want to be reminded",
    ),
    "settings_Infos": MessageLookupByLibrary.simpleMessage("Additional Infos"),
    "settings_Infos_dataProtection": MessageLookupByLibrary.simpleMessage(
      "The App doesnt collect and share any of your data, it\'s completly privat!\nThe only way someome can see your data is when you show them your smartphone 😇",
    ),
    "settings_chooseAccent": MessageLookupByLibrary.simpleMessage(
      "Choose an accent color",
    ),
    "settings_darkMode": MessageLookupByLibrary.simpleMessage("Dark Mode"),
    "settings_eveningNotification": MessageLookupByLibrary.simpleMessage(
      "Notification-Time in the evening",
    ),
    "settings_hapticFeedback": MessageLookupByLibrary.simpleMessage(
      "Haptic Feedback",
    ),
    "settings_morningNotification": MessageLookupByLibrary.simpleMessage(
      "Notification-Time in the morning",
    ),
    "settings_name": MessageLookupByLibrary.simpleMessage("Your Name"),
    "settings_name_headline": MessageLookupByLibrary.simpleMessage("Name"),
    "settings_notifications": m41,
    "settings_notificationsForTasks": MessageLookupByLibrary.simpleMessage(
      "Notifications before Activities",
    ),
    "settings_pickAColor": MessageLookupByLibrary.simpleMessage(
      "Pick a Color 🎨",
    ),
    "settings_sound_Standard": MessageLookupByLibrary.simpleMessage("Standard"),
    "settings_sound_gameSound": MessageLookupByLibrary.simpleMessage(
      "Game Sound",
    ),
    "settings_sound_levelDone": MessageLookupByLibrary.simpleMessage(
      "Level End",
    ),
    "settings_sound_levelUp": MessageLookupByLibrary.simpleMessage("Level Up"),
    "settings_sound_longer": MessageLookupByLibrary.simpleMessage(
      "longer Sound",
    ),
    "settings_sound_nothing": MessageLookupByLibrary.simpleMessage("No Sound"),
    "settings_theme": MessageLookupByLibrary.simpleMessage("Theme"),
    "settings_themeOnlyMainPage": MessageLookupByLibrary.simpleMessage(
      "Theme only on the main page",
    ),
    "settings_themePictures": MessageLookupByLibrary.simpleMessage("No Images"),
    "special_activities": MessageLookupByLibrary.simpleMessage(
      "Memorable Activities:",
    ),
    "summary_no_entries": MessageLookupByLibrary.simpleMessage(
      " No Entries yet",
    ),
    "sunday": MessageLookupByLibrary.simpleMessage("Sunday"),
    "taskCompletedOn": m42,
    "tasksCompleted": m43,
    "tasksNotAnsweredOn": m44,
    "tasksPendingFeedback": m45,
    "terminName": MessageLookupByLibrary.simpleMessage("Activity Name"),
    "themeHelperToday": m46,
    "themeHelper_msg0": m47,
    "themeHelper_open_msg0": m48,
    "themeHelper_open_msg1": m49,
    "thursday": MessageLookupByLibrary.simpleMessage("Thursday"),
    "till": MessageLookupByLibrary.simpleMessage("to"),
    "toNotDoIt": MessageLookupByLibrary.simpleMessage("(Don’t do it)"),
    "today": MessageLookupByLibrary.simpleMessage("today"),
    "todayHeadline": MessageLookupByLibrary.simpleMessage("Today"),
    "todayHelpMessage1": MessageLookupByLibrary.simpleMessage("Today Overview"),
    "todayHelpMessage2": MessageLookupByLibrary.simpleMessage(
      "This is your overview for today.\nYou can see what still needs to be done today and what feedback you\'ve already given 👍\n\nHopefully, this helps you a little with structuring your day 🥰",
    ),
    "today_Headline1": MessageLookupByLibrary.simpleMessage("What\'s on today"),
    "today_Headline2": MessageLookupByLibrary.simpleMessage(
      "Already answered today",
    ),
    "today_allAnswered": MessageLookupByLibrary.simpleMessage(
      "Everything answered, AWESOME! 🌟",
    ),
    "today_hopeForGood": MessageLookupByLibrary.simpleMessage(
      "And hopefully, you can still do something that feels good for you 🌱",
    ),
    "today_nothingToAnswer": MessageLookupByLibrary.simpleMessage(
      "There\'s nothing to answer today 😇\nI hope you still have a great day! 😊",
    ),
    "today_nothingToAnswerYet": MessageLookupByLibrary.simpleMessage(
      "There\'s nothing to answer yet, come back soon 😇",
    ),
    "tuesday": MessageLookupByLibrary.simpleMessage("Tuesday"),
    "um": MessageLookupByLibrary.simpleMessage("at"),
    "unanswered": MessageLookupByLibrary.simpleMessage("Unanswered"),
    "unansweredActivities": MessageLookupByLibrary.simpleMessage(
      "On this page you\'ll find activities that haven\'t been evaluated yet.\n Tap on a entry to give feedback",
    ),
    "understood": MessageLookupByLibrary.simpleMessage("Understood"),
    "unexpectedCaseFound": MessageLookupByLibrary.simpleMessage(
      "Congratulations!!! 🎉 You found a case I didn\'t think of! Great job! 😊 If possible, let your therapist or the app developer know which combination led to this case.",
    ),
    "wednesday": MessageLookupByLibrary.simpleMessage("Wednesday"),
    "weekEnd": MessageLookupByLibrary.simpleMessage("Week End"),
    "weekOverViewHeadline": MessageLookupByLibrary.simpleMessage(
      "Weekly Overview",
    ),
    "weekOverViewText1": MessageLookupByLibrary.simpleMessage(
      "This is your weekly overview\n",
    ),
    "weekOverViewText2": MessageLookupByLibrary.simpleMessage(
      "Here, you\'ll see what happened this week.\n",
    ),
    "weekOverViewText3": MessageLookupByLibrary.simpleMessage(
      "At the top, you\'ll see how much feedback you\'ve given, and just giving feedback means you\'ve accomplished something! :)",
    ),
    "weekOverViewText4": MessageLookupByLibrary.simpleMessage(
      "Below, you\'ll find activities that you\'ve given especially good feedback to. The tree on this page shows your progress for the entire week, starting at zero and growing depending on how much feedback you\'ve provided, with every bit of growth counting! ;) The graph shows the average of your daily scores for this week :)",
    ),
    "weekOverViewText5": MessageLookupByLibrary.simpleMessage(
      "At the end of each week, half an hour after the daily overview, you\'ll receive a notification guiding you here. You can also tap the button in the bottom right corner of a weekly plan to come here :) Good luck with giving feedback! I hope you can more easily find activities and things that bring you joy or help you in other ways :)",
    ),
    "weekOverViewText6": MessageLookupByLibrary.simpleMessage(
      "Good luck with giving feedback! I hope you can more easily find activities and things that bring you joy or help you in other ways :)",
    ),
    "weekOverView_leftAnswers": m50,
    "weekOverView_noAnswers": MessageLookupByLibrary.simpleMessage(
      "You haven\'t yet evaluated any activity this week\n Please come back later 🙋♂️",
    ),
    "weekOverView_scroll": MessageLookupByLibrary.simpleMessage(
      "\n\n Scroll down to get more info ;)",
    ),
    "weekOverView_summary": MessageLookupByLibrary.simpleMessage(
      "This week you completed\n",
    ),
    "weekOverView_summary_part2": m51,
    "weekOverView_tooEarly": MessageLookupByLibrary.simpleMessage(
      "The week isn\'t here yet. Please come back later :)",
    ),
    "weekPlanActivitiesWithExclamation": MessageLookupByLibrary.simpleMessage(
      "• Activities with an exclamation mark can still be assessed 😊",
    ),
    "weekPlanDescription": MessageLookupByLibrary.simpleMessage(
      "This is your weekly plan",
    ),
    "weekPlanGrayActivities": MessageLookupByLibrary.simpleMessage(
      "• Gray activities indicate that their time hasn\'t come yet.",
    ),
    "weekPlanGreenActivities": MessageLookupByLibrary.simpleMessage(
      "• Green activities mean you\'ve already provided feedback.",
    ),
    "weekPlanInstructions": MessageLookupByLibrary.simpleMessage(
      "Here you can see all activities planned for this week.",
    ),
    "weekPlanTapForDayView": MessageLookupByLibrary.simpleMessage(
      "Tapping on the header opens a day overview.",
    ),
    "weekPlanTapForWeekView": MessageLookupByLibrary.simpleMessage(
      "Tapping the button on the bottom-right opens an overview for the week.",
    ),
    "weekStart": MessageLookupByLibrary.simpleMessage("Week Start"),
    "week_reward_message": MessageLookupByLibrary.simpleMessage(
      "Thanks! 😊 \n\n I hope this week did you good and you made progress \n\n You\'re doing great one week at a time 💪",
    ),
    "weeklyPlans": MessageLookupByLibrary.simpleMessage("Weekly Plans"),
    "weekly_values": MessageLookupByLibrary.simpleMessage("Weekly Values"),
  };
}
