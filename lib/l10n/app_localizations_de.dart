// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get takeSelfie => 'TAKE A SELFIE';

  @override
  String get cloudStorageTitle => 'Cloud-Speicher & Datenschutz';

  @override
  String get cloudStorageDesc =>
      'Wenn Sie sich für das Teilen entscheiden, werden Ihre Fotos auf einen sicheren Cloud-Server hochgeladen, damit Sie darauf zugreifen und sie herunterladen können.\n\nUm Ihre Privatsphäre zu schützen, werden alle hochgeladenen Fotos nach 48 Stunden automatisch und dauerhaft gelöscht.';

  @override
  String get gdprNotice =>
      'Verantwortlicher: Arp-Hansen Hotel Group.\nKontakt: reservations@nexthousecopenhagen.com.\nScannen Sie den QR-Code, um die vollständige Datenschutzerklärung zu lesen.';

  @override
  String get decline => 'Ablehnen';

  @override
  String get accept => 'Akzeptieren';

  @override
  String get takeAnotherQuestion => 'Möchten Sie noch ein Foto machen?';

  @override
  String get yes => 'Ja';

  @override
  String get no => 'Nein';

  @override
  String get done => 'Fertig';

  @override
  String get edit => 'Bearbeiten';

  @override
  String get share => 'Teilen';

  @override
  String get delete => 'Löschen';

  @override
  String get processing => 'Verarbeitung';

  @override
  String get sharePhotosTitle => 'Teile deine Fotos';

  @override
  String get sharePhotosSubtitle =>
      'Wähle die Bilder aus, die du speichern möchtest';

  @override
  String get ofWord => 'von';

  @override
  String get selected => 'ausgewählt';

  @override
  String get retry => 'Wiederholen';

  @override
  String get uploadingPhotos => 'Fotos werden hochgeladen...';

  @override
  String get creatingSession => 'Download-Sitzung wird erstellt';

  @override
  String get scanMe => 'Scann mich!';

  @override
  String get stayCloseMsg =>
      'Bleibe in der Nähe des Kiosks, während wir den Vorgang abschließen.';

  @override
  String get sharingError => 'Freigabefehler';

  @override
  String get backToSelection => 'Zurück zur Auswahl';

  @override
  String get filtersLabel => 'Filter';

  @override
  String get adjustTool => 'Anpassen';

  @override
  String get stickerTool => 'Sticker';

  @override
  String get textTool => 'Text';

  @override
  String get drawTool => 'Zeichnen';

  @override
  String get rotateTool => 'Drehen';

  @override
  String get resetBtn => 'Zurücksetzen';

  @override
  String get saveBtn => 'Speichern';

  @override
  String get editTextTitle => 'Text bearbeiten';

  @override
  String get addTextTitle => 'Text hinzufügen';

  @override
  String get writeSomethingHint => 'Schreibe etwas...';

  @override
  String get textColorLbl => 'Textfarbe:';

  @override
  String get cancelBtn => 'Abbrechen';

  @override
  String get applyBtn => 'Anwenden';

  @override
  String get brightnessLbl => 'Helligkeit';

  @override
  String get contrastLbl => 'Kontrast';

  @override
  String get saturationLbl => 'Sättigung';

  @override
  String get hueLbl => 'Farbton';

  @override
  String get sharpnessLbl => 'Schärfe';

  @override
  String get bwLbl => 'S/W';

  @override
  String get unableToSaveMsg => 'Bild konnte nicht gespeichert werden.';

  @override
  String get noFilter => 'Kein Filter';

  @override
  String get grayscale => 'Graustufen';

  @override
  String get sepia => 'Sepia';

  @override
  String get cool => 'Kalt';

  @override
  String get warm => 'Warm';

  @override
  String get uploadingPhotoProgress => 'Foto wird hochgeladen';

  @override
  String get creatingLink => 'Download-Link wird erstellt...';

  @override
  String uploadingPhotoOf(String current, String total) {
    return 'Foto $current von $total wird hochgeladen...';
  }

  @override
  String get errorLoadingStickers => 'Fehler beim Laden der Sticker';

  @override
  String get emoji => 'Emoji';
}
