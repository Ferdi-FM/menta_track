// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(
      _current != null,
      'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.',
    );
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name =
        (locale.countryCode?.isEmpty ?? false)
            ? locale.languageCode
            : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(
      instance != null,
      'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?',
    );
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `Menta Track`
  String get appTitle {
    return Intl.message('Menta Track', name: 'appTitle', desc: '', args: []);
  }

  /// `Unanswered`
  String get unanswered {
    return Intl.message('Unanswered', name: 'unanswered', desc: '', args: []);
  }

  /// `Weekly Plans`
  String get weeklyPlans {
    return Intl.message(
      'Weekly Plans',
      name: 'weeklyPlans',
      desc: '',
      args: [],
    );
  }

  /// `Best Activities`
  String get bestActivities {
    return Intl.message(
      'Best Activities',
      name: 'bestActivities',
      desc: '',
      args: [],
    );
  }

  /// `Help`
  String get help {
    return Intl.message('Help', name: 'help', desc: '', args: []);
  }

  /// `Settings`
  String get settings {
    return Intl.message('Settings', name: 'settings', desc: '', args: []);
  }

  /// `Open Activities`
  String get open {
    return Intl.message('Open Activities', name: 'open', desc: '', args: []);
  }

  /// `Home`
  String get home {
    return Intl.message('Home', name: 'home', desc: '', args: []);
  }

  /// `Overview`
  String get overview {
    return Intl.message('Overview', name: 'overview', desc: '', args: []);
  }

  /// `on the`
  String get am {
    return Intl.message('on the', name: 'am', desc: '', args: []);
  }

  /// `at`
  String get um {
    return Intl.message('at', name: 'um', desc: '', args: []);
  }

  /// `Cancel`
  String get cancel {
    return Intl.message('Cancel', name: 'cancel', desc: '', args: []);
  }

  /// `Back`
  String get back {
    return Intl.message('Back', name: 'back', desc: '', args: []);
  }

  /// `Accept`
  String get accept {
    return Intl.message('Accept', name: 'accept', desc: '', args: []);
  }

  /// `Understood`
  String get understood {
    return Intl.message('Understood', name: 'understood', desc: '', args: []);
  }

  /// `{date}`
  String displayADateWithYear(DateTime date) {
    final DateFormat dateDateFormat = DateFormat(
      'dd.MM.yy',
      Intl.getCurrentLocale(),
    );
    final String dateString = dateDateFormat.format(date);

    return Intl.message(
      '$dateString',
      name: 'displayADateWithYear',
      desc: '',
      args: [dateString],
    );
  }

  /// `{date}`
  String displayADate(DateTime date) {
    final DateFormat dateDateFormat = DateFormat(
      'dd.MM',
      Intl.getCurrentLocale(),
    );
    final String dateString = dateDateFormat.format(date);

    return Intl.message(
      '$dateString',
      name: 'displayADate',
      desc: '',
      args: [dateString],
    );
  }

  /// `{date}`
  String displayATime(DateTime date) {
    final DateFormat dateDateFormat = DateFormat(
      'HH:mm',
      Intl.getCurrentLocale(),
    );
    final String dateString = dateDateFormat.format(date);

    return Intl.message(
      '$dateString',
      name: 'displayATime',
      desc: '',
      args: [dateString],
    );
  }

  /// `to`
  String get till {
    return Intl.message('to', name: 'till', desc: '', args: []);
  }

  /// ` No Entries yet`
  String get summary_no_entries {
    return Intl.message(
      ' No Entries yet',
      name: 'summary_no_entries',
      desc: '',
      args: [],
    );
  }

  /// `Memorable Activities:`
  String get special_activities {
    return Intl.message(
      'Memorable Activities:',
      name: 'special_activities',
      desc: '',
      args: [],
    );
  }

  /// `Activities where you felt good:`
  String get good_activities_desc {
    return Intl.message(
      'Activities where you felt good:',
      name: 'good_activities_desc',
      desc: '',
      args: [],
    );
  }

  /// `Activities where you felt calm:`
  String get calm_activities_desc {
    return Intl.message(
      'Activities where you felt calm:',
      name: 'calm_activities_desc',
      desc: '',
      args: [],
    );
  }

  /// `Activities that helped you:`
  String get help_activities_desc {
    return Intl.message(
      'Activities that helped you:',
      name: 'help_activities_desc',
      desc: '',
      args: [],
    );
  }

  /// `Monday`
  String get monday {
    return Intl.message('Monday', name: 'monday', desc: '', args: []);
  }

  /// `Tuesday`
  String get tuesday {
    return Intl.message('Tuesday', name: 'tuesday', desc: '', args: []);
  }

  /// `Wednesday`
  String get wednesday {
    return Intl.message('Wednesday', name: 'wednesday', desc: '', args: []);
  }

  /// `Thursday`
  String get thursday {
    return Intl.message('Thursday', name: 'thursday', desc: '', args: []);
  }

  /// `Friday`
  String get friday {
    return Intl.message('Friday', name: 'friday', desc: '', args: []);
  }

  /// `Saturday`
  String get saturday {
    return Intl.message('Saturday', name: 'saturday', desc: '', args: []);
  }

  /// `Sunday`
  String get sunday {
    return Intl.message('Sunday', name: 'sunday', desc: '', args: []);
  }

  /// `Scan a QR-Code\nto import a Weekly Plan!`
  String get qr_desc {
    return Intl.message(
      'Scan a QR-Code\nto import a Weekly Plan!',
      name: 'qr_desc',
      desc: '',
      args: [],
    );
  }

  /// `QR-Code scanned successfully! 👍`
  String get qr_success {
    return Intl.message(
      'QR-Code scanned successfully! 👍',
      name: 'qr_success',
      desc: '',
      args: [],
    );
  }

  /// `Thank you 😊 \n\n You've dealt with your emotions 🥰 \n\n That was really strong of you 💪`
  String get questionPage_rewardMsg {
    return Intl.message(
      'Thank you 😊 \n\n You\'ve dealt with your emotions 🥰 \n\n That was really strong of you 💪',
      name: 'questionPage_rewardMsg',
      desc: '',
      args: [],
    );
  }

  /// `Could you attend the appointment?`
  String get questionPage_q1 {
    return Intl.message(
      'Could you attend the appointment?',
      name: 'questionPage_q1',
      desc: '',
      args: [],
    );
  }

  /// `How did it go for ?`
  String get questionPage_q2 {
    return Intl.message(
      'How did it go for ?',
      name: 'questionPage_q2',
      desc: '',
      args: [],
    );
  }

  /// `Were you excited ?`
  String get questionPage_q3 {
    return Intl.message(
      'Were you excited ?',
      name: 'questionPage_q3',
      desc: '',
      args: [],
    );
  }

  /// `Did it do you good?`
  String get questionPage_q4 {
    return Intl.message(
      'Did it do you good?',
      name: 'questionPage_q4',
      desc: '',
      args: [],
    );
  }

  /// `very \n bad`
  String get questionPage_a1s {
    return Intl.message(
      'very \n bad',
      name: 'questionPage_a1s',
      desc: '',
      args: [],
    );
  }

  /// `very \n excited`
  String get questionPage_a2s {
    return Intl.message(
      'very \n excited',
      name: 'questionPage_a2s',
      desc: '',
      args: [],
    );
  }

  /// `little \n helpful`
  String get questionPage_a3s {
    return Intl.message(
      'little \n helpful',
      name: 'questionPage_a3s',
      desc: '',
      args: [],
    );
  }

  /// `very \n good`
  String get questionPage_a1e {
    return Intl.message(
      'very \n good',
      name: 'questionPage_a1e',
      desc: '',
      args: [],
    );
  }

  /// `very \n calm`
  String get questionPage_a2e {
    return Intl.message(
      'very \n calm',
      name: 'questionPage_a2e',
      desc: '',
      args: [],
    );
  }

  /// `very \n helpful`
  String get questionPage_a3e {
    return Intl.message(
      'very \n helpful',
      name: 'questionPage_a3e',
      desc: '',
      args: [],
    );
  }

  /// `Yes`
  String get questionPage_a0s {
    return Intl.message('Yes', name: 'questionPage_a0s', desc: '', args: []);
  }

  /// `Later`
  String get questionPage_a0m {
    return Intl.message('Later', name: 'questionPage_a0m', desc: '', args: []);
  }

  /// `No`
  String get questionPage_a0e {
    return Intl.message('No', name: 'questionPage_a0e', desc: '', args: []);
  }

  /// `You're here too early 😊 \nBut cool that you stopped by 👍`
  String get questionPage_too_early {
    return Intl.message(
      'You\'re here too early 😊 \nBut cool that you stopped by 👍',
      name: 'questionPage_too_early',
      desc: '',
      args: [],
    );
  }

  /// `If you'd like, you can add a short comment here:`
  String get questionPage_comment {
    return Intl.message(
      'If you\'d like, you can add a short comment here:',
      name: 'questionPage_comment',
      desc: '',
      args: [],
    );
  }

  /// `Your Feedback`
  String get questionPage_commentLabel {
    return Intl.message(
      'Your Feedback',
      name: 'questionPage_commentLabel',
      desc: '',
      args: [],
    );
  }

  /// `Slide to save`
  String get questionPage_save {
    return Intl.message(
      'Slide to save',
      name: 'questionPage_save',
      desc: '',
      args: [],
    );
  }

  /// `Your Name`
  String get settings_name {
    return Intl.message('Your Name', name: 'settings_name', desc: '', args: []);
  }

  /// `Theme`
  String get settings_theme {
    return Intl.message('Theme', name: 'settings_theme', desc: '', args: []);
  }

  /// `No Images`
  String get settings_themePictures {
    return Intl.message(
      'No Images',
      name: 'settings_themePictures',
      desc: '',
      args: [],
    );
  }

  /// `Theme only on the main page`
  String get settings_themeOnlyMainPage {
    return Intl.message(
      'Theme only on the main page',
      name: 'settings_themeOnlyMainPage',
      desc: '',
      args: [],
    );
  }

  /// `Dark Mode`
  String get settings_darkMode {
    return Intl.message(
      'Dark Mode',
      name: 'settings_darkMode',
      desc: '',
      args: [],
    );
  }

  /// `Choose an accent color`
  String get settings_chooseAccent {
    return Intl.message(
      'Choose an accent color',
      name: 'settings_chooseAccent',
      desc: '',
      args: [],
    );
  }

  /// `{count, plural, =0{Notification} other{Notifications}}`
  String settings_notifications(num count) {
    return Intl.plural(
      count,
      zero: 'Notification',
      other: 'Notifications',
      name: 'settings_notifications',
      desc: '',
      args: [count],
    );
  }

  /// `This is the main page.`
  String get mainPageDescription {
    return Intl.message(
      'This is the main page.',
      name: 'mainPageDescription',
      desc: '',
      args: [],
    );
  }

  /// `Here you can find all your saved weekly plans.`
  String get mainPageInstructions {
    return Intl.message(
      'Here you can find all your saved weekly plans.',
      name: 'mainPageInstructions',
      desc: '',
      args: [],
    );
  }

  /// `Tapping the button on the bottom-right opens the QR scanner.`
  String get mainPageQrScanner {
    return Intl.message(
      'Tapping the button on the bottom-right opens the QR scanner.',
      name: 'mainPageQrScanner',
      desc: '',
      args: [],
    );
  }

  /// `Tapping on a plan will open it.`
  String get mainPageTapOnPlan {
    return Intl.message(
      'Tapping on a plan will open it.',
      name: 'mainPageTapOnPlan',
      desc: '',
      args: [],
    );
  }

  /// `Hold the trash symbol to delete an entry.`
  String get mainPageDeleteWeek {
    return Intl.message(
      'Hold the trash symbol to delete an entry.',
      name: 'mainPageDeleteWeek',
      desc: '',
      args: [],
    );
  }

  /// `You can switch pages by swiping left/right or using the button in the bottom menu.`
  String get mainPageSwipeOrButton {
    return Intl.message(
      'You can switch pages by swiping left/right or using the button in the bottom menu.',
      name: 'mainPageSwipeOrButton',
      desc: '',
      args: [],
    );
  }

  /// `On this page you'll find activities that haven't been evaluated yet.\n Tap on a entry to give feedback`
  String get unansweredActivities {
    return Intl.message(
      'On this page you\'ll find activities that haven\'t been evaluated yet.\n Tap on a entry to give feedback',
      name: 'unansweredActivities',
      desc: '',
      args: [],
    );
  }

  /// `This is your weekly plan`
  String get weekPlanDescription {
    return Intl.message(
      'This is your weekly plan',
      name: 'weekPlanDescription',
      desc: '',
      args: [],
    );
  }

  /// `Here you can see all activities planned for this week.`
  String get weekPlanInstructions {
    return Intl.message(
      'Here you can see all activities planned for this week.',
      name: 'weekPlanInstructions',
      desc: '',
      args: [],
    );
  }

  /// `• Gray activities indicate that their time hasn't come yet.`
  String get weekPlanGrayActivities {
    return Intl.message(
      '• Gray activities indicate that their time hasn\'t come yet.',
      name: 'weekPlanGrayActivities',
      desc: '',
      args: [],
    );
  }

  /// `• Green activities mean you've already provided feedback.`
  String get weekPlanGreenActivities {
    return Intl.message(
      '• Green activities mean you\'ve already provided feedback.',
      name: 'weekPlanGreenActivities',
      desc: '',
      args: [],
    );
  }

  /// `• Activities with an exclamation mark can still be assessed 😊`
  String get weekPlanActivitiesWithExclamation {
    return Intl.message(
      '• Activities with an exclamation mark can still be assessed 😊',
      name: 'weekPlanActivitiesWithExclamation',
      desc: '',
      args: [],
    );
  }

  /// `Tapping on the header opens a day overview.`
  String get weekPlanTapForDayView {
    return Intl.message(
      'Tapping on the header opens a day overview.',
      name: 'weekPlanTapForDayView',
      desc: '',
      args: [],
    );
  }

  /// `Tapping the button on the bottom-right opens an overview for the week.`
  String get weekPlanTapForWeekView {
    return Intl.message(
      'Tapping the button on the bottom-right opens an overview for the week.',
      name: 'weekPlanTapForWeekView',
      desc: '',
      args: [],
    );
  }

  /// `This is your summary of all weeks.`
  String get activitySummaryDescription {
    return Intl.message(
      'This is your summary of all weeks.',
      name: 'activitySummaryDescription',
      desc: '',
      args: [],
    );
  }

  /// `The chart displays your average values for each week.`
  String get activitySummaryGraphDescription {
    return Intl.message(
      'The chart displays your average values for each week.',
      name: 'activitySummaryGraphDescription',
      desc: '',
      args: [],
    );
  }

  /// `The list below notes activities you've evaluated particularly well.`
  String get activitySummaryGoodFeedback {
    return Intl.message(
      'The list below notes activities you\'ve evaluated particularly well.',
      name: 'activitySummaryGoodFeedback',
      desc: '',
      args: [],
    );
  }

  /// `General Help`
  String get generalHelp {
    return Intl.message(
      'General Help',
      name: 'generalHelp',
      desc: '',
      args: [],
    );
  }

  /// `\n Scroll for your progress 😉`
  String get rewardPopUp_scroll {
    return Intl.message(
      '\n Scroll for your progress 😉',
      name: 'rewardPopUp_scroll',
      desc: '',
      args: [],
    );
  }

  /// `Well done! ❤️`
  String get rewardPopUp_conf {
    return Intl.message(
      'Well done! ❤️',
      name: 'rewardPopUp_conf',
      desc: '',
      args: [],
    );
  }

  /// `{count, plural, =0{Dein Progress bis zu diesem Tag 😇} other{Dein Progress an diesem Tag 😇}}`
  String gifProgress_title(num count) {
    return Intl.plural(
      count,
      zero: 'Dein Progress bis zu diesem Tag 😇',
      other: 'Dein Progress an diesem Tag 😇',
      name: 'gifProgress_title',
      desc: '',
      args: [count],
    );
  }

  /// `Your progress this week 😇 `
  String get gifProgress_title_week {
    return Intl.message(
      'Your progress this week 😇 ',
      name: 'gifProgress_title_week',
      desc: '',
      args: [],
    );
  }

  /// `Great start {name}! Keep it up! 🎉`
  String gifProgress_case0(Object name) {
    return Intl.message(
      'Great start $name! Keep it up! 🎉',
      name: 'gifProgress_case0',
      desc: '',
      args: [name],
    );
  }

  /// `A quarter achieved {name}, fantastic job! 🌟`
  String gifProgress_case1(Object name) {
    return Intl.message(
      'A quarter achieved $name, fantastic job! 🌟',
      name: 'gifProgress_case1',
      desc: '',
      args: [name],
    );
  }

  /// `More than a third done {name}, great effort! 💪`
  String gifProgress_case2(Object name) {
    return Intl.message(
      'More than a third done $name, great effort! 💪',
      name: 'gifProgress_case2',
      desc: '',
      args: [name],
    );
  }

  /// `Halfway there {name}! Keep going! 🔥`
  String gifProgress_case3(Object name) {
    return Intl.message(
      'Halfway there $name! Keep going! 🔥',
      name: 'gifProgress_case3',
      desc: '',
      args: [name],
    );
  }

  /// `Three quarters done {name}, almost there! 🌟`
  String gifProgress_case4(Object name) {
    return Intl.message(
      'Three quarters done $name, almost there! 🌟',
      name: 'gifProgress_case4',
      desc: '',
      args: [name],
    );
  }

  /// `Almost finished {name}! You've worked hard, just a little more to go! 🚀`
  String gifProgress_case5(Object name) {
    return Intl.message(
      'Almost finished $name! You\'ve worked hard, just a little more to go! 🚀',
      name: 'gifProgress_case5',
      desc: '',
      args: [name],
    );
  }

  /// `Congratulations {name}! You did it! 🏆🎉`
  String gifProgress_case6(Object name) {
    return Intl.message(
      'Congratulations $name! You did it! 🏆🎉',
      name: 'gifProgress_case6',
      desc: '',
      args: [name],
    );
  }

  /// `You did an amazing job! 🎉`
  String get helper_activities0 {
    return Intl.message(
      'You did an amazing job! 🎉',
      name: 'helper_activities0',
      desc: '',
      args: [],
    );
  }

  /// `Another step forward! 🌟`
  String get helper_activities1 {
    return Intl.message(
      'Another step forward! 🌟',
      name: 'helper_activities1',
      desc: '',
      args: [],
    );
  }

  /// `Great performance, keep going! 🔥`
  String get helper_activities2 {
    return Intl.message(
      'Great performance, keep going! 🔥',
      name: 'helper_activities2',
      desc: '',
      args: [],
    );
  }

  /// `Well done, you're pushing through! 🏅`
  String get helper_activities3 {
    return Intl.message(
      'Well done, you\'re pushing through! 🏅',
      name: 'helper_activities3',
      desc: '',
      args: [],
    );
  }

  /// `Keep it up! 🚀`
  String get helper_activities4 {
    return Intl.message(
      'Keep it up! 🚀',
      name: 'helper_activities4',
      desc: '',
      args: [],
    );
  }

  /// `Impressive work, you really nailed this! ✨`
  String get helper_activities5 {
    return Intl.message(
      'Impressive work, you really nailed this! ✨',
      name: 'helper_activities5',
      desc: '',
      args: [],
    );
  }

  /// `You deserve recognition! 🥇`
  String get helper_activities6 {
    return Intl.message(
      'You deserve recognition! 🥇',
      name: 'helper_activities6',
      desc: '',
      args: [],
    );
  }

  /// `Awesome effort, you're pushing hard! 🎯`
  String get helper_activities7 {
    return Intl.message(
      'Awesome effort, you\'re pushing hard! 🎯',
      name: 'helper_activities7',
      desc: '',
      args: [],
    );
  }

  /// `You're getting closer to your goal every day! 🚶♀️`
  String get helper_activities8 {
    return Intl.message(
      'You\'re getting closer to your goal every day! 🚶♀️',
      name: 'helper_activities8',
      desc: '',
      args: [],
    );
  }

  /// `You’re so strong, from you! 💪`
  String get helper_activities9 {
    return Intl.message(
      'You’re so strong, from you! 💪',
      name: 'helper_activities9',
      desc: '',
      args: [],
    );
  }

  /// `You're on the right track! 🌟`
  String get helper_activities10 {
    return Intl.message(
      'You\'re on the right track! 🌟',
      name: 'helper_activities10',
      desc: '',
      args: [],
    );
  }

  /// `Great work! 🌟`
  String get helper_activities11 {
    return Intl.message(
      'Great work! 🌟',
      name: 'helper_activities11',
      desc: '',
      args: [],
    );
  }

  /// `Awesome job, {name}!\nYou’re on the right track! 🌟`
  String helper_activities0_name(Object name) {
    return Intl.message(
      'Awesome job, $name!\nYou’re on the right track! 🌟',
      name: 'helper_activities0_name',
      desc: '',
      args: [name],
    );
  }

  /// `Impressive, {name}!\nYour hard work will pay off! 💪`
  String helper_activities1_name(Object name) {
    return Intl.message(
      'Impressive, $name!\nYour hard work will pay off! 💪',
      name: 'helper_activities1_name',
      desc: '',
      args: [name],
    );
  }

  /// `{name}, you did an amazing job!\nKeep going! 🎉`
  String helper_activities2_name(Object name) {
    return Intl.message(
      '$name, you did an amazing job!\nKeep going! 🎉',
      name: 'helper_activities2_name',
      desc: '',
      args: [name],
    );
  }

  /// `Wow, {name}! You’re setting a new normal every time! 🚀`
  String helper_activities3_name(Object name) {
    return Intl.message(
      'Wow, $name! You’re setting a new normal every time! 🚀',
      name: 'helper_activities3_name',
      desc: '',
      args: [name],
    );
  }

  /// `{name}, you nailed this!\nFantastic progress! ✨`
  String helper_activities4_name(Object name) {
    return Intl.message(
      '$name, you nailed this!\nFantastic progress! ✨',
      name: 'helper_activities4_name',
      desc: '',
      args: [name],
    );
  }

  /// `{name}, your performance is impressive! 🏅`
  String helper_activities5_name(Object name) {
    return Intl.message(
      '$name, your performance is impressive! 🏅',
      name: 'helper_activities5_name',
      desc: '',
      args: [name],
    );
  }

  /// `Great work,\n {name}! 🏆`
  String helper_activities6_name(Object name) {
    return Intl.message(
      'Great work,\n $name! 🏆',
      name: 'helper_activities6_name',
      desc: '',
      args: [name],
    );
  }

  /// `{name}, you're doing great!\nStay focused! 🔥`
  String helper_activities7_name(Object name) {
    return Intl.message(
      '$name, you\'re doing great!\nStay focused! 🔥',
      name: 'helper_activities7_name',
      desc: '',
      args: [name],
    );
  }

  /// `You’re rocking it, {name}!\n One step at a time! 🎯`
  String helper_activities8_name(Object name) {
    return Intl.message(
      'You’re rocking it, $name!\n One step at a time! 🎯',
      name: 'helper_activities8_name',
      desc: '',
      args: [name],
    );
  }

  /// `{name}, you’ve got this!\nIt’s awesome! 💥`
  String helper_activities9_name(Object name) {
    return Intl.message(
      '$name, you’ve got this!\nIt’s awesome! 💥',
      name: 'helper_activities9_name',
      desc: '',
      args: [name],
    );
  }

  /// `Fantastic work,\n {name}! 💪`
  String helper_activities10_name(Object name) {
    return Intl.message(
      'Fantastic work,\n $name! 💪',
      name: 'helper_activities10_name',
      desc: '',
      args: [name],
    );
  }

  /// `Great work,\n {name}! 🌟`
  String helper_activities11_name(Object name) {
    return Intl.message(
      'Great work,\n $name! 🌟',
      name: 'helper_activities11_name',
      desc: '',
      args: [name],
    );
  }

  /// `These Activities were the best for you 🙂:`
  String get favorite_comments0 {
    return Intl.message(
      'These Activities were the best for you 🙂:',
      name: 'favorite_comments0',
      desc: '',
      args: [],
    );
  }

  /// `These Activities were the calmest 😊:`
  String get favorite_comments1 {
    return Intl.message(
      'These Activities were the calmest 😊:',
      name: 'favorite_comments1',
      desc: '',
      args: [],
    );
  }

  /// `These Activities helped you the most 💪:`
  String get favorite_comments2 {
    return Intl.message(
      'These Activities helped you the most 💪:',
      name: 'favorite_comments2',
      desc: '',
      args: [],
    );
  }

  /// `How well did it go for you?`
  String get legend_Msg0 {
    return Intl.message(
      'How well did it go for you?',
      name: 'legend_Msg0',
      desc: '',
      args: [],
    );
  }

  /// `How calm were you?`
  String get legend_Msg1 {
    return Intl.message(
      'How calm were you?',
      name: 'legend_Msg1',
      desc: '',
      args: [],
    );
  }

  /// `How helpful was it?`
  String get legend_Msg2 {
    return Intl.message(
      'How helpful was it?',
      name: 'legend_Msg2',
      desc: '',
      args: [],
    );
  }

  /// `How calm\nwere you?`
  String get legend_Msg1_clip {
    return Intl.message(
      'How calm\nwere you?',
      name: 'legend_Msg1_clip',
      desc: '',
      args: [],
    );
  }

  /// `How helpful\nwas it?`
  String get legend_Msg2_clip {
    return Intl.message(
      'How helpful\nwas it?',
      name: 'legend_Msg2_clip',
      desc: '',
      args: [],
    );
  }

  /// `{name} here is a list of all your weekly plans 😊`
  String themeHelper_msg0(Object name) {
    return Intl.message(
      '$name here is a list of all your weekly plans 😊',
      name: 'themeHelper_msg0',
      desc: '',
      args: [name],
    );
  }

  /// `{name} here are all the activities where you haven't given feedback yet 😉\n`
  String themeHelper_open_msg0(Object name) {
    return Intl.message(
      '$name here are all the activities where you haven\'t given feedback yet 😉\n',
      name: 'themeHelper_open_msg0',
      desc: '',
      args: [name],
    );
  }

  /// `{count, plural, =0{Currently there is nothing to answer 😉} =1{{count} activity is left 😉} other{{count} appointments are left 😉}}`
  String themeHelper_open_msg1(num count) {
    return Intl.plural(
      count,
      zero: 'Currently there is nothing to answer 😉',
      one: '$count activity is left 😉',
      other: '$count appointments are left 😉',
      name: 'themeHelper_open_msg1',
      desc: '',
      args: [count],
    );
  }

  /// `{date} you completed\n`
  String taskCompletedOn(Object date) {
    return Intl.message(
      '$date you completed\n',
      name: 'taskCompletedOn',
      desc: '',
      args: [date],
    );
  }

  /// `today`
  String get today {
    return Intl.message('today', name: 'today', desc: '', args: []);
  }

  /// `{count, plural, =1{\nTask} other{\nTasks}}`
  String tasksCompleted(num count) {
    return Intl.plural(
      count,
      one: '\nTask',
      other: '\nTasks',
      name: 'tasksCompleted',
      desc: '',
      args: [count],
    );
  }

  /// `\n\n(If you like, you can still give feedback on {count, plural, =1{one activity} other{{count} activities}} on the 'Open' page 😊)`
  String tasksPendingFeedback(num count) {
    return Intl.message(
      '\n\n(If you like, you can still give feedback on ${Intl.plural(count, one: 'one activity', other: '$count activities')} on the \'Open\' page 😊)',
      name: 'tasksPendingFeedback',
      desc: '',
      args: [count],
    );
  }

  /// `You had no activities planned {date}.`
  String noAppointmentsOn(Object date) {
    return Intl.message(
      'You had no activities planned $date.',
      name: 'noAppointmentsOn',
      desc: '',
      args: [date],
    );
  }

  /// `I hope you had a good day {count, plural, zero{} other{, {name}}} 😊`
  String hopeYouHadAGoodDay(num count, Object name) {
    return Intl.message(
      'I hope you had a good day ${Intl.plural(count, zero: '', other: ', $name')} 😊',
      name: 'hopeYouHadAGoodDay',
      desc: '',
      args: [count, name],
    );
  }

  /// `You haven't answered {count, plural, =1{your activity} other{{count} activities}} {date} yet.`
  String tasksNotAnsweredOn(num count, Object date) {
    return Intl.message(
      'You haven\'t answered ${Intl.plural(count, one: 'your activity', other: '$count activities')} $date yet.',
      name: 'tasksNotAnsweredOn',
      desc: '',
      args: [count, date],
    );
  }

  /// `Check on the home page under 'Open' or in the 'Week Overview' to give feedback on an activity 👍`
  String get checkPendingFeedback {
    return Intl.message(
      'Check on the home page under \'Open\' or in the \'Week Overview\' to give feedback on an activity 👍',
      name: 'checkPendingFeedback',
      desc: '',
      args: [],
    );
  }

  /// `The day hasn't arrived yet 😉 \n Still, it's nice that you're checking in early {name} :)`
  String dayNotYetArrived(Object name) {
    return Intl.message(
      'The day hasn\'t arrived yet 😉 \n Still, it\'s nice that you\'re checking in early $name :)',
      name: 'dayNotYetArrived',
      desc: '',
      args: [name],
    );
  }

  /// `Congratulations!!! 🎉 You found a case I didn't think of! Great job! 😊 If possible, let your therapist or the app developer know which combination led to this case.`
  String get unexpectedCaseFound {
    return Intl.message(
      'Congratulations!!! 🎉 You found a case I didn\'t think of! Great job! 😊 If possible, let your therapist or the app developer know which combination led to this case.',
      name: 'unexpectedCaseFound',
      desc: '',
      args: [],
    );
  }

  /// `Daily Values`
  String get daily_Values {
    return Intl.message(
      'Daily Values',
      name: 'daily_Values',
      desc: '',
      args: [],
    );
  }

  /// `Thanks! 😊 \n\n I hope the day was helpful and you felt good \n\n Just take it one day at a time 😊 💪`
  String get day_reward_message {
    return Intl.message(
      'Thanks! 😊 \n\n I hope the day was helpful and you felt good \n\n Just take it one day at a time 😊 💪',
      name: 'day_reward_message',
      desc: '',
      args: [],
    );
  }

  /// `This week you completed\n`
  String get weekOverView_summary {
    return Intl.message(
      'This week you completed\n',
      name: 'weekOverView_summary',
      desc: '',
      args: [],
    );
  }

  /// `{count, plural, =1{Task\n\n {randomText}} other{Tasks\n\n {randomText}}}`
  String weekOverView_summary_part2(num count, Object randomText) {
    return Intl.plural(
      count,
      one: 'Task\n\n $randomText',
      other: 'Tasks\n\n $randomText',
      name: 'weekOverView_summary_part2',
      desc: '',
      args: [count, randomText],
    );
  }

  /// `{count, plural, =0{} =1{\n\n If you like, you can still give feedback on {count} activity} other{\n\n If you like, you can still give feedback on {count} activities}}`
  String weekOverView_leftAnswers(num count) {
    return Intl.plural(
      count,
      zero: '',
      one: '\n\n If you like, you can still give feedback on $count activity',
      other:
          '\n\n If you like, you can still give feedback on $count activities',
      name: 'weekOverView_leftAnswers',
      desc: '',
      args: [count],
    );
  }

  /// `You haven't yet evaluated any activity this week\n Please come back later 🙋♂️`
  String get weekOverView_noAnswers {
    return Intl.message(
      'You haven\'t yet evaluated any activity this week\n Please come back later 🙋♂️',
      name: 'weekOverView_noAnswers',
      desc: '',
      args: [],
    );
  }

  /// `\n\n Scroll down to get more info ;)`
  String get weekOverView_scroll {
    return Intl.message(
      '\n\n Scroll down to get more info ;)',
      name: 'weekOverView_scroll',
      desc: '',
      args: [],
    );
  }

  /// `Thanks! 😊 \n\n Ich hope this week did you good and you made progress \n\n You're doing great one week at a time 💪`
  String get week_reward_message {
    return Intl.message(
      'Thanks! 😊 \n\n Ich hope this week did you good and you made progress \n\n You\'re doing great one week at a time 💪',
      name: 'week_reward_message',
      desc: '',
      args: [],
    );
  }

  /// `Weekly Values`
  String get weekly_values {
    return Intl.message(
      'Weekly Values',
      name: 'weekly_values',
      desc: '',
      args: [],
    );
  }

  /// `📅 Activities on the {date}`
  String noti_start_title(DateTime date) {
    final DateFormat dateDateFormat = DateFormat(
      'dd.MM.yy',
      Intl.getCurrentLocale(),
    );
    final String dateString = dateDateFormat.format(date);

    return Intl.message(
      '📅 Activities on the $dateString',
      name: 'noti_start_title',
      desc: '',
      args: [dateString],
    );
  }

  /// `Today the following Activities are planed 🙂 \n`
  String get noti_start_message {
    return Intl.message(
      'Today the following Activities are planed 🙂 \n',
      name: 'noti_start_message',
      desc: '',
      args: [],
    );
  }

  /// `Today there aren't any Activities planed, so lean back and try to relax a bit 🙂`
  String get noti_noTasks_message {
    return Intl.message(
      'Today there aren\'t any Activities planed, so lean back and try to relax a bit 🙂',
      name: 'noti_noTasks_message',
      desc: '',
      args: [],
    );
  }

  /// `{terminName} is on in {count} minutens. You got this!🤞`
  String noti_termin_messageBefore(Object terminName, Object count) {
    return Intl.message(
      '$terminName is on in $count minutens. You got this!🤞',
      name: 'noti_termin_messageBefore',
      desc: '',
      args: [terminName, count],
    );
  }

  /// `It's time for {terminName}! Good Luck!🤞`
  String noti_termin_messageAt(Object terminName) {
    return Intl.message(
      'It\'s time for $terminName! Good Luck!🤞',
      name: 'noti_termin_messageAt',
      desc: '',
      args: [terminName],
    );
  }

  /// `{terminName} is over. I hope it worked out and helped you 😊\nPlease tap on me and take a second to reflect\nIt's not bad if you coudn't do the Activity, the reflection itself is more than most people can do🤘`
  String noti_termin_messageAfter(Object terminName) {
    return Intl.message(
      '$terminName is over. I hope it worked out and helped you 😊\nPlease tap on me and take a second to reflect\nIt\'s not bad if you coudn\'t do the Activity, the reflection itself is more than most people can do🤘',
      name: 'noti_termin_messageAfter',
      desc: '',
      args: [terminName],
    );
  }

  /// `$🎉 Activity Summary for the {date}`
  String noti_dayEnd_title(DateTime date) {
    final DateFormat dateDateFormat = DateFormat(
      'dd.MM.yy',
      Intl.getCurrentLocale(),
    );
    final String dateString = dateDateFormat.format(date);

    return Intl.message(
      '\$🎉 Activity Summary for the $dateString',
      name: 'noti_dayEnd_title',
      desc: '',
      args: [dateString],
    );
  }

  /// `Once again a day is over. \n Tap on me to see what happend today 😊 \n`
  String get noti_dayEnd_message {
    return Intl.message(
      'Once again a day is over. \n Tap on me to see what happend today 😊 \n',
      name: 'noti_dayEnd_message',
      desc: '',
      args: [],
    );
  }

  /// `Week Overview 🎊`
  String get noti_weekEnd_title {
    return Intl.message(
      'Week Overview 🎊',
      name: 'noti_weekEnd_title',
      desc: '',
      args: [],
    );
  }

  /// `Super! Another week done\n Tap on me for a Summary of the week`
  String get noti_weekEnd_message {
    return Intl.message(
      'Super! Another week done\n Tap on me for a Summary of the week',
      name: 'noti_weekEnd_message',
      desc: '',
      args: [],
    );
  }

  /// `Delete`
  String get delete {
    return Intl.message('Delete', name: 'delete', desc: '', args: []);
  }

  /// `Do you really want to delete the Plan for:`
  String get delete_week_plan {
    return Intl.message(
      'Do you really want to delete the Plan for:',
      name: 'delete_week_plan',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure?`
  String get delete_week_plan2 {
    return Intl.message(
      'Are you sure?',
      name: 'delete_week_plan2',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'de'),
      Locale.fromSubtags(languageCode: 'en', countryCode: 'US'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
