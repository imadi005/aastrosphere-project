import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_bn.dart';
import 'app_localizations_en.dart';
import 'app_localizations_gu.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_mr.dart';
import 'app_localizations_ta.dart';
import 'app_localizations_te.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('bn'),
    Locale('en'),
    Locale('gu'),
    Locale('hi'),
    Locale('mr'),
    Locale('ta'),
    Locale('te')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Aastrosphere'**
  String get appTitle;

  /// No description provided for @navToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get navToday;

  /// No description provided for @navInsights.
  ///
  /// In en, this message translates to:
  /// **'Insights'**
  String get navInsights;

  /// No description provided for @navAsk.
  ///
  /// In en, this message translates to:
  /// **'Ask'**
  String get navAsk;

  /// No description provided for @navCircle.
  ///
  /// In en, this message translates to:
  /// **'Circle'**
  String get navCircle;

  /// No description provided for @navChart.
  ///
  /// In en, this message translates to:
  /// **'Chart'**
  String get navChart;

  /// No description provided for @navMe.
  ///
  /// In en, this message translates to:
  /// **'Me'**
  String get navMe;

  /// No description provided for @navClients.
  ///
  /// In en, this message translates to:
  /// **'Clients'**
  String get navClients;

  /// No description provided for @selectYourLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select your language'**
  String get selectYourLanguage;

  /// No description provided for @changeLanguage.
  ///
  /// In en, this message translates to:
  /// **'Change language'**
  String get changeLanguage;

  /// No description provided for @languageUpdated.
  ///
  /// In en, this message translates to:
  /// **'Language updated'**
  String get languageUpdated;

  /// No description provided for @continueLabel.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueLabel;

  /// No description provided for @getOtp.
  ///
  /// In en, this message translates to:
  /// **'Get OTP'**
  String get getOtp;

  /// No description provided for @verifyAndContinue.
  ///
  /// In en, this message translates to:
  /// **'Verify & Continue'**
  String get verifyAndContinue;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @letsDiveIn.
  ///
  /// In en, this message translates to:
  /// **'Let\'s Dive In'**
  String get letsDiveIn;

  /// No description provided for @userLogin.
  ///
  /// In en, this message translates to:
  /// **'User Login'**
  String get userLogin;

  /// No description provided for @astrologerLogin.
  ///
  /// In en, this message translates to:
  /// **'Astrologer Login'**
  String get astrologerLogin;

  /// No description provided for @enterPhoneToContinue.
  ///
  /// In en, this message translates to:
  /// **'Enter your phone number to continue'**
  String get enterPhoneToContinue;

  /// No description provided for @enterOtpSentTo.
  ///
  /// In en, this message translates to:
  /// **'Enter the 6-digit code sent to'**
  String get enterOtpSentTo;

  /// No description provided for @areYouA.
  ///
  /// In en, this message translates to:
  /// **'Are you a'**
  String get areYouA;

  /// No description provided for @choosePath.
  ///
  /// In en, this message translates to:
  /// **'Choose your path'**
  String get choosePath;

  /// No description provided for @userRole.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get userRole;

  /// No description provided for @userRoleDesc.
  ///
  /// In en, this message translates to:
  /// **'Daily guidance, personal chart and reminders'**
  String get userRoleDesc;

  /// No description provided for @astrologerRole.
  ///
  /// In en, this message translates to:
  /// **'Astrologer'**
  String get astrologerRole;

  /// No description provided for @astrologerRoleDesc.
  ///
  /// In en, this message translates to:
  /// **'Read charts, timelines and client reports'**
  String get astrologerRoleDesc;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @askAnything.
  ///
  /// In en, this message translates to:
  /// **'Ask Anything'**
  String get askAnything;

  /// No description provided for @askYourQuestion.
  ///
  /// In en, this message translates to:
  /// **'Ask your question...'**
  String get askYourQuestion;

  /// No description provided for @clearChat.
  ///
  /// In en, this message translates to:
  /// **'Clear chat'**
  String get clearChat;

  /// No description provided for @todayTab.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get todayTab;

  /// No description provided for @insightsTab.
  ///
  /// In en, this message translates to:
  /// **'Insights'**
  String get insightsTab;

  /// No description provided for @chartTab.
  ///
  /// In en, this message translates to:
  /// **'Chart'**
  String get chartTab;

  /// No description provided for @circleTab.
  ///
  /// In en, this message translates to:
  /// **'Circle'**
  String get circleTab;

  /// No description provided for @timelineTab.
  ///
  /// In en, this message translates to:
  /// **'Timeline'**
  String get timelineTab;

  /// No description provided for @patternTab.
  ///
  /// In en, this message translates to:
  /// **'Pattern'**
  String get patternTab;

  /// No description provided for @reportsTab.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get reportsTab;

  /// No description provided for @consultTab.
  ///
  /// In en, this message translates to:
  /// **'Consult'**
  String get consultTab;

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get comingSoon;

  /// No description provided for @modeClient.
  ///
  /// In en, this message translates to:
  /// **'Client'**
  String get modeClient;

  /// No description provided for @longTermPhase.
  ///
  /// In en, this message translates to:
  /// **'Long-Term Phase'**
  String get longTermPhase;

  /// No description provided for @currentPhase.
  ///
  /// In en, this message translates to:
  /// **'Current Phase'**
  String get currentPhase;

  /// No description provided for @monthlyLabel.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get monthlyLabel;

  /// No description provided for @dailyLabel.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get dailyLabel;

  /// No description provided for @hourlyLabel.
  ///
  /// In en, this message translates to:
  /// **'Hourly'**
  String get hourlyLabel;

  /// No description provided for @basicLabel.
  ///
  /// In en, this message translates to:
  /// **'Basic'**
  String get basicLabel;

  /// No description provided for @innerSelf.
  ///
  /// In en, this message translates to:
  /// **'Inner Self'**
  String get innerSelf;

  /// No description provided for @destinyLabel.
  ///
  /// In en, this message translates to:
  /// **'Destiny'**
  String get destinyLabel;

  /// No description provided for @lifePath.
  ///
  /// In en, this message translates to:
  /// **'Life Path'**
  String get lifePath;

  /// No description provided for @numerologicalGrid.
  ///
  /// In en, this message translates to:
  /// **'Numerological Grid'**
  String get numerologicalGrid;

  /// No description provided for @lockIn.
  ///
  /// In en, this message translates to:
  /// **'Lock in'**
  String get lockIn;

  /// No description provided for @todaysPriority.
  ///
  /// In en, this message translates to:
  /// **'TODAY\'S PRIORITY'**
  String get todaysPriority;

  /// No description provided for @luckyColor.
  ///
  /// In en, this message translates to:
  /// **'Lucky Color'**
  String get luckyColor;

  /// No description provided for @coreNumbers.
  ///
  /// In en, this message translates to:
  /// **'Core Numbers'**
  String get coreNumbers;

  /// No description provided for @runningPeriods.
  ///
  /// In en, this message translates to:
  /// **'Running Periods'**
  String get runningPeriods;

  /// No description provided for @dayAnalysis.
  ///
  /// In en, this message translates to:
  /// **'Day Analysis'**
  String get dayAnalysis;

  /// No description provided for @readingTodaysEnergy.
  ///
  /// In en, this message translates to:
  /// **'Reading today\'s energy...'**
  String get readingTodaysEnergy;

  /// No description provided for @todaysGuidance.
  ///
  /// In en, this message translates to:
  /// **'TODAY\'S GUIDANCE'**
  String get todaysGuidance;

  /// No description provided for @couldNotLoadReading.
  ///
  /// In en, this message translates to:
  /// **'Could not load today\'s reading'**
  String get couldNotLoadReading;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get tryAgain;

  /// No description provided for @completeProfileToBegin.
  ///
  /// In en, this message translates to:
  /// **'Complete your profile to begin'**
  String get completeProfileToBegin;

  /// No description provided for @hourByHour.
  ///
  /// In en, this message translates to:
  /// **'Hour by Hour'**
  String get hourByHour;

  /// No description provided for @activeInYourChart.
  ///
  /// In en, this message translates to:
  /// **'Active in Your Chart'**
  String get activeInYourChart;

  /// No description provided for @tapAnyHourDetailLower.
  ///
  /// In en, this message translates to:
  /// **'tap any hour below for detail'**
  String get tapAnyHourDetailLower;

  /// No description provided for @tapAnyHourDetail.
  ///
  /// In en, this message translates to:
  /// **'Tap any hour for detail'**
  String get tapAnyHourDetail;

  /// No description provided for @notYet.
  ///
  /// In en, this message translates to:
  /// **'Not yet'**
  String get notYet;

  /// No description provided for @doLabel.
  ///
  /// In en, this message translates to:
  /// **'DO'**
  String get doLabel;

  /// No description provided for @avoidLabel.
  ///
  /// In en, this message translates to:
  /// **'AVOID'**
  String get avoidLabel;

  /// No description provided for @bestForThisHour.
  ///
  /// In en, this message translates to:
  /// **'BEST FOR THIS HOUR'**
  String get bestForThisHour;

  /// No description provided for @avoidThisHour.
  ///
  /// In en, this message translates to:
  /// **'AVOID THIS HOUR'**
  String get avoidThisHour;

  /// No description provided for @whyThisHour.
  ///
  /// In en, this message translates to:
  /// **'WHY THIS HOUR'**
  String get whyThisHour;

  /// No description provided for @physicalCaution.
  ///
  /// In en, this message translates to:
  /// **'PHYSICAL CAUTION'**
  String get physicalCaution;

  /// No description provided for @cautionWindowsToday.
  ///
  /// In en, this message translates to:
  /// **'CAUTION WINDOWS TODAY'**
  String get cautionWindowsToday;

  /// No description provided for @notifiedHourBefore.
  ///
  /// In en, this message translates to:
  /// **'You will be notified 1 hour before each window.'**
  String get notifiedHourBefore;

  /// No description provided for @goodFor.
  ///
  /// In en, this message translates to:
  /// **'GOOD FOR'**
  String get goodFor;

  /// No description provided for @goEasyOn.
  ///
  /// In en, this message translates to:
  /// **'GO EASY ON'**
  String get goEasyOn;

  /// No description provided for @rightNow.
  ///
  /// In en, this message translates to:
  /// **'RIGHT NOW'**
  String get rightNow;

  /// No description provided for @tapForDetails.
  ///
  /// In en, this message translates to:
  /// **'Tap for details'**
  String get tapForDetails;

  /// No description provided for @restOfYourDay.
  ///
  /// In en, this message translates to:
  /// **'THE REST OF YOUR DAY'**
  String get restOfYourDay;

  /// No description provided for @nowLower.
  ///
  /// In en, this message translates to:
  /// **'now'**
  String get nowLower;

  /// No description provided for @nowUpper.
  ///
  /// In en, this message translates to:
  /// **'NOW'**
  String get nowUpper;

  /// No description provided for @energyToday.
  ///
  /// In en, this message translates to:
  /// **'ENERGY TODAY'**
  String get energyToday;

  /// No description provided for @bestLabel.
  ///
  /// In en, this message translates to:
  /// **'Best'**
  String get bestLabel;

  /// No description provided for @cautionLabel.
  ///
  /// In en, this message translates to:
  /// **'Caution'**
  String get cautionLabel;

  /// No description provided for @greetingMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning, {name}'**
  String greetingMorning(String name);

  /// No description provided for @greetingAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon, {name}'**
  String greetingAfternoon(String name);

  /// No description provided for @greetingEvening.
  ///
  /// In en, this message translates to:
  /// **'Good evening, {name}'**
  String greetingEvening(String name);

  /// No description provided for @greetingLate.
  ///
  /// In en, this message translates to:
  /// **'Hello, {name}'**
  String greetingLate(String name);

  /// No description provided for @askWelcomeMessage.
  ///
  /// In en, this message translates to:
  /// **'✨ **Welcome** ✨\n\nI\'m your personal guide. Ask me anything about:\n\n• **Your Path** - Personality, patterns, life direction\n• **Career** - Job switch, promotion, business\n• **Relationships** - Love, marriage, family vibes\n• **Finance** - Money, investments, wealth\n• **Health** - Wellness, remedies, lifestyle\n\n**What\'s on your mind?** 😊'**
  String get askWelcomeMessage;

  /// No description provided for @askWord.
  ///
  /// In en, this message translates to:
  /// **'Ask '**
  String get askWord;

  /// No description provided for @anythingWord.
  ///
  /// In en, this message translates to:
  /// **'Anything'**
  String get anythingWord;

  /// No description provided for @byPankajj.
  ///
  /// In en, this message translates to:
  /// **'by Pankajj Kumar Mishra'**
  String get byPankajj;

  /// No description provided for @askQuestionGuidance.
  ///
  /// In en, this message translates to:
  /// **'Ask your question for\nastrological guidance'**
  String get askQuestionGuidance;

  /// No description provided for @careerLoveMoneyHealth.
  ///
  /// In en, this message translates to:
  /// **'Career · Love · Money · Health'**
  String get careerLoveMoneyHealth;

  /// No description provided for @typingLabel.
  ///
  /// In en, this message translates to:
  /// **'Typing...'**
  String get typingLabel;

  /// No description provided for @watchOut.
  ///
  /// In en, this message translates to:
  /// **'WATCH OUT'**
  String get watchOut;

  /// No description provided for @bestFor.
  ///
  /// In en, this message translates to:
  /// **'BEST FOR'**
  String get bestFor;

  /// No description provided for @cautionUpper.
  ///
  /// In en, this message translates to:
  /// **'CAUTION'**
  String get cautionUpper;

  /// No description provided for @yourCurrentChapter.
  ///
  /// In en, this message translates to:
  /// **'YOUR CURRENT CHAPTER'**
  String get yourCurrentChapter;

  /// No description provided for @couldNotLoadInsights.
  ///
  /// In en, this message translates to:
  /// **'Could not load insights'**
  String get couldNotLoadInsights;

  /// No description provided for @retryLabel.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retryLabel;

  /// No description provided for @weekByWeek.
  ///
  /// In en, this message translates to:
  /// **'Week by Week'**
  String get weekByWeek;

  /// No description provided for @monthByMonth.
  ///
  /// In en, this message translates to:
  /// **'Month by Month'**
  String get monthByMonth;

  /// No description provided for @thisWeek.
  ///
  /// In en, this message translates to:
  /// **'This Week'**
  String get thisWeek;

  /// No description provided for @monthArc.
  ///
  /// In en, this message translates to:
  /// **'Month Arc'**
  String get monthArc;

  /// No description provided for @lifeDomains.
  ///
  /// In en, this message translates to:
  /// **'Life Domains'**
  String get lifeDomains;

  /// No description provided for @yourYear.
  ///
  /// In en, this message translates to:
  /// **'Your Year'**
  String get yourYear;

  /// No description provided for @yourCircle.
  ///
  /// In en, this message translates to:
  /// **'Your Circle'**
  String get yourCircle;

  /// No description provided for @todayScoreLabel.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get todayScoreLabel;

  /// No description provided for @removeLabel.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get removeLabel;

  /// No description provided for @doTogether.
  ///
  /// In en, this message translates to:
  /// **'DO TOGETHER'**
  String get doTogether;

  /// No description provided for @beCarefulToday.
  ///
  /// In en, this message translates to:
  /// **'BE CAREFUL TODAY'**
  String get beCarefulToday;

  /// No description provided for @howYouShowUp.
  ///
  /// In en, this message translates to:
  /// **'How you show up for each other'**
  String get howYouShowUp;

  /// No description provided for @errorLabel.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get errorLabel;

  /// No description provided for @addToYourCircle.
  ///
  /// In en, this message translates to:
  /// **'Add to your circle'**
  String get addToYourCircle;

  /// No description provided for @partnerFriendFamily.
  ///
  /// In en, this message translates to:
  /// **'Partner, friend, family, colleague — anyone'**
  String get partnerFriendFamily;

  /// No description provided for @addToCircle.
  ///
  /// In en, this message translates to:
  /// **'Add to circle'**
  String get addToCircle;

  /// No description provided for @addAnyone.
  ///
  /// In en, this message translates to:
  /// **'Add anyone — partner, friend, family, colleague'**
  String get addAnyone;

  /// No description provided for @seeHowNumbersInteract.
  ///
  /// In en, this message translates to:
  /// **'See how your numbers interact'**
  String get seeHowNumbersInteract;

  /// No description provided for @addSomeone.
  ///
  /// In en, this message translates to:
  /// **'Add someone'**
  String get addSomeone;

  /// No description provided for @personWord.
  ///
  /// In en, this message translates to:
  /// **'person'**
  String get personWord;

  /// No description provided for @peopleWord.
  ///
  /// In en, this message translates to:
  /// **'people'**
  String get peopleWord;

  /// No description provided for @tapToSeeFullReading.
  ///
  /// In en, this message translates to:
  /// **'tap to see full reading'**
  String get tapToSeeFullReading;

  /// No description provided for @overallTab.
  ///
  /// In en, this message translates to:
  /// **'Overall'**
  String get overallTab;

  /// No description provided for @dynamicsTab.
  ///
  /// In en, this message translates to:
  /// **'Dynamics'**
  String get dynamicsTab;

  /// No description provided for @whatWorks.
  ///
  /// In en, this message translates to:
  /// **'What works'**
  String get whatWorks;

  /// No description provided for @theTension.
  ///
  /// In en, this message translates to:
  /// **'The tension'**
  String get theTension;

  /// No description provided for @growthEdge.
  ///
  /// In en, this message translates to:
  /// **'Growth edge'**
  String get growthEdge;

  /// No description provided for @friendshipLabel.
  ///
  /// In en, this message translates to:
  /// **'Friendship'**
  String get friendshipLabel;

  /// No description provided for @youLabel.
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get youLabel;

  /// No description provided for @themLabel.
  ///
  /// In en, this message translates to:
  /// **'Them'**
  String get themLabel;

  /// No description provided for @theirNameHint.
  ///
  /// In en, this message translates to:
  /// **'Their name'**
  String get theirNameHint;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
        'bn',
        'en',
        'gu',
        'hi',
        'mr',
        'ta',
        'te'
      ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'bn':
      return AppLocalizationsBn();
    case 'en':
      return AppLocalizationsEn();
    case 'gu':
      return AppLocalizationsGu();
    case 'hi':
      return AppLocalizationsHi();
    case 'mr':
      return AppLocalizationsMr();
    case 'ta':
      return AppLocalizationsTa();
    case 'te':
      return AppLocalizationsTe();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
