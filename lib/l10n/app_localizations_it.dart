// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get takeSelfie => 'TAKE A SELFIE';

  @override
  String get cloudStorageTitle => 'Cloud Storage e Privacy';

  @override
  String get cloudStorageDesc =>
      'Scegliendo di scaricare, le tue foto verranno caricate su un server cloud sicuro in modo da poterle visualizzare e scaricare.\n\nPer garantire la tua privacy, tutte le foto caricate verranno eliminate automaticamente e permanentemente allo scadere della sessione (entro 10 minuti).';

  @override
  String get gdprNotice =>
      'Titolare del trattamento: Arp-Hansen Hotel Group.\nContatto: reservations@nexthousecopenhagen.com.\nInquadra il QR code per leggere l\'informativa completa.';

  @override
  String get decline => 'Rifiuta';

  @override
  String get accept => 'Accetta';

  @override
  String get takeAnotherQuestion => 'Vuoi scattare un\'altra foto?';

  @override
  String get takeAnother => 'Scatta ancora';

  @override
  String get yes => 'Sì';

  @override
  String get no => 'No';

  @override
  String get done => 'Fatto';

  @override
  String get edit => 'Modifica';

  @override
  String get share => 'Scarica';

  @override
  String get download => 'Scarica';

  @override
  String get delete => 'Elimina';

  @override
  String get processing => 'Elaborazione';

  @override
  String get sharePhotosTitle => 'Scarica le tue foto';

  @override
  String get sharePhotosSubtitle =>
      'Seleziona le immagini che desideri salvare';

  @override
  String get ofWord => 'di';

  @override
  String get selected => 'selezionate';

  @override
  String get retry => 'Riprova';

  @override
  String get uploadingPhotos => 'Caricamento foto in corso...';

  @override
  String get creatingSession => 'Creazione sessione di download';

  @override
  String get scanMe => 'Scansionami!';

  @override
  String get stayCloseMsg =>
      'Rimani vicino al chiosco mentre completiamo l\'operazione.';

  @override
  String get sharingError => 'Errore di download';

  @override
  String get backToSelection => 'Torna alla selezione';

  @override
  String get filtersLabel => 'Filtri';

  @override
  String get adjustTool => 'Regola';

  @override
  String get stickerTool => 'Sticker';

  @override
  String get textTool => 'Testo';

  @override
  String get drawTool => 'Disegna';

  @override
  String get rotateTool => 'Ruota';

  @override
  String get resetBtn => 'Ripristina';

  @override
  String get saveBtn => 'Salva';

  @override
  String get editTextTitle => 'Modifica testo';

  @override
  String get addTextTitle => 'Aggiungi testo';

  @override
  String get writeSomethingHint => 'Scrivi qualcosa...';

  @override
  String get textColorLbl => 'Colore del testo:';

  @override
  String get cancelBtn => 'Annulla';

  @override
  String get applyBtn => 'Applica';

  @override
  String get brightnessLbl => 'Luminosità';

  @override
  String get contrastLbl => 'Contrasto';

  @override
  String get saturationLbl => 'Saturazione';

  @override
  String get hueLbl => 'Tonalità';

  @override
  String get sharpnessLbl => 'Nitidezza';

  @override
  String get bwLbl => 'B&N';

  @override
  String get unableToSaveMsg => 'Impossibile salvare l\'immagine.';

  @override
  String get noFilter => 'Nessuno';

  @override
  String get grayscale => 'Scala di grigi';

  @override
  String get sepia => 'Seppia';

  @override
  String get cool => 'Freddo';

  @override
  String get warm => 'Caldo';

  @override
  String get uploadingPhotoProgress => 'Caricamento foto';

  @override
  String get creatingLink => 'Creazione link di download...';

  @override
  String uploadingPhotoOf(String current, String total) {
    return 'Caricamento foto $current di $total...';
  }

  @override
  String get errorLoadingStickers => 'Errore nel caricamento degli sticker';

  @override
  String get emoji => 'Emoji';
}
