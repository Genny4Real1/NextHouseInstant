import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_da.dart';
import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_it.dart';

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
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
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
    Locale('da'),
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('it'),
  ];

  /// No description provided for @takeSelfie.
  ///
  /// In en, this message translates to:
  /// **'TAKE A SELFIE'**
  String get takeSelfie;

  /// No description provided for @cloudStorageTitle.
  ///
  /// In en, this message translates to:
  /// **'Cloud Storage & Privacy'**
  String get cloudStorageTitle;

  /// No description provided for @cloudStorageDesc.
  ///
  /// In en, this message translates to:
  /// **'By choosing to share, your photos will be uploaded to a secure cloud server so you can access and download them.\n\nTo ensure your privacy, all uploaded photos will be automatically and permanently deleted upon session expiration (within 10 minutes).'**
  String get cloudStorageDesc;

  /// No description provided for @gdprNotice.
  ///
  /// In en, this message translates to:
  /// **'Data Controller: Arp-Hansen Hotel Group.\nContact: reservations@nexthousecopenhagen.com.\nScan the QR code to read the full Privacy Policy.'**
  String get gdprNotice;

  /// No description provided for @decline.
  ///
  /// In en, this message translates to:
  /// **'Decline'**
  String get decline;

  /// No description provided for @accept.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get accept;

  /// No description provided for @takeAnotherQuestion.
  ///
  /// In en, this message translates to:
  /// **'Do you want to take another picture?'**
  String get takeAnotherQuestion;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @processing.
  ///
  /// In en, this message translates to:
  /// **'Processing'**
  String get processing;

  /// No description provided for @sharePhotosTitle.
  ///
  /// In en, this message translates to:
  /// **'Share your photos'**
  String get sharePhotosTitle;

  /// No description provided for @sharePhotosSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Select the images you want to save'**
  String get sharePhotosSubtitle;

  /// No description provided for @ofWord.
  ///
  /// In en, this message translates to:
  /// **'of'**
  String get ofWord;

  /// No description provided for @selected.
  ///
  /// In en, this message translates to:
  /// **'selected'**
  String get selected;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @uploadingPhotos.
  ///
  /// In en, this message translates to:
  /// **'Uploading photos...'**
  String get uploadingPhotos;

  /// No description provided for @creatingSession.
  ///
  /// In en, this message translates to:
  /// **'Creating download session'**
  String get creatingSession;

  /// No description provided for @scanMe.
  ///
  /// In en, this message translates to:
  /// **'Scan me!'**
  String get scanMe;

  /// No description provided for @stayCloseMsg.
  ///
  /// In en, this message translates to:
  /// **'Stay close to the kiosk while we complete the operation.'**
  String get stayCloseMsg;

  /// No description provided for @sharingError.
  ///
  /// In en, this message translates to:
  /// **'Sharing Error'**
  String get sharingError;

  /// No description provided for @backToSelection.
  ///
  /// In en, this message translates to:
  /// **'Back to selection'**
  String get backToSelection;

  /// No description provided for @filtersLabel.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get filtersLabel;

  /// No description provided for @adjustTool.
  ///
  /// In en, this message translates to:
  /// **'Adjust'**
  String get adjustTool;

  /// No description provided for @stickerTool.
  ///
  /// In en, this message translates to:
  /// **'Sticker'**
  String get stickerTool;

  /// No description provided for @textTool.
  ///
  /// In en, this message translates to:
  /// **'Text'**
  String get textTool;

  /// No description provided for @drawTool.
  ///
  /// In en, this message translates to:
  /// **'Draw'**
  String get drawTool;

  /// No description provided for @rotateTool.
  ///
  /// In en, this message translates to:
  /// **'Rotate'**
  String get rotateTool;

  /// No description provided for @resetBtn.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get resetBtn;

  /// No description provided for @saveBtn.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get saveBtn;

  /// No description provided for @editTextTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Text'**
  String get editTextTitle;

  /// No description provided for @addTextTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Text'**
  String get addTextTitle;

  /// No description provided for @writeSomethingHint.
  ///
  /// In en, this message translates to:
  /// **'Write something...'**
  String get writeSomethingHint;

  /// No description provided for @textColorLbl.
  ///
  /// In en, this message translates to:
  /// **'Text color:'**
  String get textColorLbl;

  /// No description provided for @cancelBtn.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelBtn;

  /// No description provided for @applyBtn.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get applyBtn;

  /// No description provided for @brightnessLbl.
  ///
  /// In en, this message translates to:
  /// **'Brightness'**
  String get brightnessLbl;

  /// No description provided for @contrastLbl.
  ///
  /// In en, this message translates to:
  /// **'Contrast'**
  String get contrastLbl;

  /// No description provided for @saturationLbl.
  ///
  /// In en, this message translates to:
  /// **'Saturation'**
  String get saturationLbl;

  /// No description provided for @hueLbl.
  ///
  /// In en, this message translates to:
  /// **'Hue'**
  String get hueLbl;

  /// No description provided for @sharpnessLbl.
  ///
  /// In en, this message translates to:
  /// **'Sharpness'**
  String get sharpnessLbl;

  /// No description provided for @bwLbl.
  ///
  /// In en, this message translates to:
  /// **'B&W'**
  String get bwLbl;

  /// No description provided for @unableToSaveMsg.
  ///
  /// In en, this message translates to:
  /// **'Unable to save image.'**
  String get unableToSaveMsg;

  /// No description provided for @noFilter.
  ///
  /// In en, this message translates to:
  /// **'No Filter'**
  String get noFilter;

  /// No description provided for @grayscale.
  ///
  /// In en, this message translates to:
  /// **'Grayscale'**
  String get grayscale;

  /// No description provided for @sepia.
  ///
  /// In en, this message translates to:
  /// **'Sepia'**
  String get sepia;

  /// No description provided for @cool.
  ///
  /// In en, this message translates to:
  /// **'Cool'**
  String get cool;

  /// No description provided for @warm.
  ///
  /// In en, this message translates to:
  /// **'Warm'**
  String get warm;

  /// No description provided for @uploadingPhotoProgress.
  ///
  /// In en, this message translates to:
  /// **'Uploading photo'**
  String get uploadingPhotoProgress;

  /// No description provided for @creatingLink.
  ///
  /// In en, this message translates to:
  /// **'Creating download link...'**
  String get creatingLink;

  /// No description provided for @uploadingPhotoOf.
  ///
  /// In en, this message translates to:
  /// **'Uploading photo {current} of {total}...'**
  String uploadingPhotoOf(String current, String total);

  /// No description provided for @errorLoadingStickers.
  ///
  /// In en, this message translates to:
  /// **'Error loading stickers'**
  String get errorLoadingStickers;

  /// No description provided for @emoji.
  ///
  /// In en, this message translates to:
  /// **'Emoji'**
  String get emoji;
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
    'da',
    'de',
    'en',
    'es',
    'fr',
    'it',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'da':
      return AppLocalizationsDa();
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'it':
      return AppLocalizationsIt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
