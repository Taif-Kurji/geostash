import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_sv.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
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
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('sv')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'GeoStash'**
  String get appTitle;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Log in'**
  String get login;

  /// No description provided for @signup.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get signup;

  /// No description provided for @toggleAuthModeToSignup.
  ///
  /// In en, this message translates to:
  /// **'Need an account? Sign up'**
  String get toggleAuthModeToSignup;

  /// No description provided for @toggleAuthModeToLogin.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Log in'**
  String get toggleAuthModeToLogin;

  /// No description provided for @loginWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Google'**
  String get loginWithGoogle;

  /// No description provided for @groups.
  ///
  /// In en, this message translates to:
  /// **'Groups'**
  String get groups;

  /// No description provided for @createGroup.
  ///
  /// In en, this message translates to:
  /// **'Create group'**
  String get createGroup;

  /// No description provided for @joinGroup.
  ///
  /// In en, this message translates to:
  /// **'Join group'**
  String get joinGroup;

  /// No description provided for @groupName.
  ///
  /// In en, this message translates to:
  /// **'Group name'**
  String get groupName;

  /// No description provided for @code.
  ///
  /// In en, this message translates to:
  /// **'Code'**
  String get code;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @create.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// No description provided for @join.
  ///
  /// In en, this message translates to:
  /// **'Join'**
  String get join;

  /// No description provided for @openMap.
  ///
  /// In en, this message translates to:
  /// **'Open map'**
  String get openMap;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get logout;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @mapTitle.
  ///
  /// In en, this message translates to:
  /// **'GeoStash Map'**
  String get mapTitle;

  /// No description provided for @noCachesYet.
  ///
  /// In en, this message translates to:
  /// **'No caches yet – tap the map to create one.'**
  String get noCachesYet;

  /// No description provided for @couldNotSaveCache.
  ///
  /// In en, this message translates to:
  /// **'Could not save cache'**
  String get couldNotSaveCache;

  /// No description provided for @couldNotLoadCaches.
  ///
  /// In en, this message translates to:
  /// **'Could not load caches'**
  String get couldNotLoadCaches;

  /// No description provided for @updatePosition.
  ///
  /// In en, this message translates to:
  /// **'Update position'**
  String get updatePosition;

  /// No description provided for @createCache.
  ///
  /// In en, this message translates to:
  /// **'Create cache'**
  String get createCache;

  /// No description provided for @cacheTitle.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get cacheTitle;

  /// No description provided for @cacheDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get cacheDescription;

  /// No description provided for @markFound.
  ///
  /// In en, this message translates to:
  /// **'Mark as found'**
  String get markFound;

  /// No description provided for @unmarkFound.
  ///
  /// In en, this message translates to:
  /// **'Unmark found'**
  String get unmarkFound;

  /// No description provided for @centerOnMap.
  ///
  /// In en, this message translates to:
  /// **'Center on map'**
  String get centerOnMap;

  /// No description provided for @deleteCache.
  ///
  /// In en, this message translates to:
  /// **'Delete cache'**
  String get deleteCache;

  /// No description provided for @deleteCacheConfirm.
  ///
  /// In en, this message translates to:
  /// **'This will remove the cache for everyone in the group. Continue?'**
  String get deleteCacheConfirm;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @showFoundCaches.
  ///
  /// In en, this message translates to:
  /// **'Show found'**
  String get showFoundCaches;

  /// No description provided for @hideFoundCaches.
  ///
  /// In en, this message translates to:
  /// **'Hide found'**
  String get hideFoundCaches;

  /// No description provided for @noUnfoundCaches.
  ///
  /// In en, this message translates to:
  /// **'All caches found.'**
  String get noUnfoundCaches;

  /// No description provided for @createdCaches.
  ///
  /// In en, this message translates to:
  /// **'Created caches'**
  String get createdCaches;

  /// No description provided for @foundCaches.
  ///
  /// In en, this message translates to:
  /// **'Found caches'**
  String get foundCaches;

  /// No description provided for @tipMarkFound.
  ///
  /// In en, this message translates to:
  /// **'Tip: mark a cache as found in the map list.'**
  String get tipMarkFound;

  /// No description provided for @hello.
  ///
  /// In en, this message translates to:
  /// **'Hi'**
  String get hello;

  /// No description provided for @cachesLabel.
  ///
  /// In en, this message translates to:
  /// **'Caches'**
  String get cachesLabel;

  /// No description provided for @foundLabel.
  ///
  /// In en, this message translates to:
  /// **'Found'**
  String get foundLabel;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @systemDefault.
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get systemDefault;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @light.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get light;

  /// No description provided for @dark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get dark;

  /// No description provided for @map.
  ///
  /// In en, this message translates to:
  /// **'Map'**
  String get map;

  /// No description provided for @select.
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get select;

  /// No description provided for @noGroups.
  ///
  /// In en, this message translates to:
  /// **'No groups yet.'**
  String get noGroups;

  /// No description provided for @enterCode.
  ///
  /// In en, this message translates to:
  /// **'Enter group code'**
  String get enterCode;

  /// No description provided for @selectGroupFirst.
  ///
  /// In en, this message translates to:
  /// **'Select or create a group first.'**
  String get selectGroupFirst;

  /// No description provided for @goToGroups.
  ///
  /// In en, this message translates to:
  /// **'Go to Groups'**
  String get goToGroups;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'sv'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'sv': return AppLocalizationsSv();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
