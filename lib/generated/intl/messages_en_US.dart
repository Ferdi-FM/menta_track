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

  static String m0(name) =>
      "The day hasn\'t arrived yet 😉 \n Still, it\'s nice that you\'re checking in early ${name} :)";

  static String m1(date) => "${date}";

  static String m2(date) => "${date}";

  static String m3(date) => "${date}";

  static String m4(name) => "Great start ${name}! Keep it up! 🎉";

  static String m5(name) => "A quarter achieved ${name}, fantastic job! 🌟";

  static String m6(name) => "More than a third done ${name}, great effort! 💪";

  static String m7(name) => "Halfway there ${name}! Keep going! 🔥";

  static String m8(name) => "Three quarters done ${name}, almost there! 🌟";

  static String m9(name) =>
      "Almost finished ${name}! You\'ve worked hard, just a little more to go! 🚀";

  static String m10(name) => "Congratulations ${name}! You did it! 🏆🎉";

  static String m11(count) =>
      "${Intl.plural(count, zero: 'Dein Progress bis zu diesem Tag 😇', other: 'Dein Progress an diesem Tag 😇')}";

  static String m12(name) =>
      "Awesome job, ${name}!\nYou’re on the right track! 🌟";

  static String m13(name) => "Fantastic work,\n ${name}! 💪";

  static String m14(name) => "Great work,\n ${name}! 🌟";

  static String m15(name) =>
      "Impressive, ${name}!\nYour hard work will pay off! 💪";

  static String m16(name) => "${name}, you did an amazing job!\nKeep going! 🎉";

  static String m17(name) =>
      "Wow, ${name}! You’re setting a new normal every time! 🚀";

  static String m18(name) => "${name}, you nailed this!\nFantastic progress! ✨";

  static String m19(name) => "${name}, your performance is impressive! 🏅";

  static String m20(name) => "Great work,\n ${name}! 🏆";

  static String m21(name) => "${name}, you\'re doing great!\nStay focused! 🔥";

  static String m22(name) =>
      "You’re rocking it, ${name}!\n One step at a time! 🎯";

  static String m23(name) => "${name}, you’ve got this!\nIt’s awesome! 💥";

  static String m24(count, name) =>
      "I hope you had a good day ${Intl.plural(count, zero: '', other: ', ${name}')} 😊";

  static String m25(date) => "You had no appointments planned ${date}.";

  static String m26(date) => "\$🎉 Activity Summary for the ${date}";

  static String m27(date) => "📅 Activities on the ${date}";

  static String m28(terminName) =>
      "${terminName} is over. I hope it worked out and helped you 😊\nPlease tap on me and take a second to reflect\nIt\'s not bad if you coudn\'t do the Activity, the reflection itself is more than most people can do🤘";

  static String m29(terminName) => "It\'s time for ${terminName}! Good Luck!🤞";

  static String m30(terminName, count) =>
      "${terminName} is on in ${count} minutens. You got this!🤞";

  static String m31(count) =>
      "${Intl.plural(count, zero: 'Notification', other: 'Notifications')}";

  static String m32(date) => "${date} you completed\n";

  static String m33(count) =>
      "${Intl.plural(count, one: '\nTask', other: '\nTasks')}";

  static String m34(count, date) =>
      "You haven\'t answered ${Intl.plural(count, one: 'your activity', other: '${count} activites')} ${date} yet.";

  static String m35(count) =>
      "\n\n(If you like, you can still give feedback on ${Intl.plural(count, one: 'one activity', other: '${count} activities')} on the \'Open\' page 😊)";

  static String m36(name) =>
      "${name} here is a list of all your weekly plans 😊";

  static String m37(name) =>
      "${name} here are all the appointments where you haven\'t given feedback yet 😉\n";

  static String m38(count) =>
      "${Intl.plural(count, zero: 'Currently there is nothing to answer 😉', one: '${count} appointment is left 😉', other: '${count} appointments are left 😉')}";

  static String m39(count) =>
      "${Intl.plural(count, zero: '', one: '\n\n If you like, you can still give feedback on ${count} activity', other: '\n\n If you like, you can still give feedback on ${count} activities')}";

  static String m40(count, randomText) =>
      "${Intl.plural(count, one: 'Task\n\n ${randomText}', other: 'Tasks\n\n ${randomText}')}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "accept": MessageLookupByLibrary.simpleMessage("Accept"),
    "activitySummaryDescription": MessageLookupByLibrary.simpleMessage(
      "This is your summary of all weeks.",
    ),
    "activitySummaryGoodFeedback": MessageLookupByLibrary.simpleMessage(
      "The list below notes activities you\'ve evaluated particularly well.",
    ),
    "activitySummaryGraphDescription": MessageLookupByLibrary.simpleMessage(
      "The chart displays your average values for each week.",
    ),
    "am": MessageLookupByLibrary.simpleMessage("on the"),
    "appTitle": MessageLookupByLibrary.simpleMessage("Menta Track"),
    "back": MessageLookupByLibrary.simpleMessage("Back"),
    "bestActivities": MessageLookupByLibrary.simpleMessage("Best Activities"),
    "calm_activities_desc": MessageLookupByLibrary.simpleMessage(
      "Activities where you felt calm:",
    ),
    "cancel": MessageLookupByLibrary.simpleMessage("Cancel"),
    "checkPendingFeedback": MessageLookupByLibrary.simpleMessage(
      "Check on the home page under \'Open\' or in the \'Week Overview\' to give feedback on an activity 👍",
    ),
    "daily_Values": MessageLookupByLibrary.simpleMessage("Daily Values"),
    "dayNotYetArrived": m0,
    "day_reward_message": MessageLookupByLibrary.simpleMessage(
      "Thanks! 😊 \n\n I hope the day was helpful and you felt good \n\n Just take it one day at a time 😊 💪",
    ),
    "delete": MessageLookupByLibrary.simpleMessage("Delete"),
    "delete_week_plan": MessageLookupByLibrary.simpleMessage(
      "Do you really want to delete the Plan for:",
    ),
    "delete_week_plan2": MessageLookupByLibrary.simpleMessage("Are you sure?"),
    "displayADate": m1,
    "displayADateWithYear": m2,
    "displayATime": m3,
    "favorite_comments0": MessageLookupByLibrary.simpleMessage(
      "These Activities were the best for you 🙂:",
    ),
    "favorite_comments1": MessageLookupByLibrary.simpleMessage(
      "These Activities were the calmest 😊:",
    ),
    "favorite_comments2": MessageLookupByLibrary.simpleMessage(
      "These Activities helped you the most 💪:",
    ),
    "friday": MessageLookupByLibrary.simpleMessage("Friday"),
    "generalHelp": MessageLookupByLibrary.simpleMessage("General Help"),
    "gifProgress_case0": m4,
    "gifProgress_case1": m5,
    "gifProgress_case2": m6,
    "gifProgress_case3": m7,
    "gifProgress_case4": m8,
    "gifProgress_case5": m9,
    "gifProgress_case6": m10,
    "gifProgress_title": m11,
    "gifProgress_title_week": MessageLookupByLibrary.simpleMessage(
      "Your progress this week 😇 ",
    ),
    "good_activities_desc": MessageLookupByLibrary.simpleMessage(
      "Activities where you felt good:",
    ),
    "help": MessageLookupByLibrary.simpleMessage("Help"),
    "help_activities_desc": MessageLookupByLibrary.simpleMessage(
      "Activities that helped you:",
    ),
    "helper_activities0": MessageLookupByLibrary.simpleMessage(
      "You did an amazing job! 🎉",
    ),
    "helper_activities0_name": m12,
    "helper_activities1": MessageLookupByLibrary.simpleMessage(
      "Another step forward! 🌟",
    ),
    "helper_activities10": MessageLookupByLibrary.simpleMessage(
      "You\'re on the right track! 🌟",
    ),
    "helper_activities10_name": m13,
    "helper_activities11": MessageLookupByLibrary.simpleMessage(
      "Great work! 🌟",
    ),
    "helper_activities11_name": m14,
    "helper_activities1_name": m15,
    "helper_activities2": MessageLookupByLibrary.simpleMessage(
      "Great performance, keep going! 🔥",
    ),
    "helper_activities2_name": m16,
    "helper_activities3": MessageLookupByLibrary.simpleMessage(
      "Well done, you\'re pushing through! 🏅",
    ),
    "helper_activities3_name": m17,
    "helper_activities4": MessageLookupByLibrary.simpleMessage(
      "Keep it up! 🚀",
    ),
    "helper_activities4_name": m18,
    "helper_activities5": MessageLookupByLibrary.simpleMessage(
      "Impressive work, you really nailed this! ✨",
    ),
    "helper_activities5_name": m19,
    "helper_activities6": MessageLookupByLibrary.simpleMessage(
      "You deserve recognition! 🥇",
    ),
    "helper_activities6_name": m20,
    "helper_activities7": MessageLookupByLibrary.simpleMessage(
      "Awesome effort, you\'re pushing hard! 🎯",
    ),
    "helper_activities7_name": m21,
    "helper_activities8": MessageLookupByLibrary.simpleMessage(
      "You\'re getting closer to your goal every day! 🚶♀️",
    ),
    "helper_activities8_name": m22,
    "helper_activities9": MessageLookupByLibrary.simpleMessage(
      "You’re so strong, from you! 💪",
    ),
    "helper_activities9_name": m23,
    "home": MessageLookupByLibrary.simpleMessage("Home"),
    "hopeYouHadAGoodDay": m24,
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
    "monday": MessageLookupByLibrary.simpleMessage("Monday"),
    "noAppointmentsOn": m25,
    "noti_dayEnd_message": MessageLookupByLibrary.simpleMessage(
      "Once again a day is over. \n Tap on me to see what happend today 😊 \n",
    ),
    "noti_dayEnd_title": m26,
    "noti_noTasks_message": MessageLookupByLibrary.simpleMessage(
      "Today there aren\'t any Activities planed, so lean back and try to relax a bit 🙂",
    ),
    "noti_start_message": MessageLookupByLibrary.simpleMessage(
      "Today the following Activities are planed 🙂 \n",
    ),
    "noti_start_title": m27,
    "noti_termin_messageAfter": m28,
    "noti_termin_messageAt": m29,
    "noti_termin_messageBefore": m30,
    "noti_weekEnd_message": MessageLookupByLibrary.simpleMessage(
      "Super! Another week done\n Tap on me for a Summary of the week",
    ),
    "noti_weekEnd_title": MessageLookupByLibrary.simpleMessage(
      "Week Overview 🎊",
    ),
    "open": MessageLookupByLibrary.simpleMessage("Open Activities"),
    "overview": MessageLookupByLibrary.simpleMessage("Overview"),
    "qr_desc": MessageLookupByLibrary.simpleMessage(
      "Scan a QR-Code\nto import a Weekly Plan!",
    ),
    "qr_success": MessageLookupByLibrary.simpleMessage(
      "QR-Code scanned successfully! 👍",
    ),
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
    "questionPage_save": MessageLookupByLibrary.simpleMessage("Slide to save"),
    "questionPage_too_early": MessageLookupByLibrary.simpleMessage(
      "You\'re here too early 😊 \nBut cool that you stopped by 👍",
    ),
    "rewardPopUp_conf": MessageLookupByLibrary.simpleMessage("Well done! ❤️"),
    "rewardPopUp_scroll": MessageLookupByLibrary.simpleMessage(
      "\n Scroll for your progress 😉",
    ),
    "saturday": MessageLookupByLibrary.simpleMessage("Saturday"),
    "settings": MessageLookupByLibrary.simpleMessage("Settings"),
    "settings_chooseAccent": MessageLookupByLibrary.simpleMessage(
      "Choose an accent color",
    ),
    "settings_darkMode": MessageLookupByLibrary.simpleMessage("Dark Mode"),
    "settings_eveningNotification": MessageLookupByLibrary.simpleMessage(
      "Notification-Time in the evening",
    ),
    "settings_morningNotification": MessageLookupByLibrary.simpleMessage(
      "Notification-Time in the morning",
    ),
    "settings_name": MessageLookupByLibrary.simpleMessage("Your Name"),
    "settings_notifications": m31,
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
    "taskCompletedOn": m32,
    "tasksCompleted": m33,
    "tasksNotAnsweredOn": m34,
    "tasksPendingFeedback": m35,
    "themeHelper_msg0": m36,
    "themeHelper_open_msg0": m37,
    "themeHelper_open_msg1": m38,
    "thursday": MessageLookupByLibrary.simpleMessage("Thursday"),
    "till": MessageLookupByLibrary.simpleMessage("to"),
    "today": MessageLookupByLibrary.simpleMessage("today"),
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
    "weekOverView_leftAnswers": m39,
    "weekOverView_noAnswers": MessageLookupByLibrary.simpleMessage(
      "You haven\'t yet evaluated any activity this week\n Please come back later 🙋♂️",
    ),
    "weekOverView_scroll": MessageLookupByLibrary.simpleMessage(
      "\n\n Scroll down to get more info ;)",
    ),
    "weekOverView_summary": MessageLookupByLibrary.simpleMessage(
      "This week you completed\n",
    ),
    "weekOverView_summary_part2": m40,
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
    "week_reward_message": MessageLookupByLibrary.simpleMessage(
      "Thanks! 😊 \n\n Ich hope this week did you good and you made progress \n\n You\'re doing great one week at a time 💪",
    ),
    "weeklyPlans": MessageLookupByLibrary.simpleMessage("Weekly Plans"),
    "weekly_values": MessageLookupByLibrary.simpleMessage("Weekly Values"),
  };
}
