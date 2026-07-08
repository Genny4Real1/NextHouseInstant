// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get takeSelfie => 'TAKE A SELFIE';

  @override
  String get cloudStorageTitle => 'Almacenamiento en la Nube y Privacidad';

  @override
  String get cloudStorageDesc =>
      'Al elegir descargar, sus fotos se subirán a un servidor seguro en la nube para que pueda acceder a ellas y descargarlas.\n\nPara garantizar su privacidad, todas las fotos subidas se eliminarán de forma automática y permanente al expirar la sesión (dentro de 10 minutos).';

  @override
  String get gdprNotice =>
      'Responsable del tratamiento: Arp-Hansen Hotel Group.\nContacto: reservations@nexthousecopenhagen.com.\nEscanee el código QR para leer la política de privacidad completa.';

  @override
  String get decline => 'Rechazar';

  @override
  String get accept => 'Aceptar';

  @override
  String get takeAnotherQuestion => '¿Quieres tomar otra foto?';

  @override
  String get takeAnother => 'Tomar otra';

  @override
  String get yes => 'Sí';

  @override
  String get no => 'No';

  @override
  String get done => 'Hecho';

  @override
  String get edit => 'Editar';

  @override
  String get share => 'Descargar';

  @override
  String get download => 'Descargar';

  @override
  String get delete => 'Eliminar';

  @override
  String get processing => 'Procesando';

  @override
  String get sharePhotosTitle => 'Descarga tus fotos';

  @override
  String get sharePhotosSubtitle =>
      'Selecciona las imágenes que deseas guardar';

  @override
  String get ofWord => 'de';

  @override
  String get selected => 'seleccionadas';

  @override
  String get retry => 'Reintentar';

  @override
  String get uploadingPhotos => 'Subiendo fotos...';

  @override
  String get creatingSession => 'Creando sesión de descarga';

  @override
  String get scanMe => '¡Escanéame!';

  @override
  String get stayCloseMsg =>
      'Permanece cerca del quiosco mientras completamos la operación.';

  @override
  String get sharingError => 'Error de descarga';

  @override
  String get backToSelection => 'Volver a la selección';

  @override
  String get filtersLabel => 'Filtros';

  @override
  String get adjustTool => 'Ajustar';

  @override
  String get stickerTool => 'Stickers';

  @override
  String get textTool => 'Texto';

  @override
  String get drawTool => 'Dibujar';

  @override
  String get rotateTool => 'Rotar';

  @override
  String get resetBtn => 'Restablecer';

  @override
  String get saveBtn => 'Guardar';

  @override
  String get editTextTitle => 'Editar texto';

  @override
  String get addTextTitle => 'Añadir texto';

  @override
  String get writeSomethingHint => 'Escribe algo...';

  @override
  String get textColorLbl => 'Color del texto:';

  @override
  String get cancelBtn => 'Cancelar';

  @override
  String get applyBtn => 'Aplicar';

  @override
  String get brightnessLbl => 'Brillo';

  @override
  String get contrastLbl => 'Contraste';

  @override
  String get saturationLbl => 'Saturación';

  @override
  String get hueLbl => 'Tono';

  @override
  String get sharpnessLbl => 'Nitidez';

  @override
  String get bwLbl => 'B y N';

  @override
  String get unableToSaveMsg => 'No se pudo guardar la imagen.';

  @override
  String get noFilter => 'Sin filtro';

  @override
  String get grayscale => 'Escala de grises';

  @override
  String get sepia => 'Sepia';

  @override
  String get cool => 'Frío';

  @override
  String get warm => 'Cálido';

  @override
  String get uploadingPhotoProgress => 'Subiendo foto';

  @override
  String get creatingLink => 'Creando enlace de descarga...';

  @override
  String uploadingPhotoOf(String current, String total) {
    return 'Subiendo foto $current de $total...';
  }

  @override
  String get errorLoadingStickers => 'Error al cargar los stickers';

  @override
  String get emoji => 'Emoji';
}
