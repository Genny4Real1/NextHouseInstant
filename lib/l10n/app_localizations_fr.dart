// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get takeSelfie => 'TAKE A SELFIE';

  @override
  String get cloudStorageTitle => 'Stockage Cloud & Confidentialité';

  @override
  String get cloudStorageDesc =>
      'En choisissant de télécharger, vos photos seront téléchargées sur un serveur cloud sécurisé afin que vous puissiez y accéder et les télécharger.\n\nPour garantir votre confidentialité, toutes les photos téléchargées seront automatiquement et définitivement supprimées à l\'expiration de la session (sous 10 minutes).';

  @override
  String get gdprNotice =>
      'Responsable du traitement: Arp-Hansen Hotel Group.\nContact: reservations@nexthousecopenhagen.com.\nScannez le code QR pour lire la politique de confidentialité complète.';

  @override
  String get decline => 'Refuser';

  @override
  String get accept => 'Accepter';

  @override
  String get takeAnotherQuestion => 'Voulez-vous prendre une autre photo?';

  @override
  String get yes => 'Oui';

  @override
  String get no => 'Non';

  @override
  String get done => 'Terminé';

  @override
  String get edit => 'Modifier';

  @override
  String get share => 'Télécharger';

  @override
  String get download => 'Télécharger';

  @override
  String get delete => 'Supprimer';

  @override
  String get processing => 'Traitement';

  @override
  String get sharePhotosTitle => 'Téléchargez vos photos';

  @override
  String get sharePhotosSubtitle =>
      'Sélectionnez les images que vous souhaitez enregistrer';

  @override
  String get ofWord => 'sur';

  @override
  String get selected => 'sélectionnées';

  @override
  String get retry => 'Réessayer';

  @override
  String get uploadingPhotos => 'Téléchargement des photos...';

  @override
  String get creatingSession => 'Création de la session de téléchargement';

  @override
  String get scanMe => 'Scannez-moi !';

  @override
  String get stayCloseMsg =>
      'Restez près du chiosque pendant que nous terminons l\'opération.';

  @override
  String get sharingError => 'Erreur de téléchargement';

  @override
  String get backToSelection => 'Retour à la sélection';

  @override
  String get filtersLabel => 'Filtres';

  @override
  String get adjustTool => 'Ajuster';

  @override
  String get stickerTool => 'Autocollant';

  @override
  String get textTool => 'Texte';

  @override
  String get drawTool => 'Dessiner';

  @override
  String get rotateTool => 'Pivoter';

  @override
  String get resetBtn => 'Réinitialiser';

  @override
  String get saveBtn => 'Enregistrer';

  @override
  String get editTextTitle => 'Modifier le texte';

  @override
  String get addTextTitle => 'Ajouter du texte';

  @override
  String get writeSomethingHint => 'Écrivez quelque chose...';

  @override
  String get textColorLbl => 'Couleur du texte :';

  @override
  String get cancelBtn => 'Annuler';

  @override
  String get applyBtn => 'Appliquer';

  @override
  String get brightnessLbl => 'Luminosité';

  @override
  String get contrastLbl => 'Contraste';

  @override
  String get saturationLbl => 'Saturation';

  @override
  String get hueLbl => 'Teinte';

  @override
  String get sharpnessLbl => 'Netteté';

  @override
  String get bwLbl => 'N&B';

  @override
  String get unableToSaveMsg => 'Impossible d\'enregistrer l\'image.';

  @override
  String get noFilter => 'Sans filtre';

  @override
  String get grayscale => 'Niveaux de gris';

  @override
  String get sepia => 'Sépia';

  @override
  String get cool => 'Froid';

  @override
  String get warm => 'Chaud';

  @override
  String get uploadingPhotoProgress => 'Téléchargement de la photo';

  @override
  String get creatingLink => 'Création du lien de téléchargement...';

  @override
  String uploadingPhotoOf(String current, String total) {
    return 'Téléchargement de la photo $current sur $total...';
  }

  @override
  String get errorLoadingStickers =>
      'Erreur lors du chargement des autocollants';

  @override
  String get emoji => 'Emoji';
}
