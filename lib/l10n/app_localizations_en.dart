// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get takeSelfie => 'TAKE A SELFIE';

  @override
  String get cloudStorageTitle => 'Cloud Storage & Privacy';

  @override
  String get cloudStorageDesc =>
      'By choosing to download, your photos will be uploaded to a secure cloud server so you can access and download them.\n\nTo ensure your privacy, all uploaded photos will be automatically and permanently deleted upon session expiration (within 10 minutes).';

  @override
  String get gdprNotice =>
      'Data Controller: Arp-Hansen Hotel Group.\nContact: reservations@nexthousecopenhagen.com.\nScan the QR code to read the full Privacy Policy.';

  @override
  String get decline => 'Decline';

  @override
  String get accept => 'Accept';

  @override
  String get takeAnotherQuestion => 'Do you want to take another picture?';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get done => 'Done';

  @override
  String get edit => 'Edit';

  @override
  String get share => 'Download';

  @override
  String get download => 'Download';

  @override
  String get delete => 'Delete';

  @override
  String get processing => 'Processing';

  @override
  String get sharePhotosTitle => 'Download your photos';

  @override
  String get sharePhotosSubtitle => 'Select the images you want to save';

  @override
  String get ofWord => 'of';

  @override
  String get selected => 'selected';

  @override
  String get retry => 'Retry';

  @override
  String get uploadingPhotos => 'Uploading photos...';

  @override
  String get creatingSession => 'Creating download session';

  @override
  String get scanMe => 'Scan me!';

  @override
  String get stayCloseMsg =>
      'Stay close to the kiosk while we complete the operation.';

  @override
  String get sharingError => 'Download Error';

  @override
  String get backToSelection => 'Back to selection';

  @override
  String get filtersLabel => 'Filters';

  @override
  String get adjustTool => 'Adjust';

  @override
  String get stickerTool => 'Sticker';

  @override
  String get textTool => 'Text';

  @override
  String get drawTool => 'Draw';

  @override
  String get rotateTool => 'Rotate';

  @override
  String get resetBtn => 'Reset';

  @override
  String get saveBtn => 'Save';

  @override
  String get editTextTitle => 'Edit Text';

  @override
  String get addTextTitle => 'Add Text';

  @override
  String get writeSomethingHint => 'Write something...';

  @override
  String get textColorLbl => 'Text color:';

  @override
  String get cancelBtn => 'Cancel';

  @override
  String get applyBtn => 'Apply';

  @override
  String get brightnessLbl => 'Brightness';

  @override
  String get contrastLbl => 'Contrast';

  @override
  String get saturationLbl => 'Saturation';

  @override
  String get hueLbl => 'Hue';

  @override
  String get sharpnessLbl => 'Sharpness';

  @override
  String get bwLbl => 'B&W';

  @override
  String get unableToSaveMsg => 'Unable to save image.';

  @override
  String get noFilter => 'No Filter';

  @override
  String get grayscale => 'Grayscale';

  @override
  String get sepia => 'Sepia';

  @override
  String get cool => 'Cool';

  @override
  String get warm => 'Warm';

  @override
  String get uploadingPhotoProgress => 'Uploading photo';

  @override
  String get creatingLink => 'Creating download link...';

  @override
  String uploadingPhotoOf(String current, String total) {
    return 'Uploading photo $current of $total...';
  }

  @override
  String get errorLoadingStickers => 'Error loading stickers';

  @override
  String get emoji => 'Emoji';
}
