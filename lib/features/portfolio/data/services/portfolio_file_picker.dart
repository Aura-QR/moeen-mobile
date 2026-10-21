import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:moean/features/portfolio/data/models/portfolio_upload_models.dart';

/// Picks evidence from the camera, the gallery or the files app.
class PortfolioFilePicker {
  PortfolioFilePicker({ImagePicker? imagePicker})
      : _imagePicker = imagePicker ?? ImagePicker();

  final ImagePicker _imagePicker;

  /// Returns null when the teacher cancels.
  Future<PortfolioPickedFile?> pick(PortfolioFileSource source) async {
    if (source == PortfolioFileSource.pdf) return _pickPdf();

    // With imageQuality set, iOS converts HEIC to JPEG, and 2000px keeps
    // phone photos well under the 10 MB limit.
    final image = await _imagePicker.pickImage(
      source: source == PortfolioFileSource.camera ? ImageSource.camera : ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 2000,
    );
    if (image == null) return null;

    return PortfolioPickedFile(
      bytes: await image.readAsBytes(),
      name: image.name,
      mime: PortfolioPickedFile.mimeFromName(image.name),
    );
  }

  Future<PortfolioPickedFile?> _pickPdf() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['pdf'],
      withData: true,
    );
    final file = result?.files.single;
    if (file == null || file.bytes == null) return null;

    return PortfolioPickedFile(
      bytes: file.bytes!,
      name: file.name,
      mime: PortfolioPickedFile.mimeFromName(file.name),
    );
  }
}
