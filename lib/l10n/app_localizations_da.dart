// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Danish (`da`).
class AppLocalizationsDa extends AppLocalizations {
  AppLocalizationsDa([String locale = 'da']) : super(locale);

  @override
  String get takeSelfie => 'TAKE A SELFIE';

  @override
  String get cloudStorageTitle => 'Cloud-lager & Privatliv';

  @override
  String get cloudStorageDesc =>
      'Ved at vælge at dele vil dine billeder blive uploadet til en sikker cloud-server, så du kan få adgang til og downloade dem.\n\nFor at sikre dit privatliv slettes alle uploadede billeder automatisk og permanent efter 48 timer.';

  @override
  String get gdprNotice =>
      'Dataansvarlig: Arp-Hansen Hotel Group.\nKontakt: reservations@nexthousecopenhagen.com.\nScan QR-koden for at læse den fulde privatlivspolitik.';

  @override
  String get decline => 'Afvis';

  @override
  String get accept => 'Accepter';

  @override
  String get takeAnotherQuestion => 'Vil du tage et billede mere?';

  @override
  String get yes => 'Ja';

  @override
  String get no => 'Nej';

  @override
  String get done => 'Færdig';

  @override
  String get edit => 'Rediger';

  @override
  String get share => 'Del';

  @override
  String get delete => 'Slet';

  @override
  String get processing => 'Behandler';

  @override
  String get sharePhotosTitle => 'Del dine billeder';

  @override
  String get sharePhotosSubtitle => 'Vælg de billeder, du vil gemme';

  @override
  String get ofWord => 'af';

  @override
  String get selected => 'valgt';

  @override
  String get retry => 'Prøv igen';

  @override
  String get uploadingPhotos => 'Uploader billeder...';

  @override
  String get creatingSession => 'Opretter download-session';

  @override
  String get scanMe => 'Scan mig!';

  @override
  String get stayCloseMsg =>
      'Bliv tæt på kiosken, mens vi fuldfører handlingen.';

  @override
  String get sharingError => 'Fejl ved deling';

  @override
  String get backToSelection => 'Tilbage til valg';

  @override
  String get filtersLabel => 'Filtre';

  @override
  String get adjustTool => 'Juster';

  @override
  String get stickerTool => 'Klistermærke';

  @override
  String get textTool => 'Tekst';

  @override
  String get drawTool => 'Tegn';

  @override
  String get rotateTool => 'Roter';

  @override
  String get resetBtn => 'Nulstil';

  @override
  String get saveBtn => 'Gem';

  @override
  String get editTextTitle => 'Rediger tekst';

  @override
  String get addTextTitle => 'Tilføj tekst';

  @override
  String get writeSomethingHint => 'Skriv noget...';

  @override
  String get textColorLbl => 'Tekstfarve:';

  @override
  String get cancelBtn => 'Annuller';

  @override
  String get applyBtn => 'Anvend';

  @override
  String get brightnessLbl => 'Lysstyrke';

  @override
  String get contrastLbl => 'Kontrast';

  @override
  String get saturationLbl => 'Mætning';

  @override
  String get hueLbl => 'Farvetone';

  @override
  String get sharpnessLbl => 'Skarphed';

  @override
  String get bwLbl => 'S/H';

  @override
  String get unableToSaveMsg => 'Kunne ikke gemme billedet.';

  @override
  String get noFilter => 'Intet filter';

  @override
  String get grayscale => 'Gråtoner';

  @override
  String get sepia => 'Sepia';

  @override
  String get cool => 'Kølig';

  @override
  String get warm => 'Varm';

  @override
  String get uploadingPhotoProgress => 'Uploader foto';

  @override
  String get creatingLink => 'Opretter download-link...';

  @override
  String uploadingPhotoOf(String current, String total) {
    return 'Uploader foto $current af $total...';
  }

  @override
  String get errorLoadingStickers => 'Fejl ved indlæsning af klistermærker';

  @override
  String get emoji => 'Emoji';
}
